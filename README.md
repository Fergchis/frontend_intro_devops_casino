# casino-frontend

SPA en **Angular 17** (standalone components, signals, lazy routes) del
**Casino Online** — asignatura **Introducción a Herramientas DevOps (ISY1101)**.
Consume la API de `casino-backend` y los microservicios de bonos, apuestas y
estadísticas.

## Stack
- Angular 17 · TypeScript 5.4
- Animaciones: GSAP 3, Three.js, Phaser 3
- Auth: JWT vía HTTP interceptor
- Pruebas: **Karma + Jasmine**

## Cómo funciona
- **Auth:** login/registro contra el backend; `AuthService` guarda el JWT en
  `localStorage` con **signals**; `authInterceptor` adjunta `Authorization: Bearer`
  a cada request; `authGuard` protege las rutas privadas.
- **Rutas:** todas las vistas usan **lazy loading** (`loadComponent`).
- **Backend:** las URLs salen de `environment.apiBaseUrl` (dev: `http://localhost:3000`;
  prod: cadena vacía → rutas relativas).

## Estructura (resumen)
```
src/app/
├── services/      auth.service.ts · casino.service.ts · apuestas.service.ts · ...
├── interceptors/  auth.interceptor.ts
├── guards/        auth.guard.ts
├── components/    login · register · lobby · slots · roulette · blackjack ·
│                  bonos · apuestas (mini-cancha) · estadisticas · history · header
└── models/        casino.models.ts
```

## Ejecutar en local
Requisito: backend corriendo en `http://localhost:3000`.
```bash
npm ci             # instala dependencias desde package-lock.json
npm start          # ng serve → http://localhost:4200
```

## Pruebas
Este repo **ya incluye pruebas unitarias** (Karma + Jasmine). Para correrlas en
modo CI (sin ventana ni watch):
```bash
npm ci
npm test -- --watch=false --browsers=ChromeHeadless
```

## Qué debes hacer en este repo (Entrega ET)
Trabaja en tu **fork**, con ramas `dev` (trabajo) y `deploy` (gatilla el pipeline).

1. **Integrar las pruebas al pipeline (obligatorio):** este repo **ya trae pruebas**
   (`npm ci && npm test -- --watch=false --browsers=ChromeHeadless`). Agrégalas como
   etapa que **bloquea el deploy** si fallan: build → **test** → push ECR → deploy EKS.
2. **Dockerfile** que compile la SPA (`npm run build`) y la sirva con **nginx**.
3. **nginx**: servir la SPA (con *fallback* de rutas para que el routing de Angular
   no dé 404 al recargar) y hacer **reverse proxy** de `/api/*` hacia los backends
   por el DNS interno del clúster.
4. **Manifiestos de Kubernetes**: `Deployment` + `Service` tipo **LoadBalancer**
   (es el **único** componente expuesto a Internet).
5. **Workflow CI/CD** gatillado por `deploy` (con etapa de *test*), **HPA** y
   autorecuperación de pods.

> Transversal (clúster, una sola vez): **Prometheus + Grafana** y el **video**.

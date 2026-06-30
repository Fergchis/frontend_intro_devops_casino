#ETAPA DE CREACION
#Imagen
FROM node:20-alpine AS builder

#Directorio de trabajo
WORKDIR /app

COPY package*.json ./

#Instalar solo dependencias necesarias
RUN npm install --legacy-peer-deps --no-audit --no-fund

#Pasamos el codigo fuente al entorno de preparacion
COPY . .

#Build de produccion: genera artefactos estaticos
RUN npm run build && \
    mkdir -p /app/build-output && \
    ( cp -r /app/dist/*/browser/* /app/build-output/ 2>/dev/null || \
      cp -r /app/dist/*/* /app/build-output/ )

#ETAPA DE EJECUCION
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

#Configuracion Nginx con propiedad para usuario (nginx)
COPY --chown=nginx:nginx nginx.conf /etc/nginx/templates/default.conf.template

#Se traen los archivos compilados en la preparacion
#Se le asigna la propiedad a usuario (nginx) y no (root)
COPY --from=builder --chown=nginx:nginx /app/dist/casino-frontend/browser/. /usr/share/nginx/html/

#Comprobacion de estado mediante peticion HTTP interna
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD wget --spider -q http://127.0.0.1:8080/ || exit 1

#Se cambia a usuario sin privilegios
USER nginx

#Comunicacion del docker 
EXPOSE 8080

#Comprobacion de estado mediante peticion HTTP interna
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1

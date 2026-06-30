#ETAPA DE CREACION
#Imagen
FROM node:20-alpine AS builder

#Directorio de trabajo
WORKDIR /app

COPY package*.json ./

#Instalar solo dependencias necesarias
RUN npm ci

#Pasamos el codigo fuente al entorno de preparacion
COPY . .

#Build de produccion: genera artefactos estaticos
RUN npm run build && \
    mkdir -p /app/build-output && \
    ( cp -r /app/dist/*/browser/* /app/build-output/ 2>/dev/null || \
      cp -r /app/dist/*/* /app/build-output/ )

#ETAPA DE EJECUCION
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

LABEL maintainer="curso-devops"
LABEL descripcion="Frontend Casino - Angular"

#Copiar configuracion de Nginx
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

#Se traen los artefactos estaticos de la preparacion
#Se le asigna la propiedad a usuario (nginx) y no (root)
COPY --from=builder --chown=nginx:nginx /app/build-output/ /usr/share/nginx/html/

#Se cambia a usuario sin privilegios
USER nginx

#Comunicacion del docker 
EXPOSE 8080

#Comprobacion de estado mediante peticion HTTP interna
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1
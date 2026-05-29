# 1. Imagen base de compilación con Node 22 (Alpine)
FROM node:22-alpine AS builder

WORKDIR /data

# Instalamos herramientas nativas del sistema necesarias para compilar módulos de C++
RUN apk add --no-cache python3 make g++ git

# Instalamos pnpm globalmente
RUN npm install -g pnpm

# Copiamos la totalidad del proyecto (incluyendo turbo.json, package.json, scripts y parches)
COPY . .

# Instalamos las dependencias permitiendo que se ejecuten los scripts de enlace internos
RUN pnpm install --frozen-lockfile

# Compilamos el proyecto completo usando el pipeline de Turborepo
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución internos con los cambios compilados de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

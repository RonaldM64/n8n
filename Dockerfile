# 1. Imagen base de compilación con Node 22
FROM node:22-alpine AS builder

WORKDIR /data

# Instalamos las herramientas necesarias para compilar el monorepo
RUN apk add --no-cache python3 make g++ git

# Copiamos los archivos de configuración de dependencias y la carpeta de parches
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY patches/ ./patches/
COPY packages/cli/package.json ./packages/cli/
COPY packages/core/package.json ./packages/core/
COPY packages/nodes-base/package.json ./packages/nodes-base/

# Instalamos pnpm globalmente e instalamos dependencias aplicando parches
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copiamos el resto del código fuente y compilamos todo el proyecto
COPY . .
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución internos con los cambios de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

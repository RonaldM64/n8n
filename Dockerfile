# Pasos de compilación pesados en una imagen temporal
FROM node:18-alpine AS builder

WORKDIR /data

# Instalamos las herramientas necesarias para compilar el monorepo
RUN apk add --no-cache python3 make g++ git

# Copiamos los archivos de configuración de dependencias
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/cli/package.json ./packages/cli/
COPY packages/core/package.json ./packages/core/
COPY packages/nodes-base/package.json ./packages/nodes-base/

# Instalamos pnpm globalmente e instalamos dependencias
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copiamos el resto del código y compilamos el proyecto
COPY . .
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN (Ultra ligera y limpia) ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución internos con los cambios de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

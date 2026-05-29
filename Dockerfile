# 1. Imagen base de compilación con Node 22 (Alpine)
FROM node:22-alpine AS builder

WORKDIR /data

# Herramientas nativas necesarias
RUN apk add --no-cache python3 make g++ git

# Instalamos pnpm globalmente
RUN npm install -g pnpm

# Copiamos todo el proyecto
COPY . .

# EVITAR LEFTHOOK: Desactivamos los scripts de preparación de Git durante la instalación
RUN pnpm config set side-effects-cache false && \
    pnpm install --frozen-lockfile --ignore-scripts

# Compilamos el proyecto completo usando Turborepo de forma directa
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución con los de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

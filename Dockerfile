# 1. Imagen base de compilación con Node 22 (Alpine)
FROM node:22-alpine AS builder

WORKDIR /data

# Herramientas nativas necesarias
RUN apk add --no-cache python3 make g++ git

# Instalamos pnpm globalmente
RUN npm install -g pnpm

# Copiamos todo el proyecto
COPY . .

# Instalamos dependencias ignorando los scripts problemáticos de Git
RUN pnpm install --frozen-lockfile --ignore-scripts

# COMPILACIÓN FILTRADA: Compilamos solo lo esencial en orden, saltándonos Turborepo global
RUN pnpm --filter n8n-core build && \
    pnpm --filter n8n-nodes-base build && \
    pnpm --filter n8n build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución con los de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

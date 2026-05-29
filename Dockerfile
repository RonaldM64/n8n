# 1. Imagen base de compilación con Node 22 (Alpine)
FROM node:22-alpine AS builder

WORKDIR /data

# CORREGIDO: git completamente en minúsculas
RUN apk add --no-cache python3 make g++ git

# Instalamos pnpm y turbo globalmente para evitar fallos de ruta
RUN npm install -g pnpm turborepo

# Copiamos absolutamente todo el monorepo
COPY . .

# Instalamos todas las dependencias permitiendo enlaces internos de pnpm
RUN pnpm install --frozen-lockfile

# Compilamos el proyecto completo usando la arquitectura del monorepo original
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Inyectamos los paquetes con los cambios de tu fork en la imagen oficial
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

# 1. Imagen base de compilación con Node 22 (Alpine)
FROM node:22-alpine AS builder

WORKDIR /data

# Instalamos las herramientas nativas necesarias para compilar el monorepo
RUN apk add --no-cache python3 make g++ git

# Copiamos la TOTALIDAD del proyecto para que no falte ningún script (como scripts/ o patches/)
COPY . .

# Instalamos pnpm globalmente
RUN npm install -g pnpm

# Instalamos las dependencias ignorando temporalmente los scripts de ciclo de vida
RUN pnpm install --frozen-lockfile --ignore-scripts

# Compilamos el proyecto completo (esto generará los binarios y ejecutables internos que faltaban)
RUN pnpm build

# --- IMAGEN FINAL DE PRODUCCIÓN ---
FROM n8nio/n8n:latest

# Reemplazamos los archivos de ejecución internos con los cambios compilados de tu fork
COPY --from=builder /data/packages /usr/local/lib/node_modules/n8n/packages

EXPOSE 5678

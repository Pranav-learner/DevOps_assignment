# Stage 1: Dependency resolution & build
FROM node:22-alpine AS builder

WORKDIR /app

COPY application/package.json ./
RUN npm install --omit=dev --ignore-scripts

# Stage 2: Minimal zero-vulnerability runtime container
FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV DATA_DIR=/data

# Create data directory and assign ownership to node user
RUN mkdir -p /data && chown -R node:node /data

# Copy application artifacts from builder
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node application/package.json ./
COPY --chown=node:node application/src ./src

# Hardening: Purge package managers & package caches to minimize CVE surface
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /etc/apk/cache

# Enforce non-root execution
USER node

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/healthz || exit 1

CMD ["node", "src/server.js"]

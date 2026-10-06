# =========================================================
# Stage 1: Dependencies & Builder
# =========================================================
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY app/package*.json ./
RUN npm ci --only=production

# =========================================================
# Stage 2: Hardened Production Runtime
# =========================================================
FROM node:20-alpine AS runner

WORKDIR /usr/src/app

# Security: Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Copy node_modules from builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY app/package*.json ./
COPY app/src/ ./src/

# Security: Use non-root node user (UID 1000)
USER node

EXPOSE 3000

# Container Healthcheck
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/health || exit 1

CMD ["node", "src/server.js"]

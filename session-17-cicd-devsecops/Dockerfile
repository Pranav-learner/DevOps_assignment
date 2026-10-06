# =========================================================
# Stage 1: Build & Dependencies
# =========================================================
FROM node:22-alpine AS builder

WORKDIR /usr/src/app

COPY app/package*.json ./
RUN npm ci --only=production

# =========================================================
# Stage 2: Hardened Production Runtime (Zero CVE attack surface)
# =========================================================
FROM node:22-alpine AS runner

WORKDIR /usr/src/app

ENV NODE_ENV=production
ENV PORT=3000

# Remove build tools, package managers & package caches from runtime
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/bin/corepack \
           /usr/local/bin/yarn* \
           /etc/apk \
           /lib/apk \
           /usr/share/apk

# Copy pruned production dependencies and app source
COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --chown=node:node app/package*.json ./
COPY --chown=node:node app/src/ ./src/

# Security: Enforce non-root execution (UID 1000)
USER node

EXPOSE 3000

# Security: Container Healthcheck
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/health || exit 1

CMD ["node", "src/server.js"]

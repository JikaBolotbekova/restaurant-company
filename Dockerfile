# ==========================================
# STAGE 1 - BUILD REACT/VITE APPLICATION
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files first for Docker cache
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source code
COPY . .

# Build production application
RUN npm run build


# ==========================================
# STAGE 2 - NGINX PRODUCTION SERVER
# ==========================================
FROM nginx:alpine

# Remove default nginx configuration
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy our nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built React/Vite application
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Container health check
HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]

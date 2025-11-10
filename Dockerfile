# ===============================
# Stage 1 — Build the Next.js app
# ===============================
FROM node:18-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Copy dependency files first (for caching)
COPY package*.json ./

# Install dependencies
# --legacy-peer-deps → fixes React/Next peer conflicts
# --ignore-scripts → skips Prisma postinstall (no schema inside build yet)
RUN npm install --legacy-peer-deps --ignore-scripts

# Copy all source code
COPY . .

# Optional: copy prisma directory if exists (uncomment if your repo has one)
# COPY prisma ./prisma

# Build the app for production
RUN npm run build

# ===============================
# Stage 2 — Run the production app
# ===============================
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy necessary build artifacts from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.mjs ./next.config.mjs

# Expose the Next.js port
EXPOSE 3000

# Start the production server
CMD ["npm", "start"]

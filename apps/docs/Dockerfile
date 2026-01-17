FROM node:22-alpine

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@10 --activate

# Copy dependency files FIRST (cacheable layer)
COPY pnpm-workspace.yaml pnpm-lock.yaml .npmrc package.json turbo.json ./
COPY apps/docs/package.json ./apps/docs/

# Install dependencies (cached unless lockfile changes)
RUN pnpm install --frozen-lockfile

# Copy source code LAST (frequently changes)
COPY apps/docs/ ./apps/docs/

EXPOSE 3055
ENV PORT=3000

# OpenAPI generation + dev server at runtime
CMD ["sh", "-c", "pnpm build:openapi && pnpm turbo dev --filter=docs"]

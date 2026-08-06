# syntax=docker/dockerfile:1
#
# Build context is the REPO ROOT, matching Dokploy's default and the convention in
# the other repos — so every COPY path is repo-relative.
#
# Why the root is the context and not next/example: the app depends on the design
# system as `file:../..`, i.e. this repository. npm resolves that to a symlink, so
# the DS has to be inside the build context or install fails. It also means QA
# needs no deploy key for the private repo — the checkout already is the dependency.

FROM node:22-slim AS build
WORKDIR /repo

# The design system, matching the `files` allowlist in the root package.json.
COPY package.json index.js index.d.ts styles.css ./
COPY components ./components
COPY tokens ./tokens
COPY ui_kits/shared ./ui_kits/shared

# The app.
COPY next/example/package.json next/example/package-lock.json ./next/example/
WORKDIR /repo/next/example
RUN npm ci --no-audit --no-fund

COPY next/example ./
RUN npm run build

FROM node:22-slim AS run
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# Next's standalone output keeps the source tree's shape, and outputFileTracingRoot
# is the repo root — so the server lands at next/example/server.js, not server.js.
COPY --from=build /repo/next/example/.next/standalone ./
COPY --from=build /repo/next/example/.next/static ./next/example/.next/static

EXPOSE 3000
CMD ["node", "next/example/server.js"]

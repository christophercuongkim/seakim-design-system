# syntax=docker/dockerfile:1
#
# Build context is the REPO ROOT, matching Dokploy's default and the convention in
# the sibling repos — so every COPY path is repo-relative.
#
# Why the root and not next/example: the app depends on the design system as
# `file:../..`, i.e. this repository. npm resolves that to a symlink, so the DS has
# to be inside the build context or install fails. It also means QA needs no deploy
# key for the private repo — the checkout already IS the dependency.
#
# Four bindings are served from one container. Only Next is a running server; the
# other three are static and land in public/.

# ---------------------------------------------------------------- Flutter → web
# The slowest stage by far (SDK pull + compile). It is cached unless something in
# flutter/ changes, so a token-only PR does not pay for it.
# cirruslabs publishes no pinned 3.44.x tag, so this tracks `stable` (3.44.0 at
# time of writing, against a pubspec floor of 3.19.0). It can therefore drift under
# you — a Flutter release that breaks the build shows up here first, not in CI.
FROM ghcr.io/cirruslabs/flutter:stable AS flutter
WORKDIR /repo
COPY flutter ./flutter
WORKDIR /repo/flutter/example
# sk_icons.g.dart and the fonts are committed, so there is no generate step here.
RUN flutter pub get && flutter build web --release --base-href /flutter/

# ------------------------------------------------------------------ Next → build
FROM node:22-slim AS build
WORKDIR /repo

# The design system, matching the `files` allowlist in the root package.json.
COPY package.json index.js index.d.ts styles.css ./
COPY components ./components
COPY tokens ./tokens
COPY ui_kits ./ui_kits
COPY ds-shim.js theme-toggle.js index.html ./

COPY next/example/package.json next/example/package-lock.json ./next/example/
WORKDIR /repo/next/example
RUN npm ci --no-audit --no-fund
COPY next/example ./

# The plain-HTML and React previews are the repo's own files, served as-is. The
# tree shape is preserved because index.html reaches styles.css and the kits reach
# ../../ds-shim.js by relative path — flatten it and both break.
RUN mkdir -p public/preview && \
    cp -r /repo/index.html /repo/styles.css /repo/ds-shim.js /repo/theme-toggle.js public/preview/ && \
    cp -r /repo/tokens /repo/components /repo/ui_kits public/preview/

COPY --from=flutter /repo/flutter/example/build/web ./public/flutter

RUN npm run build

# -------------------------------------------------------------------- runtime
FROM node:22-slim AS run
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# Next's standalone output keeps the source tree's shape, and outputFileTracingRoot
# is the repo root — so the server lands at next/example/server.js, not server.js.
COPY --from=build /repo/next/example/.next/standalone ./
COPY --from=build /repo/next/example/.next/static ./next/example/.next/static
COPY --from=build /repo/next/example/public ./next/example/public

EXPOSE 3000
CMD ["node", "next/example/server.js"]

import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

/** @type {import('next').NextConfig} */
const nextConfig = {
  // The design system ships source rather than a build, so its .jsx has to be
  // compiled by the app. This is the only configuration a consumer adds.
  transpilePackages: ["@seakim/design-system"],

  // Self-contained server for the QA container.
  output: "standalone",

  // The app lives in a subdirectory while its dependency is the repo root
  // (`file:../..`). Without this, Next traces from next/example and the
  // standalone bundle silently omits the design system — the build succeeds and
  // the container 500s on first request.
  outputFileTracingRoot: resolve(dirname(fileURLToPath(import.meta.url)), "../.."),

  // Static files under public/ are served by exact path — there is no directory
  // index — so /flutter/ 308s to /flutter and then 404s. The Flutter build's
  // --base-href is /flutter/, so the assets beneath it already resolve; this only
  // fixes the entry point.
  async rewrites() {
    return [{ source: "/flutter", destination: "/flutter/index.html" }];
  },
};
export default nextConfig;

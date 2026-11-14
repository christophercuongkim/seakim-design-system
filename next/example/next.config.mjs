import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

/** @type {import('next').NextConfig} */
const nextConfig = {
  // The design system ships source rather than a build, so its .jsx has to be
  // compiled by the app. This is the only configuration a consumer adds.
  transpilePackages: ["@seakim/design-system"],

  // QA is a static site on GitHub Pages (VPS-29): `next build` writes out/.
  // trailingSlash makes each page a directory with an index.html, which is
  // what a static host serves for /next and what /flutter already is.
  output: "export",
  trailingSlash: true,

  // The app lives in a subdirectory while its dependency is the repo root
  // (`file:../..`), so tracing starts there.
  outputFileTracingRoot: resolve(dirname(fileURLToPath(import.meta.url)), "../.."),
};
export default nextConfig;

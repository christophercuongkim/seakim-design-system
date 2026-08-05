/** @type {import('next').NextConfig} */
// The design system ships source rather than a build, so its .jsx has to be
// compiled by the app. This is the only configuration a consumer adds.
const nextConfig = {
  transpilePackages: ["@seakim/design-system"],
};
export default nextConfig;

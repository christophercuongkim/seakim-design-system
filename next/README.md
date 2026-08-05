# SeaKim in Next.js

**Adapter over the React reference binding — conforms to SeaKim 1.0**

The React components are plain function components with no framework coupling, so
they work in Next as-is — but five things need handling, and four of them will bite
you silently rather than error. This folder holds the adapter files.

Copy them into your Next app, adjusting paths to wherever you install the design
system (as a workspace package, a git dependency, or vendored under `src/seakim`).

---

## 0. Install

Point at the GitHub URL and pin a ref — the same shape the Flutter binding uses,
with no registry and no publish step:

```bash
npm i git+ssh://git@github.com/christophercuongkim/seakim-design-system.git#v3.0.0
```

Always pin a tag. An unpinned git dependency resolves to whatever `main` holds at
install time, which is how two apps end up on different rules without either
noticing. `VERSION`, `package.json`, and the newest `CHANGELOG.md` heading all
carry the same number, and `npm run version:check` fails if they ever disagree.

```ts
// next.config.mjs — the one line a consumer adds. The package ships source, so
// its .jsx has to be compiled by the app.
const nextConfig = { transpilePackages: ["@seakim/design-system"] };
export default nextConfig;
```

```tsx
import { Button, Field, Input } from "@seakim/design-system";
import "@seakim/design-system/styles.css";   // root layout only — see 3
```

React is a peer dependency, so the app owns the version. The published surface is
about 580 KB: `components/`, `tokens/`, `styles.css`, `index.js`, `spec/`, and
`conformance.md`. The Flutter binding, the fonts, the slides, and the decision
records stay in the repo and are not installed.

`npm run conformance` and `npm run tokens:check` are exposed as scripts, so a
consuming repo can run the Tier 0 checks against its own source — which is what
[decision 0012](../decisions/0012-conformance-checks-ship-with-rules.md) asks of it.

**Working from a copy instead?** If the system is vendored into `src/seakim/`
rather than installed, import from `@/lib/seakim` and keep the aliases in
`tsconfig.paths.json`. That path still works; it re-exports the same barrel.

**A worked example lives in [`example/`](example/)** — a Server Component page
consuming the installed package, with `npm run build` as the thing that keeps
this document honest.

## 1. The client boundary — the one that errors

Every interactive SeaKim component calls `useState` (hover, press, and selected state
live inside the component). In the App Router everything is a Server Component by
default, so importing `Button` into `page.tsx` throws.

Rather than adding `"use client"` to all 23 component files — which would couple the
shared library to one framework — use a **client barrel**. A single file with the
directive marks everything it re-exports as client code:

```ts
// lib/seakim.ts
"use client";
export { Button } from "@/seakim/components/core/Button.jsx";
// …
```

Then import from the barrel, never from the component files:

```tsx
import { Button, Field, Input } from "@/lib/seakim";
```

`SkCard`-style pure display components (`Card` without `interactive`, `Badge`,
`Stat`, `Avatar`) have no state and could stay server-rendered, but splitting the
barrel in two costs more confusion than the handful of bytes it saves. Start with one
barrel; split later if bundle size actually shows up as a problem.

## 2. Fonts — swap the CSS import for `next/font`

`tokens/fonts.css` pulls the three families from `fonts.googleapis.com` with an
`@import`. That works, but in Next it is the wrong tool: it blocks render, adds a
third-party round trip, and gives you no size subsetting.

`app/fonts.ts` here replaces it with `next/font/google`, which self-hosts the files
at build time and emits zero layout shift. It assigns them to **the same three CSS
variables the system already uses**, so no component changes:

```ts
variable: "--font-display"  // Outfit
variable: "--font-sans"     // Plus Jakarta Sans
variable: "--font-mono"     // IBM Plex Mono
```

Then **comment out the `@import` line in `tokens/fonts.css`** (or import the token
files individually and skip that one), or you will download the fonts twice.

## 3. Global CSS goes in the root layout, and only there

Next only allows global stylesheets in `app/layout.tsx`. `styles.css` is a chain of
`@import` lines, which Next resolves at build time — but the paths are relative to
`styles.css`, so it has to keep its neighbours. Import the whole thing once:

```tsx
import "@/seakim/styles.css";
```

Do not import it in a component or a page; Next will refuse.

## 4. Theme without a flash or a hydration mismatch

Dark is the system default and is set statically in the layout, so a first-time
visitor sees no flash. The problem is a **returning** visitor who chose light: their
preference lives in `localStorage`, which the server cannot read, so the server sends
`data-theme="dark"` and the client corrects it after hydration — a visible flash, plus
a React hydration warning.

The fix is the standard one, and `app/layout.tsx` implements it:

1. A tiny **blocking inline script** in `<head>` reads `localStorage` and sets the
   attribute *before* first paint.
2. `suppressHydrationWarning` on `<html>`, because that attribute is now expected to
   differ between server and client markup.

This is the one place in the whole system where an inline script is the right answer.

## 5. Icons

The React `Icon` renders `<i className="ph ph-…">`, which needs the Phosphor webfont
CSS present. Install the package rather than hitting unpkg:

```bash
npm i @phosphor-icons/web
```

```tsx
// app/layout.tsx
import "@phosphor-icons/web/regular";
import "@phosphor-icons/web/bold";
import "@phosphor-icons/web/fill";
```

If you would rather have tree-shaken SVG components, `@phosphor-icons/react` is the
alternative — but it means rewriting `Icon.jsx` to map names to components, and you
lose the ability to pass an arbitrary icon name as a string prop. The webfont keeps
the API identical to the Flutter port, which is worth something.

---

## Things that need no adapter

- **`next/image`** — the kits use a labelled `Placeholder` component precisely so
  there is no invented imagery to migrate. Swap it for `next/image` when you have real
  photography; nothing else changes.
- **Server-side rendering of layout.** The responsive system measures container width
  with `ResizeObserver`, so the first server render has no width. `Viewport` falls back
  to `lg` until measured — see the note in `Frames.jsx`. If a `sm`-first flash on mobile
  matters to you, pass an explicit initial breakpoint from a user-agent hint.
- **`transpilePackages`** — only needed if you install the system as an npm package
  shipping raw `.jsx`. Vendored or workspace-linked, Next compiles it already.
- **Tailwind** — the system does not use it and does not conflict with it. If your app
  has Tailwind, add `preflight: false` or load `styles.css` after it, so Tailwind's
  reset does not undo the system's.

## Pages Router

Everything above applies except the client boundary: in `pages/` there are no Server
Components, so you can drop the barrel and import components directly. Global CSS goes
in `pages/_app.tsx`, and the no-flash script goes in `pages/_document.tsx`.

# Next.js example

Proof that a Next.js App Router app can consume SeaKim, and the record of what
that actually takes. Built against Next 15 / React 19.

```bash
npm install
npm run build     # what this example exists to keep passing
npm run dev
```

## What it proves

- **The client boundary works.** `app/page.tsx` is a **Server Component** and
  imports stateful components straight from `@/lib/seakim`. The barrel's single
  `"use client"` is enough; no component file needs its own.
- **The path-alias model works.** `src/seakim` and `src/lib` are symlinks to the
  design system, standing in for the copy or submodule `../README.md` describes.
  The aliases in `tsconfig.json` are exactly the ones in `../tsconfig.paths.json`.
- **The CSS and fonts resolve.** `styles.css` and its token `@import`s load from
  the root layout; the three families come from `next/font/google`.
- The page prerenders static — 111 kB first load for this set of components.

## The one thing worth knowing before you build a screen

**Components that take function props are only reachable from a Client
Component.** `Table` (`rowKey`, a column's `render`, `subLabel`), `Slider`
(`format`), and `DatePicker` (`isDisabled`) all take functions, and React Server
Components cannot pass a function across the client boundary.

The barrel's `"use client"` makes the *component* a Client Component. It does not
make the *caller's props* serialisable. So a table with custom cell rendering
needs a one-line wrapper — see `app/roster-table.tsx`, which exists solely to
demonstrate this.

Everything without function props — `Button`, `Card`, `Badge`, `Field`, `Input`,
`Stat`, `EmptyState` and the rest — renders straight from a Server Component.

## Not covered

No interaction, visual, or accessibility testing. This asserts that the system
compiles, type-checks, and prerenders in a real Next build — nothing about how it
looks or behaves once someone clicks it.

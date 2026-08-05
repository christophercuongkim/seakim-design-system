# SeaKim in Next.js

**The web binding. App Router and Pages Router, Next 15 / React 19.**

The components are plain function components with no framework coupling, so they work
in Next as-is. Five things need handling, and four of them bite silently rather than
error — each has a section below. A worked app that builds lives in
[`example/`](example/).

---

## Quickstart

Everything a new app needs, in order. Nothing else is required.

**1. Install** (see [private repo access](#private-repo-giving-ci-access) for CI)

```bash
npm i git+ssh://git@github.com/christophercuongkim/seakim-design-system.git#v3.0.1
npm i @phosphor-icons/web
```

**2. `next.config.mjs`** — the package ships source, so the app compiles its `.jsx`:

```js
const nextConfig = { transpilePackages: ["@seakim/design-system"] };
export default nextConfig;
```

**3. `app/fonts.ts`** — copy [`example/app/fonts.ts`](example/app/fonts.ts) verbatim.
It self-hosts the three families through `next/font/google` and assigns them to the
CSS variables the system already reads.

**4. `app/layout.tsx`** — copy [`example/app/layout.tsx`](example/app/layout.tsx). It
carries the global stylesheet, the font variables, the theme attributes, and the
no-flash script. Change `APP` to your product:

```tsx
const APP = "voyage";          // seakim · voyage · bench — sets the accent hue
const DEFAULT_THEME = "dark";  // dark · light
```

**5. Use it.** Import from the package root; there is no barrel to write.

```tsx
import { Button, Card, Badge, Field, Input, Stat } from "@seakim/design-system";

export default function Page() {
  return (
    <Card style={{ padding: "var(--space-5)" }}>
      <Stat label="Fare" value="412" unit="USD" delta="-18" />
      <Button variant="primary">Book trip</Button>
    </Card>
  );
}
```

That page is a **Server Component** and it works — the package's barrel carries the
only `"use client"` in the system. The one exception is below.

### The one exception: components taking function props

`Table` (`rowKey`, a column's `render`, `subLabel`), `Slider` (`format`), and
`DatePicker` (`isDisabled`) take **functions**, and a Server Component cannot pass a
function across the client boundary. The barrel makes the *component* a Client
Component; it does not make your *props* serialisable.

So reach those from a Client Component — a one-line wrapper, shown in
[`example/app/roster-table.tsx`](example/app/roster-table.tsx):

```tsx
"use client";
import { Table } from "@seakim/design-system";
export function RosterTable() { return <Table columns={cols} rows={rows} rowKey={r => r.id} />; }
```

Everything without function props renders straight from a Server Component.

### What you get

26 components — `Avatar` `Badge` `Button` `Card` `Checkbox` `DatePicker` `Dialog`
`EmptyState` `Field` `Icon` `IconButton` `Input` `Radio` `SegmentedControl` `Select`
`SideNav` `Slider` `Stat` `Switch` `TabBar` `Table` `Tabs` `Tag` `Textarea` `Toast`
`Tooltip` — plus `Viewport` and `useMeasuredBreakpoint` for container-width layout.

Every component ships a `.d.ts`, so props autocomplete. Usage notes per component are
in `components/*/<Name>.prompt.md`; the platform-neutral contracts are in `spec/`, and
the rules a binding must not break are in `conformance.md`.

Design tokens are CSS custom properties — `var(--space-5)`, `var(--text-primary)`,
`var(--surface-card)`. Read them rather than hard-coding values;
`node_modules/@seakim/design-system/tokens/` is the full list.

### Troubleshooting

| Symptom | Cause |
| --- | --- |
| `You're importing a component that needs useState` | Importing a component file directly instead of the package root. |
| `Functions cannot be passed directly to Client Components` | A function prop from a Server Component — see the exception above. |
| `TS7016: Could not find a declaration file` | Version older than 3.0.1. Upgrade. |
| Unstyled — no colour, wrong fonts | `styles.css` not imported in the **root layout**, or imported somewhere else. |
| Icons render as empty boxes | `@phosphor-icons/web` not installed, or its CSS not imported in the layout. |
| `TS2882` on a phosphor import | Importing the bare subpath. Use the `.css` path — see [Icons](#5-icons). |
| Wrong accent colour | `data-app` on `<html>` is missing or names an app that does not exist. |

---

## Install, in detail

Point at the GitHub URL and pin a ref — the same shape the Flutter binding uses,
with no registry and no publish step:

```bash
npm i git+ssh://git@github.com/christophercuongkim/seakim-design-system.git#v3.0.1
```

Always pin a tag. An unpinned git dependency resolves to whatever `main` holds at
install time, which is how two apps end up on different rules without either
noticing. `VERSION`, `package.json`, and the newest `CHANGELOG.md` heading all
carry the same number, and `npm run version:check` fails if they ever disagree.

### Private repo: giving CI access

The repo is private, so every install needs credentials. Locally that is a developer's
own SSH key and there is nothing to configure. CI is the part that needs setting up.

**The detail that decides the recipe:** whatever you write in `package.json`, npm
resolves a git dependency to an **ssh** URL and a commit SHA in the lockfile:

```json
"resolved": "git+ssh://git@github.com/christophercuongkim/seakim-design-system.git#5921916…"
```

Good — the SHA makes `npm ci` reproducible even though the spec names a tag. But it means
CI must satisfy an **ssh** URL, no matter how the dependency was written. There are two
honest ways to do that.

**Option A — rewrite ssh to https with a token.** Nothing in the repo changes; git is told
to substitute the transport. Works anywhere, including build platforms with no ssh agent.

```yaml
# GitHub Actions
- name: Authenticate to the design system repo
  run: |
    git config --global url."https://x-access-token:${{ secrets.SEAKIM_TOKEN }}@github.com/".insteadOf "ssh://git@github.com/"
- run: npm ci
```

`SEAKIM_TOKEN` should be a **fine-grained** personal access token scoped to this one repo
with read-only Contents, or a GitHub App installation token. A classic `repo`-scoped PAT
also works and grants far more than needed.

On **Vercel or Netlify**, the same rewrite goes in the install command, with the token as
an environment variable:

```bash
git config --global url."https://x-access-token:$SEAKIM_TOKEN@github.com/".insteadOf "ssh://git@github.com/" && npm ci
```

**Option B — a deploy key.** Scoped to exactly one repo by construction, which is the
least privilege available, but needs an ssh agent so it does not suit every platform.

Add the public half under the design system repo's *Settings → Deploy keys* (read-only),
put the private half in the consuming repo's secrets, then:

```yaml
- uses: webfactory/ssh-agent@v0.9.0
  with:
    ssh-private-key: ${{ secrets.SEAKIM_DEPLOY_KEY }}
- run: npm ci
```

**Never put the token in the dependency URL.** A `https://user:token@github.com/…` spec in
`package.json` gets committed, and then copied into `package-lock.json`, and then into
every fork. The rewrite above keeps the credential in CI where it belongs.

> Verified here: the ssh install, the tag resolution, the lockfile pinning shown above,
> and that the `insteadOf` rewrite does redirect an ssh URL to https. Not verified: the
> credentials themselves — a real token and a real deploy key are the two things this repo
> cannot hold, so treat the first CI run as the test of those.

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

Every interactive component calls `useState` (hover, press, and selected state live
inside the component). In the App Router everything is a Server Component by default,
so importing a component *file* directly throws.

**The package solves this for you.** `index.js` is a client barrel: one `"use client"`
marking everything it re-exports, which is why no component file carries the directive
and the shared library stays framework-agnostic. Import from the package root and the
problem does not arise:

```tsx
import { Button, Field, Input } from "@seakim/design-system";   // fine, even in a Server Component
import { Button } from "@seakim/design-system/components/core/Button.jsx";  // throws
```

Pure display components (`Card` without `interactive`, `Badge`, `Stat`, `Avatar`) have
no state and could stay server-rendered, but splitting the barrel in two costs more
confusion than the handful of bytes it saves. Split later if bundle size actually shows
up as a problem.

**Vendoring instead of installing?** If the system is copied into `src/seakim/`,
`next/lib/seakim.ts` is the equivalent entry point — it re-exports the same barrel, so
there is still only one export list to keep current.

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
import "@phosphor-icons/web/regular/style.css";
import "@phosphor-icons/web/bold/style.css";
import "@phosphor-icons/web/fill/style.css";
```

Import the `.css` path, not the bare subpath. The package maps `./regular` to a
stylesheet but ships no type declarations, so `import "@phosphor-icons/web/regular"`
compiles and then fails type-check with `TS2882: Cannot find module or type
declarations for side-effect import`. Naming the file gives TypeScript an extension it
already understands.

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
- **`transpilePackages`** — required when installing the package, because it ships
  source rather than a build. Vendored or workspace-linked instead, Next compiles it
  already and the option is unnecessary.
- **Tailwind** — the system does not use it and does not conflict with it. If your app
  has Tailwind, add `preflight: false` or load `styles.css` after it, so Tailwind's
  reset does not undo the system's.

## Pages Router

Everything above applies except the client boundary: in `pages/` there are no Server
Components, so you can drop the barrel and import components directly. Global CSS goes
in `pages/_app.tsx`, and the no-flash script goes in `pages/_document.tsx`.

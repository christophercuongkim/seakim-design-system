# Changelog

Every notable change to SeaKim. Format follows [Keep a Changelog](https://keepachangelog.com);
versioning follows [decision 0011](decisions/0011-versioning.md).

**Two levels.** The number below is the **rules version** — `tokens/src/`, `spec/`,
`decisions/`, `conformance.md`, and the foundation guidelines. Each binding versions
itself and declares which rules version it targets, so a binding may legitimately lag.

| Bump | Means |
| --- | --- |
| Major | A Tier 0 rule changed, or a token was removed or renamed |
| Minor | A token, spec, component, or Tier 1 allowance was added |
| Patch | Wording, examples, or a regeneration with identical values |

ADRs say *why*. This says *what* and *when*.

---

## [1.0.0] — 2026-08-04

First versioned release. Everything below already existed; this is the point at which it
became something a second team could depend on.

### Rules

- **Eleven decisions accepted.** [0001](decisions/0001-platform-neutral-spec-layer.md)
  through [0011](decisions/0011-versioning.md) — the spec layer, no FAB, tables, date
  selection, first-class light mode, slider anatomy, DTCG token source, conformance tiers,
  bundled Phosphor font, contributed bindings, and this versioning scheme.
- **Conformance contract.** [`conformance.md`](conformance.md) — twelve Tier 0 rules no
  platform may adapt, seven Tier 1 concerns whose mechanism is the platform's business,
  and an inventory split mandatory / expected / on demand / forbidden.
- **Token source promoted to DTCG JSON.** `tokens/src/color.tokens.json` is now the
  single source of truth; `tool/build-tokens.mjs` emits the CSS, Dart, and TS. Verified
  name-for-name against the previous hand-written files — zero tokens lost or added.
  Per [0007](decisions/0007-token-source-format.md).
- **oklch gamut mapping centralised.** Chroma reduction rather than clipping, in one
  function instead of a rule each binding reimplements. Clipping shifts hue, which would
  break the promise that every app's ramp differs only in H.
- **Three specs written**: [Table](spec/Table.md), [Slider](spec/Slider.md),
  [DatePicker](spec/DatePicker.md). Platform-free, no code, per
  [0001](decisions/0001-platform-neutral-spec-layer.md).
- **Three guidelines added**: accessibility, layout, data visualisation. The a11y rules
  existed across four token files; they are now in one place.

### Tokens

- Added `--fill-disabled`, `--text-disabled`, `--border-disabled` in both themes.
  Disabled was previously `opacity: 0.4`, which survives dark and collapses in light —
  a disabled accent button fell well under 4.5:1 on white. Found by the light-mode audit
  that [0005](decisions/0005-light-mode-is-first-class.md) required.
- Added `--chart-1` through `--chart-6`: categorical series colours at fixed lightness
  and chroma, deliberately not derived from the app accent.
- Added `--bp-md` and `--bp-lg` as documentation of the breakpoints. Screens branch on
  measured container width, so these are read by code rather than by media queries.

### React binding

- 26 components across core, forms, feedback, navigation, and data.
- Added `Table`, `Slider`, `DatePicker` per their specs.
- Both UI kits rebuilt responsive: one layout per screen that reflows, measured by
  container width rather than viewport.
- Disabled state moved from opacity to tokens in `Button`, `IconButton`, `Tag`.
- Theme toggle added to every specimen card and guideline page, so "reviewed in both
  themes" is possible rather than aspirational.

### Flutter binding

- Full widget set mirroring React, on Flutter primitives rather than themed Material.
- Dropped the `phosphor_flutter` dependency for a bundled icon font, per
  [0009](decisions/0009-bundle-phosphor-icon-font.md) — the package subclasses `IconData`,
  which Flutter sealed in 3.27, while the token layer needs `Color.withValues` from 3.27.
- `SkTable` and the disabled tokens landed alongside their React counterparts.
- **Does not compile.** `tool/phosphor_codepoints.json` and four `.ttf` files are not in
  the repo; see [`TODO-manual.md`](TODO-manual.md).

### Next.js

- Adapter over the React binding: client barrel, `next/font` wiring, no-flash theme
  script, icon setup.

### Known gaps

Tracked in [`conformance.md`](conformance.md), not hidden:

- Flutter cannot build until the font artefacts land.
- No automated accessibility or contrast checking in either binding.
- No screen-reader pass has been done on either UI kit.
- Token pipeline phases 2 and 3 (dimension, typography and motion) not started.
- Bench still has three hand-rolled tables that predate the `Table` component.

---

## Keeping this file

Add to an `## [Unreleased]` section as you go, then rename it on release. A changelog
written retrospectively is an archaeology project — the detail that makes it useful is
exactly the detail nobody remembers a month later.

Link the ADR for anything that stems from one. A change with no decision and no obvious
cause is a change nobody will be able to explain later.

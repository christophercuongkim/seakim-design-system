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

## [3.2.0] — 2026-08-08

### Added

- **`Range`** — a distribution/interval glyph, per
  [0017](decisions/0017-distribution-interval-glyph.md). An achromatic band from `low` to
  `high` with a marker at `mid`, on a shared `domain` so a column of them compares on one
  scale. Fills the gap between identity (which series) and magnitude (more vs less): *a
  value and its spread*. Achromatic because it repeats down rows — one instance promotes to
  `--fill-accent` on hover/focus (never a selected row). **Both bindings**:
  `components/data/Range.jsx` and `flutter/lib/src/widgets/sk_range.dart`, against
  `spec/Range.md`; added to the Tier 2 on-demand inventory. First consumer: fantasy-hub's
  projection floor/expected/ceiling.

## [3.1.0] — 2026-08-05

### Added

- **Sequential chart ramp** — `--chart-seq-1..4` plus `--chart-seq-ink-flip`, per
  [0015](decisions/0015-sequential-chart-ramp.md). Fixed hue 265, product-independent, with
  separately validated light and dark steps. Fills the magnitude gap the categorical ramp
  cannot cover: heatmaps, rank grids, choropleths.

  Four steps rather than the five originally proposed. At five, adjacent contrast compresses
  to roughly 1.3:1 — below what a cell boundary carries without a border. **Cell borders are
  required either way**, since `--chart-seq-1` sits 1.23:1 from a white card.

- **Achromatic trajectory set** for more than six series over time, per
  [0016](decisions/0016-many-series-trajectories.md). A fourth sanctioned >6 treatment,
  scoped to change-over-time, where "other" would erase the entities and small multiples
  would break the crossings that carry the meaning.

  Range stated rather than left to judgement: **8–15 trajectories.** Above 15, grey strokes
  stop resolving as separate paths and end-labels collide. An adjacent sequential grid is
  mandatory — it is the only path for touch and screen readers, so it is the view that has to
  be right.

### Fixed

- Regenerated `flutter/lib/src/tokens/palette.g.dart` and `tokens/generated/colors.ts`,
  which were missing. `sk_colors.dart` imports the former, so the Flutter binding had a
  broken import. Both are outputs of `tool/build-tokens.mjs` and were rebuilt from
  `tokens/src/color.tokens.json` — which is the point of
  [0007](decisions/0007-token-source-format.md): a lost output is a rebuild, not a loss.

### Note on the number

Written as 2.2.0 and filed below 3.0.1, which was a branch from the 2.1.0 lineage — 3.0.0
and 3.0.1 already existed above it. Renumbered to 3.1.0 and moved to the top: this adds
tokens and changes no Tier 0 rule, so it is a minor bump on the current version rather
than a second history.

---

## [3.0.1] — 2026-08-05

### Fixed

- **The package was unusable from TypeScript.** A new app installing the tag and
  importing under `strict` failed with `TS7016: Could not find a declaration file for
  module '@seakim/design-system'`. Every component carried a `.d.ts`; the barrel that
  re-exports them did not, and `package.json` declared no `types`. Adds `index.d.ts`,
  wires `types` into the exports map, and writes the one declaration missing entirely —
  `ui_kits/shared/Frames.d.ts`.

  `next/example` had not caught it: it installs by `file:` path, which resolves types
  differently from a git install. Only a throwaway app consuming the published tag
  reproduced it.

### Note on the number

This is the case [3.0.0](#300--2026-08-05)'s closing note anticipated, and it arrived
immediately: a web-binding packaging fix with no rules change. Released as a patch so the
one number stays true everywhere, at the cost of implying a rules release that did not
happen. If this recurs, decouple the package version from the rules version as
[0011](decisions/0011-versioning.md) actually allows.

`v3.0.0` was left pointing where it pointed. Re-tagging a published version would change
what an app pinning it resolves to, silently.

---

## [3.0.0] — 2026-08-05

### Changed — BREAKING

- **Alpha variants are tokens.** [0013](decisions/0013-alpha-variants-are-tokens.md) — a
  component may no longer compose alpha onto a colour; it reads a token that carries it.
  Enforced by a new `composed-alpha` Tier 0 rule covering both shapes: Dart's
  `.withValues(alpha:)` / `.withOpacity()` and CSS's `rgb(var(--…) / …)`.

  Major per [0011](decisions/0011-versioning.md): a Tier 0 rule changed. The rule had
  previously bound CSS and not Dart, purely because nothing looked at Dart — so this is
  as much a correction as an addition.

  **Migration:** replace an inline alpha with a token. `SkColors.fillAccentSelection`
  covers the selection wash. The subtle badge border now reads `--border-subtle`, which
  is what the React binding had always used — the two bindings had rendered that border
  differently for as long as both existed.

- **`disabled-opacity` widened to catch the inverse phrasing.** It only fired on lines
  containing "disabled" or "off", so `opacity: enabled ? 1 : 0.5` read straight past it.
  `SkInput`, `SkTextarea` and `SkSelect` had been violating it invisibly.

### Added

- `--on-success`, `--on-warning`, `--on-info` — foreground on a solid status fill. Like
  `--on-accent`, they do not flip with the theme, because the status 500 steps are bright
  in both. `Badge`'s solid tones had been reaching for raw ramp steps for want of them.
- `--shadow-rgb` — the shadow cast as a token, so a theme retunes it in one place and no
  component ships a literal.
- `SkColors.fillAccentSelection`.
- [0012](decisions/0012-conformance-checks-ship-with-rules.md) and
  [0014](decisions/0014-text-selection-tier-1.md), neither previously released.
- **The repo is an installable package.** Root `package.json` with an exports map, so a
  web app consumes it by git ref exactly as a Flutter app already did. `index.js` is the
  single client barrel; `next/lib/seakim.ts` re-exports it rather than keeping a second
  list. Published surface is about 580 KB — the Flutter binding, fonts, and slides stay
  in the repo.
- Worked examples that build: `next/example` (Server Component page, `next build`) and
  `flutter/example` (Material coverage gallery). CI runs the token check, conformance,
  and both Flutter packages.

### Fixed

- **The token generator had lost its chart stage.** `tokens/src/` defined a chart group
  the emitters never read, so regenerating silently deleted `--chart-1`–`6` and
  `SkChartPalette`, and `--check` would have pressured the next person into making that
  deletion permanent.
- **`tokens/src/` disagreed with its own outputs about the house hue** — it still said
  `clay: 55` while every generated file said `brick: 8`, and the generator still emitted
  `var(--hue-clay)`. Regenerating would have reverted the accent from crimson to orange.
  Neither release that changed it had updated the source.
- `Table`, `DatePicker` and `Slider` were absent from the Next barrel, so a Next app
  could not import them at all.
- Three widgets in the Flutter binding could not compile (missing imports), and `SkApp`
  never provided a `Directionality`, crashing any app that did not wrap itself in a
  `WidgetsApp`.
- `decisions/README.md` had drifted from the filesystem: the index stopped at 0009, that
  link pointed at a filename that does not exist, and the count still said nine.

### Note on the number

The npm package version tracks the rules version rather than moving independently. That
is a simplification, not something [0011](decisions/0011-versioning.md) requires — it
says each binding versions itself. Revisit if the web binding ever needs to ship a fix
without a rules change.

---

## [2.1.0] — 2026-08-05

### Changed

- **`--hue-brick` revalued 15 → 8**, blue-shifting the house accent toward crimson. Reads
  crimson at steps 500–700 (`#d1647c`, `#b64b65`, `#8d364b`); the 400 step stays lighter
  than true crimson — see the note below. Separation from the danger ramp improves from 10
  degrees to 17.

  **A gap in [0011](decisions/0011-versioning.md):** its bump table covers adding,
  removing, and renaming a token, but not *revaluing* one. Treated as minor here — the token
  and its name are unchanged, so nothing breaks, but every surface using it visibly shifts,
  which is more than a patch. Worth folding into 0011's successor rather than leaving to
  judgement each time.

---

## [2.0.0] — 2026-08-05

### Changed — BREAKING

- **The house accent is red, not orange.** `--hue-clay` (55) is renamed `--hue-brick` and
  revalued to 15. Affects `data-app="seakim"` and `data-app="house"` only — decks and
  cross-product surfaces. Voyage and Bench are untouched.

  Major per [0011](decisions/0011-versioning.md): a token was renamed. The rule exists so a
  contributed binding you cannot see is forced to look, and it applies to the author who
  wrote it.

  Hue 15 rather than a truer 25: the danger ramp sits at 25, and the house accent coexists
  with status colours on the same screen. Ten degrees of separation is thin — see the note
  below. Verified against both contrast gates: `400` on `--stone-950` is 7.30, `600` on
  `--stone-50` is 4.73.

  **Migration:** any binding referencing `SkBrandRamps.clay` or `--hue-clay` renames it.
  Nothing else moves; the ramp shape and every semantic token are unchanged.

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

# SeaKim Design System

**SeaKim rules 8.0 (Quiet)** · see [`CHANGELOG.md`](CHANGELOG.md) and
[decision 0011](decisions/0011-versioning.md)

A multi-product design system for the SeaKim family of apps. One warm-neutral
chassis shared by every product; exactly **one accent hue live at a time**.

**The product of this repo is the rules, not any one implementation.** The decisions,
specs, tokens, and conformance tiers are platform-free by design; React and Flutter are
*reference bindings* that prove the rules are implementable and give a new author
something to read. If a binding and a spec disagree, the spec wins and the binding is the
bug.

A team that needs SeaKim on a platform nobody has built yet — SwiftUI, Kotlin Compose,
anything — **owns that binding and builds it**, against
[`conformance.md`](conformance.md), then contributes it back so the next team inherits
it. See [`CONTRIBUTING-A-BINDING.md`](CONTRIBUTING-A-BINDING.md) and
[decision 0010](decisions/0010-bindings-are-contributed-not-owned.md).

## Context

SeaKim is building a portfolio of consumer apps.

| App | What it is | Surfaces | Accent |
| --- | --- | --- | --- |
| **Voyage** | Travel planning and booking | Responsive web + mobile | Sea `--hue-sea` (245) |
| **Bench** | Fantasy sport | Responsive web + mobile | Turf `--hue-turf` (145) |
| _next_ | reserved | — | Plum `--hue-plum` (320) |

Internal slide decks are a third surface and share the same tokens.

### Who actually consumes this

`ui_kits/voyage` and `ui_kits/bench` in this repo are **demo kits** — they exist to prove
the rules reflow, not to ship. The real consumers are separate repositories, and none of
them is visible to any gate here:

| Repo | Consumes via | Accent | Rules version | Last synced |
| --- | --- | --- | --- | --- |
| [`fantasy-hub`](https://github.com/christophercuongkim/fantasy-hub) | vendored copy, `web/vendor/seakim/` | `data-app="bench"` | **3.2.0** | 2026-08-07 |
| [`juntio`](https://github.com/juntio/juntio) | `seakim_flutter` git dep pinned at `ref: 1cc352d`, plus a docs mirror | — | **4.2.0** | 2026-08-26 |
| [`job-search`](https://github.com/christophercuongkim/job-search) | vendored copy, `web/vendor/seakim/` | `data-app="job-search"` | **7.0.0** — current | 2026-09-11 |

Four things this table is here to stop anyone assuming:

1. **"Nothing ships, so anything can be renegotiated cheaply"** — the Sources note below
   says that about the *values*, and it was true when written. It is not true of the
   *rules*. `job-search` re-vendored 7.0.0 the morning after it landed and took the radius
   ladder, the typeface swap and the concentric-corner clause in one go; nobody has looked
   at whether it still renders.
2. **A vendored copy does not say what version it is.** Neither carries a `VERSION` file or
   a `CHANGELOG`, and the `Rules version` header inside `conformance.md` goes stale — this
   repo's own header sat at 4.1 while `VERSION` said 4.3, and `fantasy-hub`'s vendored copy
   still reads **1.0** while actually carrying rules **3.2.0** (its decisions folder stops
   at 0017, and the commit that vendored it says so). The only reliable version signal is
   the consumer's own commit message.
3. **Nothing audits them.** `tool/version-check.mjs` audits only the bindings in its own
   `BINDINGS` array, which is `flutter/pubspec.yaml`. A vendored copy declares no
   `seakim_rules` and is invisible, so the lag in this table had to be measured by hand.
4. **`job-search` runs a hue this system does not define.** It declares
   `[data-app="job-search"]` locally at hue 265 and hand-writes the whole `--brand-*` ramp
   in its own `globals.css`, because the system reserves only brick, sea, turf and plum.
   That is a fourth product answering to no slot, and it survived the 7.0.0 re-vendor
   intact — the conformance checker shipped for consumers to run (0012) would flag those
   literals if it were run there.

### Sources

**None.** This system was authored from scratch in conversation — there was no
codebase, Figma file, screenshot set, or brand kit to read. Every value here is a
decision, not a recording, so anything can be renegotiated cheaply. When real
product code or Figma files exist, re-run against them and let the source win.

Decisions taken from the user directly:

- Vibe: Swiss-clean baseline, warm and human in tone. Quiet since [0033](decisions/0033-quiet.md): chrome recedes, features stay
- Palette: warm neutral core (achromatic), one accent per app
- Mode: light and dark; **light is the default** (0033 flipped it; dark is a peer, never derived)
- Type: one geometric sans across every role (0031 superseded the original three-family split; the original brief said "clean and wide")
- Density: 7/10 in spacing; type is 14px UI / 16px body at weight 500 (adopted at the M1 checkpoint)
- Corners: a closed seven-rung ladder, assigned by role (0035 moved controls to `lg` and cards to `xl`, and pruned `md` and `2xl`) (0030 superseded the original "sharp (0px)"; `none` is still the answer for dividers, table cells and full-bleed media)
- Motion: quiet — ease-out only, at or under 150ms; nothing overshoots, nothing scales (0034)
- Surface separation: fills and gaps; hairlines are alpha and the exception (0037). Shadows only for things that overlay
- Icons: Phosphor

### No logo exists

No logo or brand mark was supplied and none has been invented. Wherever a mark
would sit, the system sets the wordmark **SeaKim** in Instrument Sans SemiBold at
`--tracking-tight`; each app sets its own name the same way. Supply real marks
and they drop in with no other change.

---

## The core idea

Most design systems break when the second product arrives, because the first
product's brand color got baked into every component. SeaKim inverts that: **the
shared layer is achromatic**, and each app binds exactly one hue.

```html
<html data-app="voyage">                <!-- light by default; data-theme="dark" opts in -->
```

Every accent ramp step (`--brand-050` → `--brand-900`) is generated from
`--hue-brand` in oklch, so lightness and chroma are identical across apps and
only H moves. Swap `data-app` and the whole product reskins; contrast ratios
hold. Components read `--fill-accent`, `--text-accent`, `--border-accent`,
`--surface-selected`, and `--on-accent` — never a raw ramp step. The primary action
reads `--fill-primary` / `--on-primary`, which are stone in both themes (0036): the
accent is identity and selection, not the loudest control.

---

## CONTENT FUNDAMENTALS

Full detail in [`guidelines/voice-and-tone.md`](guidelines/voice-and-tone.md). The essentials:

**Plain, warm, specific.** SeaKim products talk like a competent friend who
respects your time. Short sentences, concrete nouns, the user's own words.

- **Sentence case everywhere** — buttons, headings, menus, table headers, nav.
  Title Case is only for proper nouns. `Add leg`, not `Add Leg`.
- **Second person.** "Your roster." Never "my roster" or "the user's trips."
- **Verbs on buttons**, matching the outcome: `Book`, `Add leg`, `Trade player`,
  `Delete trip`. Never `OK`, never `Submit`.
- **No terminal punctuation** in labels, buttons, cells, or one-line tooltips.
  Full stops in body copy and multi-sentence help.
- **Numerals always** — `3 nights`, not `three nights`.
- **No emoji in product UI, ever.** Not in empty states, not in toasts, not in
  marketing. Team crests and country flags are *assets*, not emoji, and are fine.
- **No exclamation marks in system copy.** No "Oops!", no "Whoops, our bad."
- **Errors are three facts**: cause, consequence, next step. One sentence each.
  > Payment declined by your bank. The seats are held for 9 more minutes. → `Try another card`
- **No manufactured urgency.** Real scarcity only, with its source stated:
  `3 seats left at this fare`.
- **Money is exact and never buried**: `$412`, not `from $399*`.
- **Ranges use an en dash, no spaces**: `6:40–9:15am`, `$380–$460`.

Register shifts per app — Voyage is reassuring and logistical (the user is
spending real money while stressed); Bench is fast, dry, and opinionated
(`Start Okafor. 18.4 projected vs 11.2.`). Same voice, different tempo.

---

## VISUAL FOUNDATIONS

### Color

A warm achromatic **stone** ramp (`--stone-0` → `--stone-950`) carries every
surface, border, and text color. It is warm — near-blacks keep a trace of yellow
so the system reads as paper and graphite, never blue-grey.

- **Dark is a peer theme, opted into with `data-theme="dark"`.** `--surface-page: #0f0e0d`, never `#000`.
  Surfaces step up: page `#0f0e0d` → card `#181614` → raised `#211f1d` →
  overlay `#2b2a27`.
- **Light is the default and a peer**, not a filter of dark. The page is white and a
  card is a `--stone-100` tint on it (0037): a region is its fill, not its outline.
  Never derive one theme from the other algorithmically.
- **One accent per screen, and the primary action is ink (0036).** Accent marks links, focus, selection, the active nav
  item, the selected state, and data emphasis. Nothing else. If two things on a
  screen compete for a primary *action*, one of them is wrong; an identity fill may
  repeat (0026).
- **Status colors are not accents** and may coexist with the accent. Each has a
  `400` (dark-theme) and `500` (light-theme) tuning.
- A new hue enters the system only after clearing 4.5:1 on `--stone-950` *and*
  `--stone-50` at ramp step 400/600 respectively.
- **No gradients.** No mesh, no glow, no purple-blue washes. Flat fills only.
  The single exception is `--surface-scrim` behind a dialog.

### Type

One text family, plus mono for data (decision 0031):

- **Instrument Sans** — everything that is words. Display, headings, UI, body.
  UI text is 14px, body 16px, and every text role except data and eyebrow sits at
  weight 500 with `--tracking-ui` (−0.01em) inherited from `<body>`. Hierarchy is
  carried by size and colour, not by bold. Set the large end tight:
  `--tracking-tight` to `--tracking-tighter`.
- **JetBrains Mono** — data and eyebrows. Prices, times, confirmation codes,
  flight numbers, stat lines, and uppercase `--tracking-caps` eyebrow labels.

`--font-display` remains its own token, pointing at Instrument Sans. It is the slot
the wordmark and every `h1`–`h5` read, so a future display face is one edit rather
than a rewrite of four roles in both bindings.

Numbers in any column use `.tnum` (`font-variant-numeric: tabular-nums`). Prose
caps at 68ch.

### Responsive

**One layout per screen, three shapes.** There is no separate mobile build. Because
the system styles inline rather than with stylesheets, screens cannot use CSS media
queries — they branch on a **measured container width** supplied by `Viewport`
(`ui_kits/shared/Frames.jsx`). That is stricter than a media query: a screen dropped
into a narrow panel reflows exactly as it would on a phone.

| Breakpoint | Width | Shape |
| --- | --- | --- |
| `sm` | < 640 | One column, bottom tab bar, tappable rows, 44px targets |
| `md` | 640–1023 | Side nav collapses to icons, two columns where they help |
| `lg` | >= 1024 | Full chrome, dense tables, side rails |

Rules that hold across both apps:

- **Navigation swaps, it does not shrink** — side nav from md up, tab bar at sm.
- **Columns are dropped, not shrunk.** A table loses its widest columns before any
  type goes below 14px.
- **Rows change species.** A 6-column table row becomes a two-line tappable row at
  sm; hover-revealed actions become an inline trailing button.
- **Primary actions move to a sticky footer below lg**, where no rail exists to hold
  them.
- **Overlays change species too**: a centred panel at lg is a bottom sheet at sm.

### Spacing & layout

4px grid (with a 2px half-step for optical nudges only). Density 7/10 means
**compact controls, generous section gaps** — controls are 28/34/42px tall, but
sections separate by 32–48px. That contrast is what keeps a dense screen legible.

Fixed elements (`tokens/layout.css`): 52px top bar, 232px side nav (collapses to
56px), 44px sub-bar, 56px mobile tab bar. Mobile hit targets never drop below
44px regardless of density.

### Backgrounds

Flat color. No patterns, no textures, no noise, no illustration wallpaper.
**Photography appears only as content** — destination imagery in Voyage, crests
and player shots in Bench — never as decoration behind text. When a photo must
carry text, the text sits in a solid capsule, not a protection gradient.

Image treatment: warm, natural, faintly desaturated, unfiltered. No duotones, no
heavy grain, no grading toward the accent.

### Borders, cards & depth

**Fills and gaps define; a hairline is the exception, and it is alpha** (Tier 0
§0.16, [0037](decisions/0037-fills-define.md)).

- A region is its surface fill and the whitespace around it. Cards, panels and
  navigation carry no outline.
- A **hairline** is a 1px alpha border (`--border-subtle` on rows and dividers,
  `--border-default` on inputs and overlay edges, `--border-strong` on hover) used
  only where a gap cannot separate. Being alpha, one token composes on any surface
  in both themes.
- **Card recipe, entire:** `--surface-card` fill, `--radius-xl`, `--space-5` (16px)
  padding — `--space-4` when tight. No border; a selected card gets a `--border-accent`
  edge.
- **Shadow means "floating above the page."** Only menus, popovers, tooltips,
  dialogs, sheets, toasts, and drag ghosts get one. If it is in the layout, it
  has no shadow. This single rule is what keeps dense screens from turning to soup.
- `--shadow-raised` is the one concession: bars that scroll over content.
- **2px borders mean selected / focused / active**, never decoration.

### Corners

A closed seven-rung ladder ([0030](decisions/0030-corners-take-a-radius-ladder.md),
[0035](decisions/0035-rungs-reassigned.md)); a component takes the rung its role names,
never a value that looked right.

| Rung | Value | Use |
| --- | --- | --- |
| `none` | 0px | Dividers, table cells, full-bleed images, the page |
| `xs` | 2px | Tags, chips, inline marks |
| `sm` | 4px | Checkboxes, menu items |
| `lg` | 8px | Buttons, icon buttons, segmented control, inputs, selects, textareas |
| `xl` | 12px | Cards, panels, dialogs, sheets, popovers, menus |
| `full` | 999px | Count badges, toggle tracks, pills |
| `circle` | 50% | Avatars, dots |

A pill-shaped button is off-system. A concentric corner never rounds more than the
corner it sits in ([0032](decisions/0032-concentric-corners.md)).

### Transparency & blur

Two jobs only: the dialog scrim (`--surface-scrim`, warm black at 68% dark / 40%
light) and sticky bars over scrolling content (`--blur-overlay` plus an ~85%
surface fill). Never on cards, never on buttons, never for "glass."

### Motion

Quiet (0034). One curve, nothing overshoots, nothing scales.

- **Everything eases out** — `--ease-out` `cubic-bezier(.22,.9,.28,1)` is the only
  curve. Enters and toggles take `--dur-base` 120ms; exits `--dur-fast` 100ms, so
  leaving is always faster than arriving.
- **150ms is the ceiling** — `--dur-slow`, for sheets and layout shifts.
- **Never animate a value the user is reading.** Prices, scores, and times cut
  instantly; their containers may animate.
- `prefers-reduced-motion` collapses all durations to 0. The press tint is not motion
  and stays.

### Interaction states

| State | Treatment |
| --- | --- |
| Hover (solid) | `--fill-primary-hover` on the ink primary; `--fill-accent-hover` on an identity fill. No lift, no shadow. |
| Hover (outline/ghost) | `--surface-hover` fill appears; border goes to `--border-strong`. |
| Hover (card/row) | `--surface-hover`, an alpha tint that composes on any surface. No border appears. |
| Press | The control's active fill (`--fill-*-active`, `--surface-active`) at 80ms. No scale, no ripple, nothing moves (0034). |
| Focus | `--focus-ring`: 2px accent ring with a 2px canvas gap. Visible-only, never suppressed. |
| Selected | 2px accent border, or `--surface-selected` fill plus `--text-accent`. |
| Disabled | `--fill-disabled` / `--text-disabled` / `--border-disabled`, `cursor: not-allowed`. **Not an opacity pass** — blanket opacity survives dark and collapses in light, where everything fades toward white. |
| Loading | The label is replaced in place by a mono progress word; the control keeps its width. No spinners. |

Hover is a lightness shift, not a lift — nothing in the layout moves on hover,
because nothing in the layout has depth.

---

## ICONOGRAPHY

**Phosphor Icons**, loaded from CDN as a webfont. No icon assets were supplied,
so this is a substitution from a known-good CDN set rather than a copy of
anything — flagged as such. Chosen over Lucide because six weights ship in one
family, so a single dependency serves a dense Voyage dashboard and a playful
Bench mobile app.

```html
<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/regular/style.css">
<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/bold/style.css">
<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/fill/style.css">

<i class="ph ph-map-pin"></i>          <!-- regular: all UI -->
<i class="ph-fill ph-map-pin"></i>     <!-- fill: active nav item only -->
<i class="ph-bold ph-arrow-right"></i> <!-- bold: inside solid accent buttons -->
```

In React, always go through `<Icon name="map-pin" />` rather than raw `<i>`.

Rules:

- **Regular at 20px** is the UI default. 16px in dense rows and small controls,
  24px in mobile tab bars, 32px+ only in empty states.
- **`fill` marks "active"** — the current tab or nav item, a saved trip, a locked
  lineup. Nothing else.
- **`bold` at 14px and below**, and inside solid primary buttons — regular strokes
  thin out at small sizes and against a filled background.
- **`duotone` only in empty states and slides**, where an icon is doing decorative
  rather than functional work.
- **Never mix weights within a row or a nav.** One weight per group.
- Icons inherit `currentColor`. They are never accent-colored unless the text
  beside them is.
- **Icon-only controls always carry an `aria-label`** and a tooltip.
- **No emoji as icons. No unicode glyphs as icons. No hand-drawn SVG.** If
  Phosphor lacks a concept, compose it from two Phosphor glyphs or commission one.
- Crests, airline logos, and flags are **image assets**, not icons.

---

## How the documentation is layered

Three kinds of document, deliberately separated. See
[`decisions/0001`](decisions/0001-platform-neutral-spec-layer.md) for the reasoning.

| Layer | Answers | Edited? |
| --- | --- | --- |
| **This readme + `guidelines/`** | What the system looks like, at the foundation level | Yes, freely |
| **`decisions/`** | *Why* a contested call went the way it did | Never — append a successor instead |
| **`spec/`** | What one component *is*, platform-free | Yes, as the component evolves |
| **`components/*.prompt.md`, `flutter/`, `next/`** | How to *call* it in one binding | Yes, per binding |

A spec never contains code, and a binding usage doc never contains cross-platform
opinion. When those two mix, the opinion ends up living in three places and drifting in
two of them.

**Conformance** is defined in [`conformance.md`](conformance.md): Tier 0 rules that no
platform may adapt, Tier 1 rules whose mechanism is the platform's business, and the
component inventory split into mandatory, expected, on demand, and forbidden.

## Index

| Path | What's there |
| --- | --- |
| `styles.css` | Global entry point. `@import` lines only — consumers link this one file. |
| `tokens/src/*.tokens.json` | **Source of truth.** Hand-edited. Colour lives here in oklch. |
| `tool/build-tokens.mjs` | Emits the CSS, Dart, and TS from `tokens/src/`. `--check` fails on stale output. |
| `tokens/fonts.css` | The three families + the Google Fonts import. |
| `tokens/colors.css` | **Generated.** Hues, brand ramp, stone ramp, status ramps, dark semantic layer. |
| `tokens/theme-light.css` | **Generated.** The light peer, under `[data-theme="light"]`. |
| `tokens/apps.css` | **Generated.** `[data-app]` → `--hue-brand` bindings. |
| `tokens/typography.css` | Size scale, leading, tracking, weights, composed `--type-*` roles. |
| `tokens/spacing.css` | 4px scale, control heights, standard insets. |
| `tokens/radius.css` | Radius scale (and why it's mostly zero). |
| `tokens/depth.css` | Border widths, the shadow set, focus ring, blur. |
| `tokens/layout.css` | Containers, fixed chrome dimensions, z-index scale. |
| `tokens/motion.css` | Durations, the one easing, composed transitions. |
| `tokens/base.css` | Reset and element defaults. |
| `decisions/` | Numbered ADRs for contested or reversible calls. Append-only. |
| `spec/` | Platform-neutral component contracts. No code — see decision 0001. |
| `conformance.md` | What a binding must implement to call itself SeaKim. |
| `guidelines/accessibility.md` | Contrast, focus, targets, naming, structure, and the review pass. |
| `guidelines/layout.md` | The shell, page padding, content ceilings, and the four composition patterns. |
| `guidelines/data-visualisation.md` | Chart anatomy and the series-colour rules. |
| `guidelines/voice-and-tone.md` | The long-form copy guide. |
| `ds-shim.js` | Dev-only loader so cards and kits render before the bundle is compiled. Not part of the shipped system. |
| `guidelines/*.html` | Foundation specimen cards (Design System tab). |
| `components/core/` | Icon, Button, IconButton, Card, Badge, Tag, Avatar, Stat |
| `components/forms/` | Field, Input, Textarea, Select, Checkbox, Radio, Switch, SegmentedControl, Slider, DatePicker |
| `components/data/` | Table |
| `components/feedback/` | Dialog, Toast, Tooltip, EmptyState |
| `components/navigation/` | Tabs, SideNav, TabBar |
| `ui_kits/shared/` | Responsive plumbing both kits use: measured-container breakpoints, `Viewport`, status bar, screen header, kit bar |
| `ui_kits/voyage/` | Voyage — travel planning, one responsive build, 6 screens |
| `ui_kits/bench/` | Bench — fantasy sport, one responsive build, 4 screens |
| `slides/` | Deck slide types: title, section, agenda, numbers, comparison, quote |
| `VERSION` | The rules-layer version. One number, quoted by every binding. |
| `CHANGELOG.md` | What changed in the rules, and what to do about it. |
| `VERSION` | The rules version. One number for the platform-free layer. |
| `CHANGELOG.md` | What changed and when. ADRs say why; this says what. |
| `CONTRIBUTING-A-BINDING.md` | How to build SeaKim on a new platform. Start here for SwiftUI, Compose, Vue. |
| `next/` | Next.js adapter: client barrel, next/font wiring, no-flash theme script |
| `flutter/` | Flutter port: generated token layer, 24 custom widgets, breakpoint plumbing |
| `SKILL.md` | Agent-skill entry point for use outside this project |

### Intentional additions

No source defined an inventory, so the whole set is authored: the standard
primitive set, sized to what Voyage and Bench actually need. Beyond the standard
list, `Icon` (a wrapper over the Phosphor webfont), `Field` (label + hint + error
scaffold), `Stat` (a label/value/delta unit both apps need for fares and stat
lines), `SegmentedControl`, `Avatar`, and the three navigation shells are
included because both apps require them. Drop anything still unused after the
first real build.

## Adding an app

1. Pick one hue. Verify `oklch(0.72 0.13 H)` clears 4.5:1 on `--stone-950` and
   `oklch(0.56 0.14 H)` clears 4.5:1 on `--stone-50`.
2. Add `--hue-<name>` to `tokens/colors.css`.
3. Add the `[data-app="<name>"]` binding to `tokens/apps.css`.
4. Do not add app-specific components to the shared library. Build them in the
   app and promote once a second app needs them.

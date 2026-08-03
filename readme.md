# SeaKim Design System

A multi-product design system for the SeaKim family of apps. One warm-neutral
chassis shared by every product; exactly **one accent hue live at a time**.

## Context

SeaKim is building a portfolio of consumer apps. Two are in flight, more are planned:

| App | What it is | Surfaces | Accent |
| --- | --- | --- | --- |
| **Voyage** | Travel planning and booking | Responsive web + mobile | Sea `--hue-sea` (245) |
| **Bench** | Fantasy sport | Responsive web + mobile | Turf `--hue-turf` (145) |
| _next_ | reserved | — | Plum `--hue-plum` (320) |

Internal slide decks are a third surface and share the same tokens.

### Sources

**None.** This system was authored from scratch in conversation — there was no
codebase, Figma file, screenshot set, or brand kit to read. Every value here is a
decision, not a recording, so anything can be renegotiated cheaply. When real
product code or Figma files exist, re-run against them and let the source win.

Decisions taken from the user directly:

- Vibe: Swiss-clean baseline, warm and human in tone, playful in motion and accent
- Palette: warm neutral core (achromatic), one accent per app
- Mode: light and dark; **dark is the default**
- Type: geometric sans, clean and wide
- Density: 7/10
- Corners: sharp (0px)
- Motion: springy — slight overshoot on enter
- Surface separation: borders by default, shadows only for things that overlay
- Icons: Phosphor

### No logo exists

No logo or brand mark was supplied and none has been invented. Wherever a mark
would sit, the system sets the wordmark **SeaKim** in Outfit SemiBold at
`--tracking-tight`; each app sets its own name the same way. Supply real marks
and they drop in with no other change.

---

## The core idea

Most design systems break when the second product arrives, because the first
product's brand color got baked into every component. SeaKim inverts that: **the
shared layer is achromatic**, and each app binds exactly one hue.

```html
<html data-theme="dark" data-app="voyage">
```

Every accent ramp step (`--brand-050` → `--brand-900`) is generated from
`--hue-brand` in oklch, so lightness and chroma are identical across apps and
only H moves. Swap `data-app` and the whole product reskins; contrast ratios
hold. Components read `--fill-accent`, `--text-accent`, `--border-accent`,
`--surface-selected`, and `--on-accent` — never a raw ramp step.

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

- **Dark is the default theme.** `--surface-page: #0f0e0d`, never `#000`.
  Surfaces step up: page `#0f0e0d` → card `#181614` → raised `#211f1d` →
  overlay `#2b2a27`.
- **Light is a peer**, not a filter of dark. Its card is pure `#ffffff` on a
  `#faf9f7` page, so cards read *lighter* than the page — the inverse of dark
  mode's logic. Never derive one from the other algorithmically.
- **One accent per screen.** Accent marks the primary action, the active nav
  item, the selected state, and data emphasis. Nothing else. If two things on a
  screen are accent-colored, one of them is wrong.
- **Status colors are not accents** and may coexist with the accent. Each has a
  `400` (dark-theme) and `500` (light-theme) tuning.
- A new hue enters the system only after clearing 4.5:1 on `--stone-950` *and*
  `--stone-50` at ramp step 400/600 respectively.
- **No gradients.** No mesh, no glow, no purple-blue washes. Flat fills only.
  The single exception is `--surface-scrim` behind a dialog.

### Type

Three families, strictly divided by job:

- **Outfit** — display and headings. Wide, geometric, clean; earns its keep above
  17px. Set tight: `--tracking-tight` to `--tracking-tighter`.
- **Plus Jakarta Sans** — UI and body. Geometric skeleton with humanist
  apertures, so it stays legible at 13px where Outfit gets stiff.
- **IBM Plex Mono** — data and eyebrows. Prices, times, confirmation codes,
  flight numbers, stat lines, and uppercase `--tracking-caps` eyebrow labels.

Numbers in any column use `.tnum` (`font-variant-numeric: tabular-nums`). Prose
caps at 68ch. Never use Outfit below 17px; never use Plus Jakarta above 24px.

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
  type goes below 13px.
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

**Borders define, shadows lift.**

- Every in-flow surface is defined by a **1px hairline** (`--border-subtle` on
  quiet dividers, `--border-default` on controls). No shadow.
- **Card recipe, entire:** 1px `--border-subtle`, `--radius-none`,
  `--surface-card` fill, `--space-5` (16px) padding — `--space-4` when tight.
- **Shadow means "floating above the page."** Only menus, popovers, tooltips,
  dialogs, sheets, toasts, and drag ghosts get one. If it is in the layout, it
  has no shadow. This single rule is what keeps dense screens from turning to soup.
- `--shadow-raised` is the one concession: bars that scroll over content.
- **2px borders mean selected / focused / active**, never decoration.

### Corners

`0px` everywhere. `--radius-full` (999px) is reserved for count badges, filter
chips, and switch tracks; `--radius-circle` for avatars and status dots — shapes
that are *conceptually* round. A pill-shaped button is off-system. Do not
introduce a 4px radius.

### Transparency & blur

Two jobs only: the dialog scrim (`--surface-scrim`, warm black at 68% dark / 40%
light) and sticky bars over scrolling content (`--blur-overlay` plus an ~85%
surface fill). Never on cards, never on buttons, never for "glass."

### Motion

Springy, but disciplined.

- **Enters and toggles overshoot** — `--ease-spring` `cubic-bezier(.34,1.42,.5,1)`
  at `--dur-base` 200ms. Badges, knobs, and chips use the punchier `--ease-pop`.
- **Exits never overshoot** — `--ease-out` at `--dur-fast` 140ms. Leaving is
  always faster than arriving.
- **Never animate a value the user is reading.** Prices, scores, and times cut
  instantly; their containers may animate.
- Sheets slide 320ms; tab indicators spring; toasts pop in and fade out.
- `prefers-reduced-motion` collapses all durations to 0 and `--press-scale` to 1.

### Interaction states

| State | Treatment |
| --- | --- |
| Hover (solid) | Fill steps one ramp stop lighter in dark, darker in light. No lift, no shadow. |
| Hover (outline/ghost) | `--surface-hover` fill appears; border goes to `--border-strong`. |
| Hover (card/row) | Background steps to `--surface-hover`. Border unchanged. |
| Press | `scale(var(--press-scale))` = 0.97 at 80ms. Every clickable thing. |
| Focus | `--focus-ring`: 2px accent ring with a 2px canvas gap. Visible-only, never suppressed. |
| Selected | 2px accent border, or `--surface-selected` fill plus `--text-accent`. |
| Disabled | `opacity: 0.4`, `cursor: not-allowed`. No greyed-out repaint. |
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
- **`bold` at 14px and below**, and inside solid accent buttons — regular strokes
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

## Index

| Path | What's there |
| --- | --- |
| `styles.css` | Global entry point. `@import` lines only — consumers link this one file. |
| `tokens/fonts.css` | The three families + the Google Fonts import. |
| `tokens/colors.css` | Hues, brand ramp, stone ramp, status ramps, dark semantic layer. |
| `tokens/theme-light.css` | The light peer, under `[data-theme="light"]`. |
| `tokens/apps.css` | `[data-app]` → `--hue-brand` bindings. |
| `tokens/typography.css` | Size scale, leading, tracking, weights, composed `--type-*` roles. |
| `tokens/spacing.css` | 4px scale, control heights, standard insets. |
| `tokens/radius.css` | Radius scale (and why it's mostly zero). |
| `tokens/depth.css` | Border widths, the shadow set, focus ring, blur. |
| `tokens/layout.css` | Containers, fixed chrome dimensions, z-index scale. |
| `tokens/motion.css` | Durations, easings, composed transitions, press scale. |
| `tokens/base.css` | Reset and element defaults. |
| `guidelines/voice-and-tone.md` | The long-form copy guide. |
| `ds-shim.js` | Dev-only loader so cards and kits render before the bundle is compiled. Not part of the shipped system. |
| `guidelines/*.html` | Foundation specimen cards (Design System tab). |
| `components/core/` | Icon, Button, IconButton, Card, Badge, Tag, Avatar, Stat |
| `components/forms/` | Field, Input, Textarea, Select, Checkbox, Radio, Switch, SegmentedControl |
| `components/feedback/` | Dialog, Toast, Tooltip, EmptyState |
| `components/navigation/` | Tabs, SideNav, TabBar |
| `ui_kits/shared/` | Responsive plumbing both kits use: measured-container breakpoints, `Viewport`, status bar, screen header, kit bar |
| `ui_kits/voyage/` | Voyage — travel planning, one responsive build, 6 screens |
| `ui_kits/bench/` | Bench — fantasy sport, one responsive build, 4 screens |
| `slides/` | Deck slide types: title, section, agenda, numbers, comparison, quote |
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

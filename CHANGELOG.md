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

## [8.0.0] — unreleased

The Quiet revamp, per [0033](decisions/0033-quiet.md). Milestone 1 lands here one
change at a time; the entry is dated when 8.0.0 ships. Consumers on 7.x: nothing below
is additive.

### Changed

- **Light is the default theme; dark is opted into.** The generated CSS carries the light
  semantic layer at bare `:root` and the dark layer under `[data-theme="dark"]`; no token
  value changed. `SkApp` defaults to `SkThemeMode.light`. `ui_kits/` and `slides/` keep an
  explicit dark root.
- **Tier 0 §0.5 (press is a scale) is retired; §0.15 (press is a tint, and nothing
  overshoots) replaces it**, per [0034](decisions/0034-press-is-a-tint.md). Press feedback
  is the control's active fill. `--press-scale`, `--press-scale-lg`, `--ease-spring`,
  `--ease-pop` and `--transition-spring` are removed; `--transition-enter` is added.
  Durations are 80 / 100 / 120 / 150ms. Flutter: `SkPressable` no longer takes
  `pressScale` and no longer scales; `SkMotion.spring`, `.pop`, `.pressScale` and
  `.pressScaleLarge` are removed. Tappable cards, table rows and combobox options now
  tint on press.

- **Controls take `lg` (8), cards take `xl` (12); `md` (6) and `2xl` (16) are removed
  from the ladder**, per [0035](decisions/0035-rungs-reassigned.md). Buttons, icon
  buttons, segmented controls, inputs, selects, textareas and the combobox trigger move to
  `lg`; Card moves to `xl`; checkboxes and menu items stay `sm`; dialogs, popovers and menus
  stay `xl`. `--radius-md`, `--radius-2xl`, `SkRadius.md` and `SkRadius.xxl` no longer
  exist. A consumer that named them fails at build time, which is what a Major is for.

- **The primary action is ink**, per [0036](decisions/0036-ink-primary.md). Tier 0 §0.3
  keeps its number and gains a second half: `--fill-primary` / `--on-primary` (stone in
  both themes) are the primary button's fill; `--fill-accent` and `--on-accent` stay for
  identity and selection (checked marks, switch track, tab indicator, own-message
  bubbles). `SkColors` gains `fillPrimary`, `fillPrimaryHover`, `fillPrimaryActive`,
  `onPrimary`; Material's `ColorScheme.primary` maps to `fillPrimary`.

- **Tier 0 §0.2 (borders define) is retired; §0.16 (fills and gaps define; a hairline is
  the exception, and it is alpha) replaces it**, per [0037](decisions/0037-fills-define.md).
  Light surfaces invert: page `stone-0`, card `stone-100`, sunken and inset `stone-200`;
  raised and overlay stay white. Hairlines (`--border-subtle` / `-default` / `-strong`) are
  now alpha in both themes (light: ink 8 / 14 / 24%; dark: white 10 / 16 / 26%), and so are
  `--surface-hover` and `--surface-active` (light 6 / 12%, dark 8 / 14%). Card and SkCard
  drop their outline; `SkCard.borderless` is removed. Other components lose their
  hairlines in the M2 component pass.

- **Type: 14px UI, 16px body, weight 500 throughout, UI tracking −0.01em** (CHR-188 trial,
  adopted at the M1 checkpoint). `--text-sm` 13 → 14, `--text-md` 15 → 16; every composed
  `--type-*` role except data and eyebrow is `--weight-medium`; `--tracking-ui` is applied on
  `<body>` in `tokens/base.css`. `SkFontSize.sm` / `.md` and every `SkText` role follow.
  The 12-step scale and 0031 are unchanged; this is a revalue.

- **Navigation surfaces are fills (M2).** SideNav loses its right border and the header
  and footer hairlines; the active item's accent edge is a border, not an inset shadow.
  Tabs' indicator height names `--border-emphasis`. Active nav and tab labels are weight
  500 like everything else; the accent colour and fill carry the state.

- **Data surfaces are fills (M2).** Table loses its container outline (rows keep their
  hairlines); the selected row's accent edge and the DatePicker's today underline are
  borders, not inset shadows; Slider rail and Range track are `--surface-inset` fills with
  no outline; Slider ticks name `--border-hairline`.

- **Chips, badges, segmented control and empty state are fills (M2).** Tag rests on
  `--fill-neutral` with no outline (the selected chip keeps its accent edge); subtle Badge
  loses its hairline; SegmentedControl is a `--surface-sunken` well whose selected segment
  is a raised `--surface-raised` fill, no outer border, no dividers; EmptyState is a
  `--surface-sunken` fill with no dashed outline (the Flutter dash painter is deleted).

- **Rings and edges are borders (M2).** Avatar's hairline ring and status-dot gap ring,
  AvatarStack's separator ring, and Radio's on/off widths name `--border-hairline` /
  `--border-emphasis` (`SkDepth.hairline` / `.emphasis`) as borders or outlines; no inset
  or spread-only box-shadow stands in for a border anywhere in `components/`.

- **Skeleton's `radius` names a rung (M2).** React takes a rung name (`none | xs | sm |
  lg | xl | full | circle`); Flutter takes an `SkRadius` constant. A placeholder cannot
  render an off-ladder corner, and `untokenised-radius` now flags any radius fed through
  a variable (`BorderRadius.circular(x)`, `borderRadius: x`) that is not a named rung.

- **Overlays enter without scale (M2).** SkDialog drops its 0.97 → 1 `ScaleTransition`;
  the React Toast keyframe rises and fades only. The Checkbox mark keeps its settle-in:
  state feedback, not a press or an enter. The motion specimen no longer demonstrates an
  overshoot curve.

### Added

- The `inset-shadow-border` line rule in `tool/conformance-check.mjs`: an inset or
  spread-only box-shadow (or a `BoxShadow` with `spreadRadius`) outside the depth tokens
  fails as a border in disguise.
- The `alpha-hairline` gate in `tool/conformance-check.mjs`, which reads the resolved
  border roles in both themes and `SkColors` and fails on an opaque one.
- `--fill-primary`, `--fill-primary-hover`, `--fill-primary-active`, `--on-primary`, and
  the `ink-primary` gate in `tool/conformance-check.mjs`, which resolves the primary fill
  in both themes and both bindings and fails on hue.
- `tool/conformance-check.mjs` gains the `press-transform` line rule and the
  `overshoot-easing` value gate, which reads both bindings' motion token values.

## [7.0.1] — 2026-09-11

### Fixed

- **`Skeleton` and `LoadingState` are now declared in `index.d.ts`.** Both shipped with
  0021, were registered in `ds-shim.js` and the preview manifest, were demoed and rendered
  green — and were unreachable from a TypeScript consumer under `strict`, because the barrel
  whose entire job is to keep the typed surface equal to the runtime surface had never heard
  of them. The rule that cannot be satisfied without them (Tier 0 §0.13, no spinners) was
  therefore unsatisfiable in any typed binding. Found from a consuming app, which is
  [lesson 4](docs/lessons.md) happening a second time one level in.
- **`tool/preview-check.mjs` now asserts barrel parity** — every name exported from
  `index.js` must also be exported from `index.d.ts`. Per [0012](decisions/0012-conformance-checks-ship-with-rules.md),
  the drift and its check move together; this one is unambiguous, so it fails rather than warns.

No rules changed and no runtime behaviour changed: this is the React binding's public
surface being declared as what it already was.

## [7.0.0] — 2026-09-10

### Added

- **Tier 0 §0.14 — a concentric corner never rounds more than the corner it sits in**,
  per [0032](decisions/0032-concentric-corners.md), extending 0030. When a child's corner
  is flush with its parent's or inset by less than one space rung, the child's rung never
  exceeds the parent's; prefer `parent − inset`, snapped down a rung.

  A child that does **not** sit in the parent's corner takes its own role's rung. That
  clause is what keeps this from becoming the rule it resembles: `Toast` and `EmptyState`
  are `none` and both hold a `md` Button, which is correct and ordinary — the naive "a
  child never rounds more than its parent" would have made both a violation and pushed
  toasts to invent a rung they do not need.

  **Nothing in either binding changes.** Every current pairing already complies; this
  records a rule the system was keeping by accident. It is Major because Tier 0 gains an
  obligation, so a contributed binding never reviewed against it may now be
  non-conformant even though nothing here moved.
- Machine coverage is now six of **fourteen**. §0.14 is judgement — concentricity depends
  on render-time layout, which a line-based checker cannot see — and joins the manual list.



### Added

- **Tier 0 clauses are numbered §0.1–§0.13**, and the numbers are a contract: a removed
  clause has its number **retired, never reused**, the same discipline the decision records
  follow. Renumbering would silently invalidate every citation written before it. Review
  can now say "this fails §0.4" instead of quoting the bullet.
- **The checker prints the clause it enforces** — `TIER 0  §0.1  untokenised-radius` — so a
  violation names the law rather than only the rule id. Each rule carries a `clause` field;
  `contrast-floor` and `radius-ladder-drift` carry theirs inline.
- **Coverage is now stated rather than implied.** Six of the thirteen are machine-checked
  (§0.1, §0.4, §0.6, §0.7, §0.8, §0.13). The other seven are judgement and stay manual by
  design, per [0012](decisions/0012-conformance-checks-ship-with-rules.md). A green gate
  means the six held, not that the thirteen were obeyed.



### Added

- **`--stone-450` (`#8e8a84`) and `--stone-550` (`#6c6964`)**, and `SkStone.s450` /
  `s550`. They exist for one reason: **no single grey clears 4.5:1 against both a
  near-black card and a white one.** The window is arithmetically empty — a colour needs
  relative luminance ≥ 0.209 to clear the floor on `--stone-900`, and ≤ 0.183 to clear it
  on white. So the third text tier has to split by theme, and 400/600 were already spoken
  for by `--text-secondary`.

### Fixed

- **`--text-tertiary` was under the contrast floor in every app, in both themes** —
  4.12:1 on the dark card and 4.38:1 on the light one, from a single `--stone-500` binding.
  It is 165 call sites across both bindings, so collapsing it into `--text-secondary` would
  have cost a real tier. It now resolves to `--stone-450` in dark (5.26:1 card, 5.62:1
  page) and `--stone-550` in light (5.47:1 card, 5.19:1 page). `SkColors` moves with it.
- The pair is now **gated** in `contrast-floor` rather than reported, on both card and
  page. It was the only entry the gate printed and did not enforce.



### Fixed

- **Two shipped accent hues were under the contrast floor in light mode.**
  `guidelines/accessibility.md` stated the admission test for a new hue — 4.5:1 at
  `oklch(0.56 0.14 H)` on `--stone-50` — and nothing had ever computed it. Sea scored
  4.39:1 and turf 4.17:1; Voyage and Bench are the two apps in flight. `--text-accent` and
  `--text-link` resolved to `--brand-600` in light, giving Bench **4.38:1** on card and
  Voyage 4.62:1 with no headroom. Both now resolve to **`--brand-700`**, which clears
  6.7:1 for every hue. Fixed in both bindings — `tokens/theme-light.css` and
  `SkColors.light`, which named `brand.s600` and would otherwise have diverged.
- The guideline's admission criterion now names `oklch(0.46 0.12 H)` — the step
  `--text-accent` actually resolves to — and records why the old one was wrong.

### Added

- **`contrast-floor`** gate. Resolves the semantic pairs for real — every app, both
  themes, `var()` chains and oklch included — and measures them against
  `guidelines/accessibility.md`. This is the gate [0019](decisions/0019-versioning-second-pass.md)
  already pointed at when it made "a revalue that fails a documented contrast gate" Major;
  until now there was nothing behind that clause. `--text-tertiary` sits at 4.12:1 / 4.38:1
  and is **reported, not failed** — whether metadata is body text or decorative is a
  judgement the guideline does not settle.
- **`accent-text-step-parity`** — the light accent text step is hand-mapped in both
  bindings and drifted once already; CSS and Dart must now name the same rung.
- `tool/oklch.mjs` — the oklch→sRGB transform, previously private to
  `build-tokens.mjs`, extracted so the contrast gate uses the same maths rather than a
  second implementation. Generated outputs verified byte-identical across the move.
- Lesson 18: a uniform perceptual ladder is not a uniform contrast ladder.



### Added

- **A Tier 1 row for type delivery.** [0031](decisions/0031-one-typeface.md) noted that no
  rule named a typeface at any tier — icons were pinned, type never was, so a binding could
  ship any face and pass every gate. Fixed intent is the family set and that components
  read `--font-*` / `SkFonts`; free to differ is delivery — CDN, self-hosted webfont or a
  bundled binary, static cuts or a variable file.
- **`literal-font-family`** conformance rule, so the row is enforced rather than merely
  written down. It flags a quoted family name in component code and passes anything that
  resolves a token, including Dart's `'packages/$skFontPackage/${SkFonts.sans}'` — which
  `ThemeData.fontFamily` requires, because it takes no package argument.



### Changed

- **One text family** — [0031](decisions/0031-one-typeface.md). Outfit, Plus Jakarta Sans
  and IBM Plex Mono are replaced by **Instrument Sans** for every word in the system and
  **JetBrains Mono** for data. Hierarchy is now carried by size and weight, never by a
  change of face. The twelve-step size scale is **unchanged** — this moves the faces only.
- **`--font-display` is kept as a named slot**, pointing at Instrument Sans rather than
  being deleted or aliased away. It is what the wordmark, every `h1`–`h5`, the nav rail
  and the deck chrome read, so a future display face or a real logotype is one edit
  instead of a four-role rewrite in both bindings. `SkFonts.display` mirrors it.
- **Flutter bundles variable fonts** — one `.ttf` per family (381 KB) in place of ten
  static cuts (~1.1 MB). Every `SkText` style gained `fontVariations` alongside
  `fontWeight`, because the `wght` axis is what moves on a variable font; `fontWeight`
  alone risks a synthesised bold instead of the real cut.
- **The wordmark loses its distinct letterform.** `readme.md`'s founding line "Type:
  geometric sans, clean and wide" is superseded, and the wordmark rule now names
  Instrument Sans SemiBold. Identity rests on hue until a real mark exists; the retained
  slot is what keeps that reversible.

### Fixed

- **`conformance.md` claimed the text font binaries were not committed.** They have been
  tracked in `flutter/assets/fonts/` for some time. The note now says what is true: the
  two text faces ship with the package, and only the four Phosphor icon `.ttf` files are
  still absent from a fresh clone.

## [5.0.0] — 2026-09-10

### Changed

- **Corners take a radius ladder** — [0030](decisions/0030-corners-take-a-radius-ladder.md)
  (now **Accepted**), superseding the square-corners rule. Tier 0 no longer says "0px on
  everything that contains content"; it says **every corner names a rung of a closed
  ladder**: `none` 0, `xs` 2, `sm` 4, `md` 6, `lg` 8, `xl` 12, `2xl` 16, `full` 999,
  `circle` 50%. A component takes the rung its *role* names — buttons and icon buttons
  `md`, inputs, selects and checkboxes `sm`, cards `lg`, dialogs, sheets and popovers
  `xl`, tags `xs`. `none` stays the answer for dividers, table cells and full-bleed media,
  and `full`/`circle` are unchanged. Applied across both bindings; roles the decision does
  not name (toast, tooltip, skeleton, empty and loading states, the range track) stay at
  `none` pending a rung of their own.
- **`non-zero-radius` → `untokenised-radius`** — the check moves with the rule, per
  [0012](decisions/0012-conformance-checks-ship-with-rules.md). It now flags any literal
  radius and any `--radius-*` or `SkRadius.*` that names no rung, and it reads the
  **camelCase `borderRadius: 'var(...)'` form** that the old rule could not see at all.

### Fixed

- **The corner rule is enforced at the value level for the first time.** The old check
  whitelisted three token *names* and never opened `tokens/radius.css`, so a full non-zero
  ladder could be swapped into the tokens with every gate still green. A new
  `radius-ladder-drift` assertion compares both `tokens/radius.css` and Flutter's
  `SkRadius` against the ladder the checker itself encodes — each against the ladder
  rather than against each other, so drifting both bindings the same way no longer passes.
  Recorded as lesson 17.

## [4.3.0] — 2026-08-24

### Added

- **`SkErrorState` / `ErrorState`** (both bindings), the first-class error treatment owed
  by [0029](decisions/0029-error-state.md) (now **Accepted**). A centred frame — the same
  layout as the empty and loading states — but its own treatment: **no dashed border**
  (that is empty's alone), an **error-toned glyph** (`--text-danger`), cause →
  consequence → next-step copy, and a **recovery action** — a `Try again` retry by
  default, or a navigational escape for a terminal error (a 403) where retrying cannot
  help. It announces **assertively** (`role="alert"` / `SemanticsService.announce` with
  `Assertiveness.assertive`), unlike loading's polite-busy region or empty's static
  content. `spec/ErrorState.md`. Closes the third of `voice-and-tone.md`'s empty/loading/
  error states, which had a rule but no component.

## [4.2.0] — 2026-08-23

### Added

- **`SkCombobox` / `Combobox`** (both bindings), the searchable long-list picker owed by
  [0028](decisions/0028-searchable-select.md) (now **Accepted**). A field trigger opens an
  anchored-popover (0022) filter surface — a search input over a ranked, keyboard-navigable
  option list, resolving to a sheet on `sm`. Ranking is in the contract: exact → prefix →
  substring → list order, case- and accent-insensitive (`zurich` finds `Zürich`), with a
  scored-subsequence fuzzy matcher opt-in per picker. The filtered-to-nothing state names
  the filter and offers to clear it. `spec/Combobox.md`.
- **`SkFieldTrigger`** — the shared closed-state field chrome (border, focus ring, caret,
  44px floor) now backs both `SkSelect` and `SkCombobox`, so a picker can never again ship
  a trigger that forgot its focus ring.
- **`skMatchScore` / `skFuzzyScore`** matchers exported in both bindings (Flutter util +
  React `components/core/match.js`), so every long list ranks the same way.

### Fixed

- **Flutter `SkSelect` now shows a keyboard focus ring while closed** — a standing Tier 0
  ("focus is always visible") gap where the trigger only lit `borderFocus` while open,
  diverging from React's `Select`. The `SkFieldTrigger` extraction closes it. (See 0028.)

## [4.1.1] — 2026-08-22

### Fixed

- **`spec/Popover.md`** — the positioning section now describes horizontal on-screen
  resolution, not only the vertical flip, completing the "flip to stay on-screen"
  behavior 4.1.0 already promised for
  [0022](decisions/0022-anchored-popover-species.md). The Flutter binding (1.10.1)
  implements it: a trigger hugging the right edge opens leftward instead of overflowing
  off the viewport. No new allowance — spec prose and binding catch up to the rule.

## [4.1.0] — 2026-08-22

### Added

- **`SkPopover` / `Popover`** (both bindings), the anchored-overlay primitive owed by
  [0022](decisions/0022-anchored-popover-species.md). One trigger-anchored surface with a
  `modal` flag: modal carries a scrim, moves focus in and restores it on close; non-modal
  keeps focus on the trigger. Both flip to stay on-screen and dismiss on Escape and
  outside-press, on `--shadow-popover` + a hairline. `spec/Popover.md` documents it.
- **`SkAvatarStack` / `AvatarStack`** (both bindings), the facepile primitive owed by
  [0024](decisions/0024-avatar-receipts-and-stack.md). Overlaps avatars by a shared
  constant (`SkSpace.avatarOverlap` / `--avatar-overlap`), caps at `max`, and collapses
  the remainder into a mono "+k" pill — with the "+1 shows the avatar instead" rule.
  `spec/AvatarStack.md` documents it. Both compose the existing `SkAvatar`.
- Both close the last follow-ups owed by the 3.7.0 acceptances of 0022 and 0024.

## [4.0.0] — 2026-08-22

Major: two Tier 0 rules change.

### Changed (Tier 0)

- **The 44px touch floor now decouples mark from target**, per
  [0023](decisions/0023-sub-floor-chrome-hit-area.md) (accepted). A visible mark may
  render below 44px *only* when its hit area — pointer and assistive-technology bounds —
  stays ≥44px. This generalises the slider's long-standing exception into a rule.
- **A non-primary floating affordance is permitted and is not a FAB**, per
  [0027](decisions/0027-non-primary-floating-affordance.md) (accepted). A labelled,
  square, secondary, transient scroll-position utility (jump-to-latest, back-to-top) with
  `--shadow-popover` is allowed; 0002's ban still reaches every primary/circular/unlabelled
  case. `conformance.md`'s 44px and no-FAB rules move with these.

### Compliance

- **Both bindings meet the 44px floor on touch across the control library.** An audit
  found ~30 tappable controls rendering below 44px with the painted box as the hit area.
  Under the touch-context reading of 0023 they now grow their hit area to 44px on a coarse
  pointer and stay compact on a precise one:
  - **Flutter:** a new `SkTouchTarget` / `skCoarsePointer` primitive, applied to
    `SkIconButton` (which cascades to the Toast/Dialog/DatePicker buttons), `SkButton`,
    `SkTag` (grows to 44 on touch, dismiss included), `SkSegmentedControl`, `SkTabs`,
    `SkSideNav`, `SkSelect`, and the Toast action.
  - **React:** a `useCoarsePointer` (`matchMedia('(pointer: coarse)')`) hook adding a
    `minHeight`/`minWidth` floor to `IconButton`, `Button`, `Tag`, `SegmentedControl`,
    `Tabs`, `SideNav`, `Select`, and — closing a cross-binding gap where the React
    versions lacked the guard their Flutter counterparts already had — `Switch`,
    `Checkbox`, `Radio`.
- The Flutter binding is reviewed against rules 4.0.

## [3.7.0] — 2026-08-22

### Added

- **Four chat-pattern ADRs accepted: [0022](decisions/0022-anchored-popover-species.md),
  [0024](decisions/0024-avatar-receipts-and-stack.md),
  [0025](decisions/0025-progressive-disclosure-metadata.md),
  [0026](decisions/0026-accent-as-ownership-fill.md).** A trigger-anchored popover joins
  the overlay-species table as a third species (modal or non-modal); an avatar
  read-receipt pattern and an `SkAvatarStack` primitive are sanctioned; metadata may be
  disclosed on demand provided it stays reachable via the accessible description and any
  pointer gesture has a non-pointer path; and the single-accent rule is clarified to
  govern competing *actions*, not repeated identity fills (own-message bubbles, selected
  rows). The accent-rule gloss and the overlay-species row in `conformance.md` move with
  them.
- Owed by acceptance (tracked, not in this release): the `SkPopover` and `SkAvatarStack`
  components in both bindings, each with its `spec/` file (0001) and preview surface
  (0020).

### Still proposed

- [0023](decisions/0023-sub-floor-chrome-hit-area.md) (sub-floor hit area) and
  [0027](decisions/0027-non-primary-floating-affordance.md) (non-primary floating
  affordance) change Tier 0 rules and are held for a Major release with their
  conformance-check work (including regularising `SkTag`'s hit area).

## [3.6.0] — 2026-08-22

### Added

- **`--overlay-w-dialog` (440px), the one overlay width shared across bindings.** The
  dialog max-width was a bare literal in each binding — `440` in React's `Dialog` and
  Flutter's `SkDialog` — with nothing holding the two equal. It is now a token
  (`--overlay-w-dialog`) mirrored by `SkChrome.overlayDialogW`, and a new
  `overlay-width-parity` check in `tool/conformance-check.mjs` fails if the Dart and CSS
  values drift apart (the class of bug that produced a 480/460 sheet mismatch). The sheet
  width is deliberately not tokenised: the sheet is not a promoted system component yet
  (`conformance.md` item 8), so its Flutter primitive keeps its own value.

## [3.5.0] — 2026-08-17

### Added

- **Loading states: a skeleton and a labeled fallback, never a bare spinner**, per
  [0021](decisions/0021-loading-states.md). SeaKim stated the loading *rule* ("never a bare
  spinner", "there are no spinners in this system") but shipped no loading *component*, so
  adopters fell back to a bare `CircularProgressIndicator`. Two sanctioned treatments now close
  the gap — a **skeleton** for when you know what is arriving, and a **labeled loading state**
  for when you know only that something is. Additive: nothing removed or renamed, so this is a
  **minor** rules bump per [0011] and [0019].
  - **Tokens** (land in both bindings together): a per-theme `--surface-shimmer` highlight
    (dark lightens, light darkens over `--surface-sunken`), plus a shimmer loop `--dur-shimmer`
    (1400ms) and `--ease-shimmer` (linear) — the existing 80–320ms one-shot curves can't drive a
    loop. The shimmer pulses colour rather than sweeping a gradient, so it stays inside the
    no-gradients rule; reduced motion collapses it to a static block, not a frozen mid-pulse.
  - **React binding**: `Skeleton` (a pulsing placeholder, `aria-hidden`) and `LoadingState` (the
    centred `EmptyState` frame without the dashed border, a static linear bar, `role="status"` +
    `aria-busy`).
  - **Flutter binding** (`1.1.0` → `1.2.0`, `seakim_rules` `3.3` → `3.5`): `SkSkeleton` and
    `SkLoadingState`, mirroring the web semantics; the skeleton respects
    `MediaQuery.disableAnimations`, the labeled state carries `Semantics(liveRegion: true)`.
  - **Conformance** (a binding obligation, unlike 0020's repo gate): a Tier 0
    `indefinite-rotation` rule flags a spinner used as a loading affordance across *both*
    bindings — `CircularProgressIndicator` / `RotationTransition` in Dart, an infinite rotate
    animation in CSS — outside the two sanctioned treatments' own source.
  - **Guidelines**: `voice-and-tone.md`'s "Empty, loading, error" and `accessibility.md`'s live
    regions now point at the treatments, so the rule is no longer orphaned from the component.

---

## [3.4.0] — 2026-08-16

### Added

- **Versioning, second pass**, per
  [0019](decisions/0019-versioning-second-pass.md). Closes two holes 0011's bump table left:
  a token **revalue within the rules is now Minor** (a revalue that fails a documented contrast
  gate is Major); and `tool/version-check.mjs` gains a **binding audit** that prints each
  binding's `seakim_rules` against the rules version and fails only when it is *ahead* or a full
  *Major step behind* — legitimate lag stays green. Records that `seakim_rules` is a claim, not a
  measurement.
- **Preview surfaces are gated**, per
  [0020](decisions/0020-preview-surfaces-are-gated.md). The root gallery, `/next`, and
  `/flutter` are deliverables, no longer checked by a human remembering to look. Three parts:
  - **Web static** (`tool/preview-check.mjs`, pre-commit): every `index.js` export is in the
    ds-shim `FILES` registry and its demo — catches lesson 14's registry gap.
  - **Flutter coverage** (`flutter/example/test/preview_coverage_test.dart`, under `flutter
    test`): a **compiler-checked** test asserts a canonical `skShowcase` covers every barrel
    widget and each builds. Replaces a brittle filename→classname grep (`sk_radio.dart` exports
    `SkRadioGroup`, not `SkRadio`) with real widget types. The Flutter example gains a
    `SkWidgetGallery` demonstrating all 28 widgets, rendered from that same list.
  - **Render** (`--render`, CI): headless Chrome asserts each root-gallery card mounted (not
    blank) with its markers in the DOM, that `/next` renders its markers, and that `/flutter`
    boots (a Flutter view is in the DOM) — nothing throws on any.

  Turns lessons 14 and 15 into a failure instead of a thing to remember. Added to
  `conformance.md` as a **repo gate, not a binding obligation**.

### Note

- `conformance.md` gains a standing line: a check asserts an outcome; the rule that produced it
  usually stays judgement (0012, 0017, 0018, 0019, 0020 are all this shape).

---

## [3.3.0] — 2026-08-16

### Added

- **Raised shadow direction**, per
  [0018](decisions/0018-raised-shadow-direction.md). A raised bar's shadow casts *toward
  the content it floats over* — away from the edge it is anchored to. A top bar casts down;
  a sticky footer (0002's `sm` primary-action bar) casts up. Before this, `raised` was a
  single downward value, so the footer shadow 0002 promised fell off the bottom of the
  viewport and did nothing.
  - **Tokens**: `--shadow-raised-topbar` (down) and `--shadow-raised-footer` (up) added to
    `tokens/depth.css`. `--shadow-raised` is kept as a back-compat alias of the top-bar
    orientation — no token removed or renamed, so this is a **minor** rules bump.
  - **Flutter binding**: `SkDepth` is now exported, with `raisedTopBar` / `raisedFooter`
    replacing the internal, uncalled `raised`. The accessor is role-named and required —
    there is no direction-defaulted `raised`, so a footer wearing the top-bar orientation
    cannot compile. Additive to the public API (the removed method was never exported).
  - Fixes three voyage footers (`SearchScreen`, `TripDetailScreen`, `CheckoutScreen`) that
    were casting a downward shadow off-viewport; they now use `--shadow-raised-footer`.

### Binding versions

- **Flutter `seakim_flutter` → 1.1.0, `seakim_rules: "3.3"`.** Catch-up: the binding had
  stayed at `1.0.0` / `"1.0"` since it was imported, through the `SkRange` addition at
  3.2.0 — the declared conformance had gone stale invisibly, exactly the lag 0011 exists to
  make visible. It passes machine-checkable conformance at 3.3, so it now says so. The
  additions since 1.0.0 (`SkRange`, exported `SkDepth` with role-named raised accessors)
  are all additive, hence the minor bump.

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

# Quiet component audit — what hardcodes borders, shadows, press, or radius

Research for CHR-191 (child of CHR-181, SeaKim 8.0 "Quiet"). Read on 2026-09-18 at
commit 3018452. Sources are the component sources themselves: `components/*/*.jsx`
(React styles are inline; there are no CSS files), `flutter/lib/src/widgets/*.dart`,
`spec/*.md`, `components/*/*.prompt.md`, `tokens/{radius,depth,motion}.css`,
`flutter/lib/src/tokens/{sk_depth,sk_motion,sk_space}.dart`, `tool/conformance-check.mjs`.
Facts only; M2 ticket boundaries are the checkpoint's job.

What M1 settles, per CHR-181, and what each column measures against it:

- **Borders** — "fills and gaps define; a hairline is the exception, and it is alpha." The
  column lists every border a component draws and which token it names. Every border in
  both bindings names a `--border-*` / `c.border*` token; no border colour is a literal.
- **Shadows** — §0.2 unchanged: shadow only on overlays. The column lists box-shadows on
  in-flow elements (including inset box-shadows used as bars or rings) and overlay shadows.
- **Press / easing** — "press is a tint, no scale; all easing ease-out at or under 150ms;
  spring and pop removed." The column lists every `scale(`, `AnimatedScale`,
  `Transform.scale`, `--press-scale`, `pressScale`, `--ease-spring`/`--ease-pop`,
  `SkMotion.spring`/`pop`.
- **Radius rung** — ladder stays; "controls move to lg 8, cards to xl 12." The column names
  the rung each corner takes today. "none named" = no radius property at all (square).
- **Literals** — anything in the five categories that bypasses a token: literal colour (none
  found in either binding beyond `transparent` / `Color(0x00000000)`, which the §0.4 check
  permits), literal border width, literal radius, literal scale factor. Spacing literals are
  out of scope and not listed.

The registered React list is `ds-shim.js` `FILES` (33 components + 3 helpers). Flutter has
the same 33 plus three infrastructure widgets: `SkPressable`, `SkFieldTrigger` (both rows
below), `SkTouchTarget` (no paint; omitted). Paths are relative to the repo root; `R` =
React, `F` = Flutter. Flutter paths omit the `flutter/lib/src/widgets/` prefix after first
mention; React paths omit `components/<group>/` after first mention.

## Table

| Component | B | Borders | Shadows | Press / easing | Radius rung | Literals |
| --- | --- | --- | --- | --- | --- | --- |
| Button | R | `1px solid` on every variant; secondary `--border-default`→`strong` on hover, others `transparent` (`components/core/Button.jsx:18,25,28,31,34`) | none | `scale(var(--press-scale))` on active (`Button.jsx:64`); `--transition-control` (`:63`) | `md` (`Button.jsx:60`) | none |
| Button | F | `Border.all` hairline, colour per variant (`flutter/lib/src/widgets/sk_button.dart:108`) | none (`:109` comment) | `SkPressable` default `pressScale` 0.97 (`sk_button.dart:81`); `AnimatedContainer` instant/out (`:100-101`) | `md` (`sk_button.dart:106`) | none |
| IconButton | R | `1px solid` when `bordered`, else `transparent` (`components/core/IconButton.jsx:22-24`) | none | `scale(var(--press-scale))` on press (`IconButton.jsx:29`) | `md` (`IconButton.jsx:21`) | none |
| IconButton | F | `Border.all` hairline for secondary (`sk_icon_button.dart:101`); hover-label `Border.all(borderStrong)` hairline (`:182`) | hover-label `SkDepth.popover` (`:183`, overlay) | `SkPressable` default `pressScale` (`sk_icon_button.dart:58`); `AnimatedContainer` instant/out (`:93-94`) | `md` (`sk_icon_button.dart:99`); hover-label none named | none |
| Badge | R | `1px solid --border-subtle` for `subtle`, else `transparent` (`components/core/Badge.jsx:19`) | none | none | none named on the badge; dot `full` (`Badge.jsx:24`) | none |
| Badge | F | `Border.all` hairline for `subtle` (`sk_badge.dart:57`) | none | none | `pill` when `pill`, else none (`sk_badge.dart:55`); dot `BoxShape.circle` (`:67`) | none |
| Tag | R | `1px solid --border-default`/`strong`/`accent` (`components/core/Tag.jsx:19`); remove button `border: 0` (`:33`) | none | none — `--transition-control` only (`Tag.jsx:22`) | `xs` (`Tag.jsx:17`) | none |
| Tag | F | `Border.all` hairline, `SkDepth.emphasis` when selected (`sk_tag.dart:77-79`) | none | `SkPressable` default `pressScale` 0.97 on the whole tag (`sk_tag.dart:44`; React has no press scale); dismiss `pressScale: 1` (`:102`) | `xs` (`sk_tag.dart:75`) | none |
| Card | R | `1px solid --border-subtle`/`strong`/`accent` (`components/core/Card.jsx:13`); footer `borderTop` (`:32`) | none | none; hover bg/border on `--ease-out` (`Card.jsx:15`) | `lg` (`Card.jsx:14`) | none |
| Card | F | `Border.all` hairline, top-only when `borderless` (`sk_card.dart:132-135`); footer hairline `Container` (`:97`) | none | `SkPressable pressScale: SkMotion.pressScaleLarge` when tappable (`sk_card.dart:113`; React has none) | `lg` (`sk_card.dart:127`); doc comment `:8` says "no radius" (stale) | none |
| Avatar | R | ring drawn as `boxShadow: inset 0 0 0 1px --border-subtle` (`components/core/Avatar.jsx:23`) | in-flow inset box-shadow as hairline (`:23`); status dot `0 0 0 2px --surface-card` (`:37`) | none | `circle` (`Avatar.jsx:18,35`) | `1px`/`2px` widths inside box-shadow strings (`:23,37`) |
| Avatar | F | `Border.all` hairline (`sk_avatar.dart:75`); status dot `Border.all(surfaceCard, width: 2)` (`:102`) | none | none | `BoxShape.circle` (`sk_avatar.dart:73,96`) | `width: 2` literal, not `SkDepth.emphasis` (`:102`) |
| AvatarStack | R | none | ring `boxShadow: 0 0 0 2px --surface-card` on every in-flow mark (`components/core/AvatarStack.jsx:26,41`) | none | `full` / `circle` (`AvatarStack.jsx:40,64`) | `2px` inside the ring string (`:26`) |
| AvatarStack | F | none | `BoxShadow(color: surfaceCard, spreadRadius: 2)` built in the widget, not `SkDepth` (`sk_avatar_stack.dart:86-87,112,128`) | none | `pill` (`:111`); `BoxShape.circle` (`:128`) | `spreadRadius: 2` (`:87`) |
| Stat | R | none | none | none | none named | none |
| Stat | F | none | none | none | none named | none |
| Icon | R | none | none | none | none named | none |
| Icon | F | none | none | none | none named | none |
| Field | R | none | none | none | none named | none |
| Field | F | none | none | none | none named | none |
| Input | R | `1px solid` default/strong/focus/danger (`components/forms/Input.jsx:17,26`) | focus `--focus-ring-inset` (`Input.jsx:27`) | none; `--transition-control` (`:30`) | `sm` (`Input.jsx:28`) | none |
| Input | F | `Border.all` hairline → `emphasis` on focus (`sk_input.dart:163-167`) | none | none; `AnimatedContainer` instant/out (`sk_input.dart:154-155`) | `sm` (`sk_input.dart:161`) | none |
| Textarea | R | `1px solid` (`components/forms/Textarea.jsx:6,19`) | focus `--focus-ring-inset` (`Textarea.jsx:20`) | none (`:23`) | `sm` (`Textarea.jsx:19`) | none |
| Textarea | F | `Border.all` hairline → `emphasis` on focus (`sk_textarea.dart:101-103`) | none | none (`:95-96`) | `sm` (`sk_textarea.dart:99`) | none |
| Select | R | `1px solid` (`components/forms/Select.jsx:16,25`) | focus `--focus-ring-inset` (`Select.jsx:26`) | none (`:27`) | `sm` (`Select.jsx:25`) | none |
| Select | F | trigger from `SkFieldTrigger` (below); overlay from `SkPopover` (`sk_select.dart:129`) | via `SkPopover` | `pressScale: 1` on options (`sk_select.dart:142`); `AnimatedContainer` base/out (`:122-123`) | via `SkFieldTrigger` (`sm`) | none |
| SkFieldTrigger (F only) | F | `Border.all` hairline → `emphasis` when lit (`sk_field_trigger.dart:83-85`) | none | `pressScale: 1` (`sk_field_trigger.dart:52`) | `sm` (`sk_field_trigger.dart:79`) | none |
| Checkbox | R | `1px solid` default/strong/accent (`components/forms/Checkbox.jsx:33`) | none | box `scale(0.94)`→`scale(1)` on mark under `--transition-control` (ease-out) (`Checkbox.jsx:37`) | `sm` (`Checkbox.jsx:34`) | `0.94` |
| Checkbox | F | `Border.all` hairline (`sk_checkbox.dart:77-85`) | none | `AnimatedScale 0.94→1` with `SkMotion.pop` (`sk_checkbox.dart:60-63`); `pressScale: 1` (`:44`) | `sm` (`sk_checkbox.dart:71`) | `0.94` |
| Radio | R | `${on ? 2 : 1}px solid` (`components/forms/Radio.jsx:10`) | none | dot `scale(0)`→`scale(1)` with `--ease-pop` (`Radio.jsx:16-17`) | `circle` (`Radio.jsx:7,14`) | border width `2`/`1` computed literal, not `--border-emphasis`/`hairline` (`:10`) |
| Radio | F | `Border.all` hairline → `emphasis` when on (`sk_radio.dart:105-113`) | none | dot `AnimatedScale 0→1` with `SkMotion.pop` (`sk_radio.dart:116-119`); `pressScale: 1` (`:79`) | `BoxShape.circle` (`sk_radio.dart:103,124`) | none |
| Switch | R | `1px solid` default/accent (`components/forms/Switch.jsx:37`) | none | knob `translateX` with `--ease-spring` (`Switch.jsx:44`); `--transition-surface` (`:38`) | track `full` (`:35`), knob `circle` (`:41`) | none |
| Switch | F | `Border.all` hairline (`sk_switch.dart:56-62`) | none | knob `AnimatedAlign` with `SkMotion.spring` (`sk_switch.dart:68-69`); `pressScale: 1` (`:92`) | track `pill` (`:55`), knob `BoxShape.circle` (`:75`) | none |
| SegmentedControl | R | outer `1px solid --border-default` (`components/forms/SegmentedControl.jsx:18`); segment `borderLeft` subtle (`:32`) | none | none; `--transition-control` (`:39`) | `md` (`SegmentedControl.jsx:18`) | none |
| SegmentedControl | F | outer `Border.all` hairline default (`sk_segmented_control.dart:119`); segment left hairline (`:74-78`) | none | `pressScale: 1` (`:53`); `AnimatedContainer` instant/out (`:63-64`) | `md` (`sk_segmented_control.dart:117`) | none |
| Slider | R | rail `1px solid --border-subtle` (`components/forms/Slider.jsx:24`); thumb `1px solid` strong/focus (`:36-38`) | none | whole control `scale(var(--press-scale))` while dragging (`Slider.jsx:158`) | none named | tick `width: 1, height: 6` (`:175`) |
| Slider | F | rail `Border.all` hairline (`sk_slider.dart:212-213`); thumb hairline (`:251-257`) | none | thumb `AnimatedScale` to `SkMotion.pressScale` (`sk_slider.dart:195-200`) — the one Flutter scale outside `SkPressable` | none named | tick `width: 1, height: 6` (`:236`) |
| DatePicker | R | header `borderBottom` subtle (`components/forms/DatePicker.jsx:98`); grid gap = `--border-subtle` background + `gap: 1` (`:117`); month `borderLeft` (`:208`); sheet `borderTop` default (`:276`); popover `1px solid --border-default` (`:288`) | today `inset 0 -2px 0 --border-accent` (`:73`, in-flow inset); sheet `--shadow-sheet` (`:277`); popover `--shadow-popover` (`:289`) | none; keyframes on `--ease-out` (`:278,290`); cells `--transition-control` (`:74`) | none named | `-2px` in the today inset string (`:73`) |
| DatePicker | F | sheet top hairline (`sk_date_picker.dart:254-258`); header bottom hairline (`:328-330`); today bottom `emphasis` accent (`:489-491`); overlay from `SkPopover` (`:242`) | via `SkPopover` | none | none named | none |
| Dialog | R | `1px solid --border-default` (`components/feedback/Dialog.jsx:24`); footer `borderTop` (`:45`) | `--shadow-dialog` (`Dialog.jsx:26`, overlay) | none | `xl` (`Dialog.jsx:25`) | none |
| Dialog | F | `Border.all` hairline (`sk_dialog.dart:22`); footer top hairline (`:125`); sheet top hairline (`:240-242`) | `SkDepth.dialog` (`:23`); sheet `SkDepth.sheet` (`:244`) | enter `ScaleTransition 0.97→1` on `SkMotion.spring` (`sk_dialog.dart:175,182`); exit `out` | `xl` (`:20`); sheet top `xl` (`:238`) | `begin: 0.97` (`:182`) |
| Toast | R | `1px solid --border-default` (`components/feedback/Toast.jsx:21`) | `--shadow-toast` (`:22`, overlay) | `sk-toast-in` on `--ease-pop` with `scale(.98)` (`Toast.jsx:23,38`) | `none` (`:22`) | `.98` |
| Toast | F | `Border.all` hairline (`sk_toast.dart:66`) | `SkDepth.toast` (`:67`) | enter tween on `SkMotion.pop` (`sk_toast.dart:52`); dismiss `pressScale: 1` (`:86`) | none named | none |
| Tooltip | R | `1px solid --border-strong` (`components/feedback/Tooltip.jsx:26`) | `--shadow-popover` (`:27`, overlay) | `sk-tip-in` on `--ease-out` (`:29`) | `none` (`:27`) | none |
| Tooltip | F | delegates to `SkHoverLabel` — `Border.all(borderStrong)` hairline (`sk_icon_button.dart:182`) | `SkDepth.popover` (`sk_icon_button.dart:183`) | none | none named | none |
| Popover | R | `1px solid --border-default` (`components/feedback/Popover.jsx:74`) | `--shadow-popover` (`:75`, overlay) | none | `xl` (`Popover.jsx:76`); `spec/Popover.md:53` says `--radius-none` | none |
| Popover | F | `Border.all` hairline (`sk_popover.dart:225`) | `SkDepth.popover` (`:226`) | none | `xl` (`sk_popover.dart:222`) | none |
| Combobox | R | trigger `1px solid` (`components/feedback/Combobox.jsx:120-123,153`); overlay `1px solid --border-default` (`:174`); search row `borderBottom` (`:180`); search box border (`:184`) | trigger focus `--focus-ring-inset` (`:155`); overlay `--shadow-popover` (`:175`) | none; `--transition-control` (`:159`) | trigger `sm` (`:154`); overlay `xl` (`:176`); search box `sm` (`:184`) | none |
| Combobox | F | trigger via `SkFieldTrigger`; overlay via `SkPopover` (`sk_combobox.dart:214`) | via `SkPopover` | `pressScale: 1` (`:374,437`); `AnimatedContainer` base/out (`:289-290`) | via `SkFieldTrigger`/`SkPopover` | none |
| EmptyState | R | `1px dashed --border-default` (`components/feedback/EmptyState.jsx:10`) | none | none | `none` (`:10`) | none |
| EmptyState | F | `_DashedBorderPainter` stroke `SkDepth.hairline` in `borderDefault` (`sk_empty_state.dart:43,101`) | none | none | none named | dash `4` / gap `3` (`:93-94`) |
| ErrorState | R | none (`--surface-sunken` fill, `components/feedback/ErrorState.jsx:47`) | none | none | none named | none |
| ErrorState | F | none (`sk_error_state.dart:75`) | none | none | none named | none |
| LoadingState | R | none | none | none | bar `none` (`components/feedback/LoadingState.jsx:37`) | none |
| LoadingState | F | none | none | none | none named | none |
| Skeleton | R | none | none | shimmer is `linear` (`tokens/motion.css`) | `radius` prop, default `--radius-none`, accepts any string (`components/feedback/Skeleton.jsx:16,28`) | none by default |
| Skeleton | F | none | none | shimmer is `linear` | `radius` is a raw `double`, default `0`, fed to `BorderRadius.circular` (`sk_skeleton.dart:21,30,64`) — not a rung | `0` default |
| Table | R | header `borderBottom` (`components/data/Table.jsx:14`); row `borderTop` (`:97,112,146`); container `1px solid --border-subtle` (`:194,206,218`) | selected row `inset 2px 0 0 --border-accent` (`Table.jsx:87`, in-flow inset as bar) | none; `--transition-surface` (`:89`) | none named | `2px` in the inset string (`:87`) |
| Table | F | container `Border.all` hairline (`sk_table.dart:141,299`); row top hairline (`:187,279,318`); selected left `emphasis` accent (`:319-321`) | none | list rows `SkPressable pressScale: SkMotion.pressScaleLarge` (`sk_table.dart:179`; React has none) | none named | none |
| Range | R | track `1px solid --border-subtle` (`components/data/Range.jsx:33`) | none | none | `none` (`:33`) | none |
| Range | F | track `Border.all(color: borderSubtle)` with no `width` — Flutter default 1.0, not `SkDepth.hairline` (`sk_range.dart:94`) | none | none | `BorderRadius.zero` (`:95`) | default width |
| Tabs | R | list `borderBottom` subtle (`components/navigation/Tabs.jsx:17`); tab `border: none` (`:32`) | none | indicator `scaleX` with `--ease-spring` (`Tabs.jsx:46-47`) | none named | indicator `height: 2` (not `--border-emphasis`) (`:44`) |
| Tabs | F | bottom hairline (`sk_tabs.dart:46-47`) | none | indicator `Transform.scale(scaleX)` on `SkMotion.spring` (`sk_tabs.dart:123-126`); `pressScale: 1` (`:59`) | none named | none (indicator `SkDepth.emphasis`, `:129`) |
| SideNav | R | `borderRight` (`components/navigation/SideNav.jsx:41`); header `borderBottom` (`:48`); footer `borderTop` (`:70`) | active `inset 2px 0 0 --fill-accent` (`:22`, in-flow inset as bar) | none; `--transition-control` (`:25`); width on `--ease-out` (`:42`) | none named | `2px` in the inset string (`:22`) |
| SideNav | F | right hairline (`sk_side_nav.dart:72-73`); header bottom (`:86-88`); footer top (`:134-136`); active left `emphasis` `fillAccent` (`:189-192`) | none | `pressScale: 1` (`:167`); `AnimatedContainer` slow/out (`:67-68`), instant/out (`:177-178`) | none named | none |
| TabBar | R | `borderTop` subtle (`components/navigation/TabBar.jsx:10`); item `border: none` (`:22`) | none | active icon `translateY(-1px) scale(1.04)` on `--ease-spring` (`TabBar.jsx:29-30`) | none named | `1.04` scale |
| TabBar | F | top hairline (`sk_tab_bar.dart:43-44`) | none | active icon `Transform.translate` + `Transform.scale(1 + t*0.04)` on `SkMotion.spring` (`sk_tab_bar.dart:66-72`); `pressScale: 1` (`:56`) | none named | `0.04` scale |
| SkPressable (F only) | F | focus ring `Border.all(borderFocus, width: SkDepth.emphasis)` (`sk_pressable.dart:163-165`) | none (ring painted as border, `:142` comment) | `AnimatedScale` to `pressScale ?? SkMotion.pressScale` on press (`sk_pressable.dart:89-96`) — the one press implementation every Flutter widget routes through | none named | none |

Cross-binding notes the table surfaces:

- Press scale disagrees between bindings on **Tag**, **Card**, **Table rows**: Flutter scales
  (`sk_tag.dart:44` default, `sk_card.dart:113`, `sk_table.dart:179`), React does not.
- Every Flutter press scale routes through `SkPressable` (`sk_pressable.dart:89-96`) except
  **Slider** (`sk_slider.dart:195`) and the **Dialog** enter scale (`sk_dialog.dart:182`).
  Every React press scale is a per-component `transform` (Button, IconButton, Slider).
- Spring/pop call sites: React `--ease-spring` in Tabs, TabBar, Switch; `--ease-pop` in Radio,
  Toast. Flutter `SkMotion.spring` in Tabs, TabBar, Switch, Dialog; `SkMotion.pop` in Radio,
  Toast, Checkbox. Checkbox differs: React eases the mark with `--transition-control`
  (ease-out), Flutter with `pop`.
- `spec/Popover.md:53` and `components/core/Tag.prompt.md:8` document rungs; Popover's spec
  (`none`) disagrees with both bindings (`xl`). No gate reads `.md` (lesson 17).
- Inset box-shadows used as borders or bars in React (Avatar ring, AvatarStack ring, Table
  selected bar, SideNav active bar, DatePicker today underline) are drawn as real borders in
  Flutter. No check looks at `boxShadow` on in-flow elements; only `--shadow-*` tokens are
  role-named.
- `untokenised-radius` (`tool/conformance-check.mjs:199-227`) matches `borderRadius:` literals
  and `BorderRadius.circular(<number>)`; it cannot see `BorderRadius.circular(widget.radius)`
  (Skeleton) or `BorderRadius.zero`. No check reads border widths or `transform: scale`.

## Follows automatically from tokens

Nothing in the five columns beyond token consumption; no scale, no spring/pop, no literal, and
no rung in the "controls → lg / cards → xl" reassignment. 15 entries (10 components in both
bindings, 5 in one).

- **Icon** (R, F) — paints nothing but a glyph.
- **Stat** (R, F) — text only.
- **Field** (R, F) — text only.
- **ErrorState** (R, F) — fill only, no border.
- **LoadingState** (R, F) — fill + `none` bar.
- **Badge** (R, F) — hairline is `--border-subtle` / `borderSubtle`; rungs are `full`/`pill`/none.
- **Tooltip** (R, F) — overlay; shadow is the popover token; `none` radius.
- **Popover** (R, F) — overlay; `xl` is not in the reassignment. (Spec text disagrees on the rung; that is a doc fix, not code.)
- **DatePicker** (R, F) — all borders tokened, overlays wear overlay tokens, easing is `--ease-out`, no rung named.
- **SideNav** (R, F) — borders tokened, no scale, easing `out`; React's active bar is an inset box-shadow, a mechanism note rather than a token bypass.
- **Dialog** (R only) — overlay; `xl`. Flutter is below for its spring enter.
- **Range** (R only) — tokened, `none`. Flutter is below for the default-width border.
- **EmptyState** (R only) — one dashed hairline in `--border-default`. Flutter is below for the dash literals.
- **Combobox** (F only) — takes its trigger and overlay from `SkFieldTrigger` / `SkPopover`; nothing of its own to change.
- **Select** (F only) — same.

## Needs a ticket in M2

One line each: what is hardcoded and where. 25 entries (24 code, 1 docs).

- **Button** (R, F) — press scale (`Button.jsx:64`, `sk_button.dart:81` via `SkPressable`); `md` rung, controls move to `lg` (`Button.jsx:60`, `sk_button.dart:106`).
- **IconButton** (R, F) — press scale (`IconButton.jsx:29`, `sk_icon_button.dart:58`); `md` rung (`IconButton.jsx:21`, `sk_icon_button.dart:99`).
- **SkPressable** (F) — `AnimatedScale` is the shared press mechanism (`sk_pressable.dart:89-96`); every Flutter press change lands here first.
- **Tag** (F) — default press scale where React has none (`sk_tag.dart:44`). Both bindings name `xs` (`Tag.jsx:17`, `sk_tag.dart:75`); whether a chip counts as a "control" is a checkpoint call.
- **Card** (R, F) — `lg` rung, cards move to `xl` (`Card.jsx:14`, `sk_card.dart:127`); Flutter `pressScaleLarge` on tappable cards (`sk_card.dart:113`); stale "no radius" doc (`sk_card.dart:8`).
- **Avatar** (R, F) — React ring is an in-flow inset box-shadow with `1px`/`2px` literals (`Avatar.jsx:23,37`); Flutter status ring `width: 2` literal (`sk_avatar.dart:102`).
- **AvatarStack** (R, F) — ring is a box-shadow / hand-built `BoxShadow` on in-flow marks with a literal `2` (`AvatarStack.jsx:26`, `sk_avatar_stack.dart:86-87`).
- **Input** (R, F) — `sm` rung, controls move to `lg` (`Input.jsx:28`, `sk_input.dart:161`).
- **Textarea** (R, F) — `sm` rung (`Textarea.jsx:19`, `sk_textarea.dart:99`).
- **Select** (R) and **SkFieldTrigger** (F) — `sm` rung (`Select.jsx:25`, `sk_field_trigger.dart:79`); the Flutter fix covers Select, Combobox, DatePicker triggers at once.
- **Combobox** (R) — trigger and search box `sm` (`Combobox.jsx:154,184`).
- **Checkbox** (R, F) — `sm` rung (`Checkbox.jsx:34`, `sk_checkbox.dart:71`); Flutter mark eases with `pop` (`sk_checkbox.dart:63`); both bindings scale the mark 0.94→1 (`Checkbox.jsx:37`, `sk_checkbox.dart:61`).
- **Radio** (R, F) — dot enters on `pop` (`Radio.jsx:17`, `sk_radio.dart:119`); React border width is a computed literal `2`/`1` (`Radio.jsx:10`).
- **Switch** (R, F) — knob moves on `spring` (`Switch.jsx:44`, `sk_switch.dart:69`).
- **SegmentedControl** (R, F) — `md` rung (`SegmentedControl.jsx:18`, `sk_segmented_control.dart:117`).
- **Slider** (R, F) — press scale on the control (`Slider.jsx:158`) / thumb (`sk_slider.dart:195-200`), the one Flutter scale outside `SkPressable`; tick `1×6` literals (`Slider.jsx:175`, `sk_slider.dart:236`); `spec/Slider.md:41` documents the scale.
- **Dialog** (F) — enter is `ScaleTransition 0.97→1` on `spring` (`sk_dialog.dart:175,182`).
- **Toast** (R, F) — enters on `pop` with a `scale(.98)` keyframe (`Toast.jsx:23,38`, `sk_toast.dart:52`); `Toast.prompt.md:9` documents it.
- **Tabs** (R, F) — indicator on `spring` (`Tabs.jsx:47`, `sk_tabs.dart:124`); React indicator `height: 2` literal (`Tabs.jsx:44`).
- **TabBar** (R, F) — active icon `scale(1.04)` on `spring` (`TabBar.jsx:29-30`, `sk_tab_bar.dart:68,72`).
- **Table** (F) — list rows `pressScaleLarge` where React has none (`sk_table.dart:179`).
- **Skeleton** (R, F) — `radius` prop is unconstrained (`Skeleton.jsx:16`, `sk_skeleton.dart:30`); Flutter feeds a raw double to `BorderRadius.circular` (`:64`), which the §0.1 check cannot see.
- **Range** (F) — track border omits `width`, so it is Flutter's default 1.0 rather than `SkDepth.hairline` (`sk_range.dart:94`).
- **EmptyState** (F) — dash `4` / gap `3` literals in the painter (`sk_empty_state.dart:93-94`).
- **Popover** (docs) — `spec/Popover.md:53` says `--radius-none`; both bindings ship `xl`.

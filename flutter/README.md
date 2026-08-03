# SeaKim for Flutter

Custom widgets built on Flutter primitives — not themed Material. The system's three
loudest decisions (0px radius everywhere, shadows only on things that float, scale-press
instead of ink ripple) are the three Material resists hardest, so the widget layer is
ours and only the invisible platform machinery is borrowed.

One codebase for mobile, desktop, and web.

## Install

```yaml
# your app's pubspec.yaml
dependencies:
  seakim_flutter:
    path: ../seakim/flutter   # or a git ref, or a private pub server
```

Then drop the font files into `assets/fonts/`. All three families are on Google Fonts
with open licences: **Outfit**, **Plus Jakarta Sans**, **IBM Plex Mono**. The filenames
`pubspec.yaml` expects are listed there — nine `.ttf` files. They are not committed here
because no licensed binaries were supplied.

## Use

```dart
import 'package:seakim_flutter/seakim_flutter.dart';

void main() => runApp(
      const SkApp(
        brand: SkAppBrand.voyage,   // rotates the accent hue
        mode: SkThemeMode.dark,     // dark is the default
        child: TripsScreen(),
      ),
    );
```

Read tokens from the context, never from a palette directly:

```dart
final SkColors c = context.skColors;

Container(
  color: c.surfaceCard,                                  // not SkStone.s900
  padding: const EdgeInsets.all(SkSpace.s5),
  decoration: BoxDecoration(
    border: Border.all(color: c.borderSubtle, width: SkDepth.hairline),
  ),
  child: Text('Lisbon', style: SkText.subheading.copyWith(color: c.textPrimary)),
)
```

## Responsive

Same three breakpoints as the web kit, and for the same reason — measured **container**
width, not viewport. In Dart this is the natural tool rather than a workaround:

```dart
SkResponsive(
  builder: (context, bp, width) => Column(
    children: [
      if (bp.isWide) const _SideRail(),
      _Roster(bp: bp),
    ],
  ),
)

// or pick a value per breakpoint
final int columns = bp.pick(sm: 1, md: 2, lg: 4);
```

`sm` under 640 · `md` 640–1023 · `lg` 1024 and up.

## What maps to what

| Web (React) | Flutter | Notes |
| --- | --- | --- |
| `styles.css` + `data-theme` / `data-app` | `SkApp`, `SkTheme`, `SkThemeData` | Nesting `SkTheme` retints a subtree, exactly like a nested `data-app` |
| `Button` | `SkButton` | Same variants and sizes |
| `IconButton` | `SkIconButton` | `label` is required, not optional |
| `Badge` / `Tag` | `SkBadge` / `SkTag` | |
| `Card` | `SkCard` | `interactive` became `onPressed` |
| `Avatar` / `Stat` | `SkAvatar` / `SkStat` | |
| `Field` / `Input` / `Textarea` | `SkField` / `SkInput` / `SkTextarea` | |
| `Select` | `SkSelect` | Native `<select>` became a custom popover |
| `Checkbox` / `Radio` / `Switch` | `SkCheckbox` / `SkRadioGroup` / `SkSwitch` | `Radio` renders the whole group in both |
| `SegmentedControl` | `SkSegmentedControl` | |
| `Dialog` | `SkDialog` + `showSkDialog` | |
| `Toast` | `SkToast` + `showSkToast` | Helper handles overlay placement and auto-dismiss |
| `Tooltip` | `SkTooltip` | |
| `EmptyState` | `SkEmptyState` | |
| `Tabs` / `SideNav` / `TabBar` | `SkTabs` / `SkSideNav` / `SkTabBar` | |
| `PlayerSheet` pattern | `showSkSheet` | Bottom sheet at sm, centred panel from md up |
| `Viewport` | `SkResponsive` | `LayoutBuilder` instead of `ResizeObserver` |
| — | `SkPressable` | New. The hover/press/focus primitive every control sits on |

## Colour is generated, not retyped

`tokens/colors.css` is still the single source of truth. The brand ramps there are
`oklch(L C H)` with H rotating per app, and Dart cannot evaluate oklch — so every step
is baked to sRGB in `lib/src/tokens/palette.g.dart`.

```bash
dart run tool/gen_tokens.dart
```

The generator uses chroma-reduction gamut mapping rather than clipping, because clipping
shifts hue and would break the promise that every app's ramp differs only in H. A few
steps therefore sit at slightly lower chroma than the CSS asks for — most visibly
`clay.s600`, which cannot be reached in sRGB at that lightness.

**Adding an app:** add the hue to `tokens/colors.css` and `tokens/apps.css`, add it to
`_apps` in the generator and to the `SkAppBrand` enum, re-run. Never hand-edit the
`.g.dart`.

## Where this deliberately differs from the web

- **Springy curves are tuned, not identical.** `SkMotion.spring` uses the same
  `cubic-bezier(0.34, 1.42, 0.50, 1)` control points, but Flutter composites
  differently from a browser, so the felt overshoot is close rather than pixel-equal.
  Colour tweens clamp badly on overshoot — use `spring` for transforms, `out` for colour.
- **`SkInput` and `SkTextarea` keep a Material ancestor.** Only for selection colours,
  handles, and the platform context menu. Rebuilding those faithfully is a lot of
  invisible work to get wrong.
- **Letter spacing is absolute in Flutter**, not em-relative, so each `SkText` style
  multiplies its own size by the em value from the CSS.
- **Hover exists on desktop and web, not on touch.** Every hover affordance has a
  non-hover equivalent — that is why table row actions become inline buttons at `sm`.

## Not yet built

The **screens** are not ported. This is the component library and token layer; the
Voyage and Bench kits still exist only as React. Porting a screen is now mostly
mechanical — say which one and I will do it.

## Icons are bundled, not depended on

The icon fonts ship inside this package — `assets/icons/Phosphor-{Regular,Bold,Fill,Duotone}.ttf`
(Phosphor Icons, MIT) — and the code points are generated:

```bash
dart run tool/gen_icons.dart      # tool/phosphor_codepoints.json -> lib/src/tokens/sk_icons.g.dart
```

```dart
SkIcon(SkIcons.mapPin)                             // regular
SkIcon(SkIcons.mapPin, weight: SkIconWeight.fill)  // active
```

**Why not the `phosphor_flutter` package:** every Flutter icon package subclasses
`IconData`, and Flutter sealed that class (`final class`) in 3.27. Since this system also
uses `Color.withValues`, which *needs* 3.27+, no single SDK could satisfy both. Bundling
the font sidesteps it entirely — nothing subclasses `IconData`, so the widgets stay on
modern Flutter, and three apps stop sharing a third party's release cadence.

`SkGlyph` is a value type carrying all four weights as `const IconData`. The const matters:
Flutter's `--tree-shake-icons` only recognises const `IconData`, and resolving a code point
at render time would silently ship all four fonts (~2 MB) whole.

Duotone is a glyph *pair* — a solid backdrop under a line layer — so `SkIcon` stacks the two
and knocks the backdrop back to 20%. The other three weights are a single glyph.

Adding an icon is nothing: all 1512 Phosphor glyphs are already generated. Never hand-edit
the `.g.dart`.

## Before you trust this

It compiles and it runs. On Flutter 3.44 / Dart 3.12:

```bash
flutter analyze     # No issues found!
flutter test        # All tests passed!
```

`test/smoke_test.dart` mounts a real `SkButton` inside `SkApp`, reads tokens from context,
taps it, renders every icon weight, and checks the bundled font licence is registered.

Two things to know before shipping an app on it:

1. **The fonts are not committed.** `pubspec.yaml` declares ten `.ttf` files under
   `assets/fonts/` — Outfit, Plus Jakarta Sans, IBM Plex Mono, all on Google Fonts under
   the SIL OFL. Drop them in or the asset bundle will not build. The OFL notice has to
   ship with your app; add it in `lib/src/tokens/sk_licenses.dart` next to the icon one.
2. **Tree shaking is unverified.** The const `IconData` shape is designed for
   `--tree-shake-icons`, but that only proves out in a release build of a real app —
   this package has no app target. Check with `flutter build apk --release` and look for
   `Font asset ... tree-shaken`. If it does not fire, the fonts ship whole.

The screens still are not ported — this is the component library and token layer.

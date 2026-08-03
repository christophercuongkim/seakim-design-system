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

## Before you trust this

It has not been compiled. I can write and review Dart but cannot run `flutter analyze`
in this environment, so expect a handful of first-build errors — most likely in these
three places, in order of probability:

1. **`phosphor_flutter` API surface.** `SkGlyph` assumes v2.x exposes each glyph as a
   function taking an optional `PhosphorIconsStyle`. If your installed version differs,
   `sk_icon.dart` is the only file to change.
2. **`Color.withValues`.** Requires Flutter 3.27+. On older SDKs replace with
   `withOpacity`.
3. **`EditableText` required parameters.** These have shifted across versions; the
   analyzer will name any that are missing.

Paste the output of `flutter analyze` and I will clear them.

import 'package:flutter/widgets.dart';

import '../tokens/sk_colors.dart';
import '../tokens/sk_licenses.dart';
import '../tokens/sk_type.dart';

export '../tokens/sk_colors.dart';
export '../tokens/sk_depth.dart';
export '../tokens/sk_motion.dart';
export '../tokens/sk_space.dart';
export '../tokens/sk_type.dart';
export '../tokens/palette.g.dart';

/// Everything a SeaKim widget needs to paint itself.
///
/// Read it with SkTheme.of(context). Widgets never import a palette directly.
@immutable
class SkThemeData {
  const SkThemeData({required this.colors, required this.brand, required this.mode});

  final SkColors colors;
  final SkAppBrand brand;
  final SkThemeMode mode;

  factory SkThemeData.of(SkAppBrand brand, SkThemeMode mode) => SkThemeData(
        brand: brand,
        mode: mode,
        colors: mode == SkThemeMode.dark
            ? SkColors.dark(brand.ramp)
            : SkColors.light(brand.ramp),
      );

  Brightness get brightness => colors.brightness;
  bool get isDark => colors.isDark;

  SkThemeData withMode(SkThemeMode next) => SkThemeData.of(brand, next);
  SkThemeData withBrand(SkAppBrand next) => SkThemeData.of(next, mode);
}

/// Provides [SkThemeData] to the subtree.
///
/// Nesting is supported and meaningful: wrapping part of a Voyage screen in
/// SkTheme(brand: SkAppBrand.bench) retints only that subtree, exactly as a nested
/// data-app attribute does on the web.
class SkTheme extends InheritedWidget {
  const SkTheme({super.key, required this.data, required super.child});

  final SkThemeData data;

  static SkThemeData of(BuildContext context) {
    final SkTheme? found = context.dependOnInheritedWidgetOfExactType<SkTheme>();
    assert(found != null, 'No SkTheme found. Wrap your app in SkApp or SkTheme.');
    return found!.data;
  }

  /// Null-safe lookup, for widgets that can fall back to a default.
  static SkThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SkTheme>()?.data;

  @override
  bool updateShouldNotify(SkTheme oldWidget) => oldWidget.data != data;
}

/// Convenience shorthands. Kept deliberately terse because widget code reads
/// these on nearly every line.
extension SkThemeContext on BuildContext {
  SkThemeData get sk => SkTheme.of(this);
  SkColors get skColors => SkTheme.of(this).colors;
}

/// Root of a SeaKim app.
///
/// Sets up the theme, a default text style and colour, and the directionality and
/// media plumbing widgets expect — without pulling in MaterialApp's visual
/// defaults.
///
/// It is a theme scope, not an app shell: it provides no [Overlay], [Navigator],
/// or [MediaQuery], so [SkToast], [SkDialog], and [SkSelect] need a [WidgetsApp]
/// or [MaterialApp] above them. For an app that is otherwise Material, prefer
/// [SkMaterialTheme] with [SkThemeScope] — see the README.
class SkApp extends StatelessWidget {
  const SkApp({
    super.key,
    required this.child,
    this.brand = SkAppBrand.seakim,
    this.mode = SkThemeMode.dark,
    this.textDirection = TextDirection.ltr,
  });

  final Widget child;
  final SkAppBrand brand;
  final SkThemeMode mode;

  /// Reading direction for the subtree. [Icon], [Row], and every
  /// `*Directional` value assert on this, so SkApp supplies it rather than
  /// making each app remember a [Directionality] of its own. Override when the
  /// app localises to an RTL language.
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    // Idempotent; the bundled icon font is MIT and owes an attribution notice.
    registerSkLicenses();

    final SkThemeData data = SkThemeData.of(brand, mode);
    return SkTheme(
      data: data,
      child: Directionality(
        textDirection: textDirection,
        child: DefaultTextStyle(
          style: SkText.body.copyWith(color: data.colors.textPrimary),
          child: ColoredBox(
            color: data.colors.surfacePage,
            child: child,
          ),
        ),
      ),
    );
  }
}

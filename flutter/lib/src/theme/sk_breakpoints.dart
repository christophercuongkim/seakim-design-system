import 'package:flutter/widgets.dart';

/// Breakpoints, mirroring the web kit exactly.
///
/// The web system styles inline rather than with stylesheets, so its screens
/// cannot use CSS media queries — they branch on a measured CONTAINER width. Dart
/// gets the same behaviour from [LayoutBuilder], and it is the better tool: a
/// screen embedded in a narrow panel or a split view reflows the same way it would
/// on a phone, which a MediaQuery-based rule would get wrong.
enum SkBreakpoint {
  /// Under 640. One column, bottom tab bar, tappable rows, 44px targets.
  sm,

  /// 640 to 1023. Side nav collapses to icons, two columns where they help.
  md,

  /// 1024 and up. Full chrome, dense tables, side rails.
  lg;

  static const double mdMin = 640;
  static const double lgMin = 1024;

  static SkBreakpoint forWidth(double width) {
    if (width >= lgMin) return SkBreakpoint.lg;
    if (width >= mdMin) return SkBreakpoint.md;
    return SkBreakpoint.sm;
  }

  bool get isSm => this == SkBreakpoint.sm;
  bool get isMd => this == SkBreakpoint.md;
  bool get isLg => this == SkBreakpoint.lg;

  /// True from md upward — the common test for "is there room for chrome".
  bool get isWide => this != SkBreakpoint.sm;

  /// Pick a value per breakpoint. [md] falls back to [sm] when omitted, so the
  /// common two-way split stays short.
  T pick<T>({required T sm, T? md, required T lg}) => switch (this) {
        SkBreakpoint.sm => sm,
        SkBreakpoint.md => md ?? sm,
        SkBreakpoint.lg => lg,
      };
}

/// Measures its own width and hands the breakpoint to [builder].
///
/// Put one of these at the top of a screen, not around every widget — passing the
/// breakpoint down explicitly keeps it obvious which parts of a layout respond.
class SkResponsive extends StatelessWidget {
  const SkResponsive({super.key, required this.builder});

  final Widget Function(BuildContext context, SkBreakpoint bp, double width) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, SkBreakpoint.forWidth(width), width);
      },
    );
  }
}

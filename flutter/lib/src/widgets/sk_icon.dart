import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_glyph.dart';

// Re-exported so `import 'sk_icon.dart'` still names the glyph type, which is
// what every control that takes an icon does.
export '../tokens/sk_glyph.dart' show SkGlyph, SkIconFont, skIconFontPackage;

/// Which Phosphor weight to draw. One job each.
enum SkIconWeight {
  /// All UI. The default.
  regular,

  /// 14px and under, and inside solid accent buttons, where regular strokes thin
  /// out against the fill.
  bold,

  /// Marks ACTIVE — the current tab or nav item, a saved trip, a locked lineup.
  /// Nothing else.
  fill,

  /// Empty states and slides only, where an icon is decorative rather than
  /// functional.
  duotone,
}

/// Phosphor icon at a system size and weight.
///
/// Always go through this rather than a bare [Icon], so the weight rules and
/// the 20px default live in one place. Icons inherit the surrounding text colour
/// and are never accent-coloured unless the text beside them is.
///
///     SkIcon(SkIcons.mapPin)
///     SkIcon(SkIcons.mapPin, weight: SkIconWeight.fill)
class SkIcon extends StatelessWidget {
  const SkIcon(
    this.glyph, {
    super.key,
    this.size = 20,
    this.weight = SkIconWeight.regular,
    this.color,
    this.semanticLabel,
  });

  final SkGlyph glyph;

  /// 20 is the UI default. 16 in dense rows and small controls, 24 in mobile tab
  /// bars, 32 and up only in empty states.
  final double size;

  final SkIconWeight weight;

  /// Defaults to the inherited text colour.
  final Color? color;

  /// Set on icon-only controls. Leave null elsewhere so decorative icons stay out
  /// of the accessibility tree.
  final String? semanticLabel;

  /// Phosphor's duotone glyphs are a pair: a solid backdrop under a line layer.
  /// Both are drawn in the same colour and the backdrop is knocked back, which is
  /// what keeps a duotone icon reading as one mark rather than two.
  static const double _duotoneBackdropOpacity = 0.20;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ??
        DefaultTextStyle.of(context).style.color ??
        context.skColors.textPrimary;

    if (weight == SkIconWeight.duotone) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: _duotoneBackdropOpacity,
            child: Icon(glyph.duotoneSecondary, size: size, color: resolved),
          ),
          Icon(
            glyph.duotone,
            size: size,
            color: resolved,
            semanticLabel: semanticLabel,
          ),
        ],
      );
    }

    return Icon(
      switch (weight) {
        SkIconWeight.regular => glyph.regular,
        SkIconWeight.bold => glyph.bold,
        SkIconWeight.fill => glyph.fill,
        SkIconWeight.duotone => glyph.duotone, // handled above
      },
      size: size,
      color: resolved,
      semanticLabel: semanticLabel,
    );
  }
}

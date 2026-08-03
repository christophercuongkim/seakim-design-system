import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/sk_theme.dart';

/// A Phosphor glyph, before a weight has been chosen.
///
/// In phosphor_flutter 2.x each glyph is exposed as a function that takes an
/// optional style, so PhosphorIcons.mapPin is itself a value of this type. That
/// is what lets [SkIcon] own the weight decision instead of the caller:
///
///     SkIcon(PhosphorIcons.mapPin)                      // regular
///     SkIcon(PhosphorIcons.mapPin, weight: SkIconWeight.fill)
typedef SkGlyph = PhosphorIconData Function([PhosphorIconsStyle style]);

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
/// Always go through this rather than a bare PhosphorIcon, so the weight rules and
/// the 20px default live in one place. Icons inherit the surrounding text colour
/// and are never accent-coloured unless the text beside them is.
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

  static PhosphorIconsStyle _style(SkIconWeight w) => switch (w) {
        SkIconWeight.regular => PhosphorIconsStyle.regular,
        SkIconWeight.bold => PhosphorIconsStyle.bold,
        SkIconWeight.fill => PhosphorIconsStyle.fill,
        SkIconWeight.duotone => PhosphorIconsStyle.duotone,
      };

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ??
        DefaultTextStyle.of(context).style.color ??
        context.skColors.textPrimary;
    return PhosphorIcon(
      glyph(_style(weight)),
      size: size,
      color: resolved,
      semanticLabel: semanticLabel,
    );
  }
}

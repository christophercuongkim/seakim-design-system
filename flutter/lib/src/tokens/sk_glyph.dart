import 'package:flutter/widgets.dart';

/// Font families bundled by this package, one per Phosphor weight.
///
/// Declared in `pubspec.yaml` against the `.ttf` files in `assets/icons/`.
/// [skIconFontPackage] must travel with every [IconData] so the glyphs still
/// resolve when SeaKim is consumed as a package dependency rather than run
/// from this repo.
class SkIconFont {
  const SkIconFont._();

  static const String regular = 'PhosphorRegular';
  static const String bold = 'PhosphorBold';
  static const String fill = 'PhosphorFill';
  static const String duotone = 'PhosphorDuotone';
}

/// The package that owns the icon fonts. See [SkIconFont].
const String skIconFontPackage = 'seakim_flutter';

/// One Phosphor glyph, carrying every weight it can be drawn in.
///
/// A glyph is weight-agnostic on purpose: the caller names *what* to draw and
/// `SkIcon` decides *how heavy* to draw it, so the weight rules live in one
/// place. See `SkIcons` in `sk_icons.g.dart` for the generated set:
///
///     SkIcon(SkIcons.mapPin)                             // regular
///     SkIcon(SkIcons.mapPin, weight: SkIconWeight.fill)  // active
///
/// Every field is a `const IconData` rather than a code point resolved at
/// render time. That is deliberate: Flutter's `--tree-shake-icons` pass only
/// recognises const `IconData`, and without it all four fonts (~2 MB) ship
/// whole instead of just the glyphs actually used.
@immutable
class SkGlyph {
  const SkGlyph({
    required this.regular,
    required this.bold,
    required this.fill,
    required this.duotone,
    required this.duotoneSecondary,
  });

  final IconData regular;
  final IconData bold;
  final IconData fill;

  /// Foreground layer of the duotone pair.
  final IconData duotone;

  /// Background layer, drawn beneath [duotone] at reduced opacity.
  final IconData duotoneSecondary;
}

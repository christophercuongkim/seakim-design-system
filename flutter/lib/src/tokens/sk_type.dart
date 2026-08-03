import 'dart:ui' show FontFeature;

import 'package:flutter/widgets.dart';

/// Three families, strictly divided by job. Bundled as assets — see pubspec.yaml.
class SkFonts {
  const SkFonts._();

  /// Display and headings. Wide and geometric; earns its keep above 17px.
  static const String display = 'Outfit';

  /// UI and body. Geometric skeleton, humanist apertures — legible at 13px.
  static const String sans = 'PlusJakartaSans';

  /// Data and eyebrows. Prices, times, codes, stat lines.
  static const String mono = 'IBMPlexMono';
}

class SkFontSize {
  const SkFontSize._();

  static const double xs2 = 10;
  static const double xs = 11;
  static const double sm = 13; // UI default
  static const double md = 15; // body default
  static const double lg = 17;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 30;
  static const double xl4 = 38;
  static const double xl5 = 48;
  static const double xl6 = 60;
  static const double xl7 = 76;
}

/// Composed roles. Use these rather than assembling raw sizes — they carry the
/// family, weight, line height, and tracking decisions together.
///
/// Flutter's height property is a multiplier of font size, exactly like a unitless
/// CSS line-height, so these values match the CSS one for one. Letter spacing in
/// Flutter is absolute pixels rather than em, so each style multiplies its own
/// size by the em value from the CSS.
class SkText {
  const SkText._();

  static const TextStyle display = TextStyle(
    fontFamily: SkFonts.display,
    fontSize: SkFontSize.xl5,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: SkFontSize.xl5 * -0.03,
  );

  static const TextStyle title = TextStyle(
    fontFamily: SkFonts.display,
    fontSize: SkFontSize.xl3,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: SkFontSize.xl3 * -0.03,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: SkFonts.display,
    fontSize: SkFontSize.xl,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: SkFontSize.xl * -0.018,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: SkFonts.display,
    fontSize: SkFontSize.lg,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: SkFontSize.lg * -0.018,
  );

  static const TextStyle body = TextStyle(
    fontFamily: SkFonts.sans,
    fontSize: SkFontSize.md,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: SkFonts.sans,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle label = TextStyle(
    fontFamily: SkFonts.sans,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: SkFonts.sans,
    fontSize: SkFontSize.xs,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Tabular by default, so columns of figures always align.
  static const TextStyle data = TextStyle(
    fontFamily: SkFonts.mono,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Uppercase section labels. Apply the capitals yourself with toUpperCase, so
  /// the original string stays readable in source and in Semantics.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: SkFonts.mono,
    fontSize: SkFontSize.xs2,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: SkFontSize.xs2 * 0.10,
  );

  /// Add to any figure that sits in a column.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

import 'package:flutter/widgets.dart';

/// One text family, plus mono for data. Bundled as VARIABLE assets — see pubspec.yaml.
/// Every style therefore carries `fontVariations` alongside `fontWeight`: the wght
/// axis is what actually moves on a variable font, and relying on `fontWeight`
/// alone risks a synthesised bold on some backends instead of the real cut.
/// The package that bundles the text fonts. A TextStyle must carry this or
/// the family resolves only when the *app* happens to declare it too — which
/// silently falls back to the platform font for every consuming app.
const String skFontPackage = 'seakim_flutter';

class SkFonts {
  const SkFonts._();

  /// The display SLOT. Points at the text face today (0031) — SeaKim has one
  /// text family. Kept as its own name so a future display face is one edit
  /// here, picked up by the wordmark, every heading and the deck chrome at once.
  static const String display = 'InstrumentSans';

  /// UI and body. The one text family.
  static const String sans = 'InstrumentSans';

  /// Data and eyebrows. Prices, times, codes, stat lines.
  static const String mono = 'JetBrainsMono';
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
    package: skFontPackage,
    fontSize: SkFontSize.xl5,
    fontWeight: FontWeight.w600,
    fontVariations: const <FontVariation>[FontVariation('wght', 600)],
    height: 1.1,
    letterSpacing: SkFontSize.xl5 * -0.03,
  );

  static const TextStyle title = TextStyle(
    fontFamily: SkFonts.display,
    package: skFontPackage,
    fontSize: SkFontSize.xl3,
    fontWeight: FontWeight.w600,
    fontVariations: const <FontVariation>[FontVariation('wght', 600)],
    height: 1.1,
    letterSpacing: SkFontSize.xl3 * -0.03,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: SkFonts.display,
    package: skFontPackage,
    fontSize: SkFontSize.xl,
    fontWeight: FontWeight.w600,
    fontVariations: const <FontVariation>[FontVariation('wght', 600)],
    height: 1.3,
    letterSpacing: SkFontSize.xl * -0.018,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: SkFonts.display,
    package: skFontPackage,
    fontSize: SkFontSize.lg,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[FontVariation('wght', 500)],
    height: 1.3,
    letterSpacing: SkFontSize.lg * -0.018,
  );

  static const TextStyle body = TextStyle(
    fontFamily: SkFonts.sans,
    package: skFontPackage,
    fontSize: SkFontSize.md,
    fontWeight: FontWeight.w400,
    fontVariations: const <FontVariation>[FontVariation('wght', 400)],
    height: 1.55,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: SkFonts.sans,
    package: skFontPackage,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w400,
    fontVariations: const <FontVariation>[FontVariation('wght', 400)],
    height: 1.55,
  );

  static const TextStyle label = TextStyle(
    fontFamily: SkFonts.sans,
    package: skFontPackage,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w600,
    fontVariations: const <FontVariation>[FontVariation('wght', 600)],
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: SkFonts.sans,
    package: skFontPackage,
    fontSize: SkFontSize.xs,
    fontWeight: FontWeight.w400,
    fontVariations: const <FontVariation>[FontVariation('wght', 400)],
    height: 1.3,
  );

  /// Tabular by default, so columns of figures always align.
  static const TextStyle data = TextStyle(
    fontFamily: SkFonts.mono,
    package: skFontPackage,
    fontSize: SkFontSize.sm,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[FontVariation('wght', 500)],
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Uppercase section labels. Apply the capitals yourself with toUpperCase, so
  /// the original string stays readable in source and in Semantics.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: SkFonts.mono,
    package: skFontPackage,
    fontSize: SkFontSize.xs2,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[FontVariation('wght', 500)],
    height: 1.2,
    letterSpacing: SkFontSize.xs2 * 0.10,
  );

  /// Add to any figure that sits in a column.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

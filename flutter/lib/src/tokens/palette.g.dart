// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Regenerate with:  dart run tool/gen_tokens.dart
//
// Source of truth is ../../../tokens/colors.css. The brand ramps there are
// written as oklch(L C H) with H rotating per app; Dart cannot evaluate oklch, so
// every step is converted to sRGB here. Conversion uses chroma-reduction gamut
// mapping, so a few steps sit at slightly lower chroma than the CSS asks for
// rather than being naively clipped, which would shift hue.

import 'dart:ui' show Color;

/// One app's accent ramp. Steps mirror the CSS custom properties
/// --brand-050 through --brand-900, plus --brand-wash.
class SkBrandRamp {
  const SkBrandRamp({
    required this.s050,
    required this.s100,
    required this.s200,
    required this.s300,
    required this.s400,
    required this.s500,
    required this.s600,
    required this.s700,
    required this.s800,
    required this.s900,
    required this.wash,
  });

  final Color s050;
  final Color s100;
  final Color s200;
  final Color s300;
  final Color s400;
  final Color s500;
  final Color s600;
  final Color s700;
  final Color s800;
  final Color s900;
  final Color wash;
}

/// The accent ramp for each app. Adding an app means adding a hue in
/// tokens/colors.css and re-running the generator — never hand-typing colours.
class SkBrandRamps {
  const SkBrandRamps._();

  /// oklch(L C 55) — SeaKim house, decks
  static const SkBrandRamp clay = SkBrandRamp(
    s050: Color(0xFFFEEEE4),
    s100: Color(0xFFFADAC6),
    s200: Color(0xFFF2BE9C),
    s300: Color(0xFFF0AD7F),
    s400: Color(0xFFE28D4F),
    s500: Color(0xFFCB7229),
    s600: Color(0xFFB05A00),
    s700: Color(0xFF874300),
    s800: Color(0xFF602D00),
    s900: Color(0xFF3C1900),
    wash: Color(0xFF2F1908),
  );

  /// oklch(L C 245) — Voyage, travel
  static const SkBrandRamp sea = SkBrandRamp(
    s050: Color(0xFFE7F4FF),
    s100: Color(0xFFC9E5FE),
    s200: Color(0xFFA2D0F9),
    s300: Color(0xFF86C5FA),
    s400: Color(0xFF56ACF0),
    s500: Color(0xFF3093DB),
    s600: Color(0xFF037AC0),
    s700: Color(0xFF005C94),
    s800: Color(0xFF00406A),
    s900: Color(0xFF002642),
    wash: Color(0xFF0A2133),
  );

  /// oklch(L C 145) — Bench, fantasy sport
  static const SkBrandRamp turf = SkBrandRamp(
    s050: Color(0xFFE9F6E9),
    s100: Color(0xFFD0EACF),
    s200: Color(0xFFADD8AD),
    s300: Color(0xFF95CF96),
    s400: Color(0xFF6DBA70),
    s500: Color(0xFF4EA253),
    s600: Color(0xFF34893C),
    s700: Color(0xFF226929),
    s800: Color(0xFF14491A),
    s900: Color(0xFF082C0C),
    wash: Color(0xFF102511),
  );

  /// oklch(L C 320) — reserved for app three
  static const SkBrandRamp plum = SkBrandRamp(
    s050: Color(0xFFF9EDFB),
    s100: Color(0xFFEFD8F4),
    s200: Color(0xFFE1BBE9),
    s300: Color(0xFFDBA9E6),
    s400: Color(0xFFC889D7),
    s500: Color(0xFFB16EC0),
    s600: Color(0xFF9856A7),
    s700: Color(0xFF753E81),
    s800: Color(0xFF522A5C),
    s900: Color(0xFF321739),
    wash: Color(0xFF29182C),
  );
}

/// The warm achromatic spine. Hex values, copied verbatim from the CSS.
class SkStone {
  const SkStone._();

  static const Color s0 = Color(0xFFFFFFFF);
  static const Color s50 = Color(0xFFFAF9F7);
  static const Color s100 = Color(0xFFF0EFEC);
  static const Color s200 = Color(0xFFE0DEDA);
  static const Color s300 = Color(0xFFC6C3BD);
  static const Color s400 = Color(0xFFA09C95);
  static const Color s500 = Color(0xFF7C7873);
  static const Color s600 = Color(0xFF5C5955);
  static const Color s700 = Color(0xFF413F3C);
  static const Color s800 = Color(0xFF2B2A27);
  static const Color s850 = Color(0xFF211F1D);
  static const Color s900 = Color(0xFF181614);
  static const Color s950 = Color(0xFF0F0E0D);
}

/// Status ramps. The 400 step is tuned for dark surfaces, 500 for light.
class SkStatusPalette {
  const SkStatusPalette._();

  static const Color success400 = Color(0xFF6BD185);
  static const Color success500 = Color(0xFF2E9E52);
  static const Color warning400 = Color(0xFFEEBC4A);
  static const Color warning500 = Color(0xFFCB8900);
  static const Color danger400 = Color(0xFFF67972);
  static const Color danger500 = Color(0xFFD94543);
  static const Color info400 = Color(0xFF62BBF5);
  static const Color info500 = Color(0xFF177DD1);

  static const Color successSubtleDark = Color(0xFF17351F);
  static const Color warningSubtleDark = Color(0xFF3C2A07);
  static const Color dangerSubtleDark = Color(0xFF491F1D);
  static const Color infoSubtleDark = Color(0xFF133047);

  static const Color successTextLight = Color(0xFF067132);
  static const Color warningTextLight = Color(0xFF856300);
  static const Color dangerTextLight = Color(0xFFB33736);
  static const Color infoTextLight = Color(0xFF006A9E);

  static const Color successSubtleLight = Color(0xFFE4F8E7);
  static const Color warningSubtleLight = Color(0xFFFEF0D4);
  static const Color dangerSubtleLight = Color(0xFFFFEDEB);
  static const Color infoSubtleLight = Color(0xFFE6F4FF);
}

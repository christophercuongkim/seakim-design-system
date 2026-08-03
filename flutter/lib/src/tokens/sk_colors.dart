import 'package:flutter/widgets.dart';

import 'palette.g.dart';

/// Which app's accent is live. The Dart equivalent of data-app on the html element.
enum SkAppBrand {
  seakim(SkBrandRamps.clay),
  voyage(SkBrandRamps.sea),
  bench(SkBrandRamps.turf),
  reserve(SkBrandRamps.plum);

  const SkAppBrand(this.ramp);
  final SkBrandRamp ramp;
}

/// The Dart equivalent of data-theme.
enum SkThemeMode { dark, light }

/// The semantic colour layer — the only colours widgets are allowed to read.
///
/// Reaching past this into [SkStone] or a raw [SkBrandRamp] step is the Dart
/// equivalent of hardcoding --stone-900: it breaks theme and app switching.
@immutable
class SkColors {
  const SkColors({
    required this.brightness,
    required this.surfacePage,
    required this.surfaceSunken,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.surfaceInset,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.surfaceSelected,
    required this.surfaceScrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.textAccent,
    required this.textLink,
    required this.textLinkHover,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderAccent,
    required this.borderFocus,
    required this.fillAccent,
    required this.fillAccentHover,
    required this.fillAccentActive,
    required this.onAccent,
    required this.fillNeutral,
    required this.fillNeutralHover,
    required this.fillNeutralActive,
    required this.textSuccess,
    required this.textWarning,
    required this.textDanger,
    required this.textInfo,
    required this.fillSuccessSubtle,
    required this.fillWarningSubtle,
    required this.fillDangerSubtle,
    required this.fillInfoSubtle,
    required this.fillDanger,
    required this.onDanger,
  });

  final Brightness brightness;

  final Color surfacePage;
  final Color surfaceSunken;
  final Color surfaceCard;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color surfaceInset;
  final Color surfaceHover;
  final Color surfaceActive;
  final Color surfaceSelected;
  final Color surfaceScrim;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color textAccent;
  final Color textLink;
  final Color textLinkHover;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderAccent;
  final Color borderFocus;

  final Color fillAccent;
  final Color fillAccentHover;
  final Color fillAccentActive;
  final Color onAccent;

  final Color fillNeutral;
  final Color fillNeutralHover;
  final Color fillNeutralActive;

  final Color textSuccess;
  final Color textWarning;
  final Color textDanger;
  final Color textInfo;
  final Color fillSuccessSubtle;
  final Color fillWarningSubtle;
  final Color fillDangerSubtle;
  final Color fillInfoSubtle;
  final Color fillDanger;
  final Color onDanger;

  bool get isDark => brightness == Brightness.dark;

  /// Mirrors the dark block in tokens/colors.css. Dark is the default theme.
  factory SkColors.dark(SkBrandRamp brand) => SkColors(
        brightness: Brightness.dark,
        surfacePage: SkStone.s950,
        surfaceSunken: const Color(0xFF0A0908),
        surfaceCard: SkStone.s900,
        surfaceRaised: SkStone.s850,
        surfaceOverlay: SkStone.s800,
        surfaceInset: const Color(0xFF0A0908),
        surfaceHover: SkStone.s800,
        surfaceActive: SkStone.s700,
        surfaceSelected: brand.wash,
        // warm black at 68%
        surfaceScrim: const Color(0xAD000000),
        textPrimary: const Color(0xFFF5F3F0),
        textSecondary: SkStone.s400,
        textTertiary: SkStone.s500,
        textInverse: SkStone.s950,
        textAccent: brand.s300,
        textLink: brand.s300,
        textLinkHover: brand.s200,
        borderSubtle: const Color(0xFF2A2724),
        borderDefault: const Color(0xFF383431),
        borderStrong: const Color(0xFF4C4844),
        borderAccent: brand.s400,
        borderFocus: brand.s400,
        fillAccent: brand.s400,
        fillAccentHover: brand.s300,
        fillAccentActive: brand.s500,
        onAccent: SkStone.s950,
        fillNeutral: SkStone.s800,
        fillNeutralHover: SkStone.s700,
        fillNeutralActive: SkStone.s600,
        textSuccess: SkStatusPalette.success400,
        textWarning: SkStatusPalette.warning400,
        textDanger: SkStatusPalette.danger400,
        textInfo: SkStatusPalette.info400,
        fillSuccessSubtle: SkStatusPalette.successSubtleDark,
        fillWarningSubtle: SkStatusPalette.warningSubtleDark,
        fillDangerSubtle: SkStatusPalette.dangerSubtleDark,
        fillInfoSubtle: SkStatusPalette.infoSubtleDark,
        fillDanger: SkStatusPalette.danger500,
        onDanger: const Color(0xFFFDF6F4),
      );

  /// Mirrors tokens/theme-light.css. A peer of dark, not a filter of it — the card
  /// is pure white on an off-white page, the inverse of dark mode's logic.
  factory SkColors.light(SkBrandRamp brand) => SkColors(
        brightness: Brightness.light,
        surfacePage: SkStone.s50,
        surfaceSunken: SkStone.s100,
        surfaceCard: SkStone.s0,
        surfaceRaised: SkStone.s0,
        surfaceOverlay: SkStone.s0,
        surfaceInset: SkStone.s100,
        surfaceHover: SkStone.s100,
        surfaceActive: SkStone.s200,
        surfaceSelected: brand.s050,
        // stone-800 at 40%
        surfaceScrim: const Color(0x662B2A27),
        textPrimary: SkStone.s900,
        textSecondary: SkStone.s600,
        textTertiary: SkStone.s500,
        textInverse: SkStone.s50,
        textAccent: brand.s600,
        textLink: brand.s600,
        textLinkHover: brand.s700,
        borderSubtle: SkStone.s200,
        borderDefault: SkStone.s300,
        borderStrong: SkStone.s400,
        borderAccent: brand.s500,
        borderFocus: brand.s600,
        fillAccent: brand.s500,
        fillAccentHover: brand.s600,
        fillAccentActive: brand.s700,
        onAccent: SkStone.s950,
        fillNeutral: SkStone.s100,
        fillNeutralHover: SkStone.s200,
        fillNeutralActive: SkStone.s300,
        textSuccess: SkStatusPalette.successTextLight,
        textWarning: SkStatusPalette.warningTextLight,
        textDanger: SkStatusPalette.dangerTextLight,
        textInfo: SkStatusPalette.infoTextLight,
        fillSuccessSubtle: SkStatusPalette.successSubtleLight,
        fillWarningSubtle: SkStatusPalette.warningSubtleLight,
        fillDangerSubtle: SkStatusPalette.dangerSubtleLight,
        fillInfoSubtle: SkStatusPalette.infoSubtleLight,
        fillDanger: SkStatusPalette.danger500,
        onDanger: SkStone.s50,
      );
}

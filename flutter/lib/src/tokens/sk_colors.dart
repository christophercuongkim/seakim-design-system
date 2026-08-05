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
    required this.fillDisabled,
    required this.textDisabled,
    required this.borderDisabled,
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

  /// Accent at the selection weight. Selected text tints its background rather
  /// than replacing it, so the glyphs keep their own colour — which is why this
  /// carries alpha instead of being a flat step. Derived here rather than in a
  /// widget: per decision 0013, an alpha variant is a token.
  Color get fillAccentSelection => fillAccent.withValues(alpha: 0.32);
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

  /// Disabled is a TOKEN, not an opacity pass.
  ///
  /// Blanket opacity survives dark — everything fades toward the near-black page
  /// and the fill/text relationship holds. In light it fades toward white and
  /// collapses, so a disabled accent button becomes pale-on-pale. Per decision
  /// 0005, a value that only works in one theme is not semantic.
  final Color fillDisabled;
  final Color textDisabled;
  final Color borderDisabled;

  bool get isDark => brightness == Brightness.dark;

  /// Mirrors the dark block in tokens/colors.css. Dark is the default theme.
  factory SkColors.dark(SkBrandRamp brand) => SkColors(
        brightness: Brightness.dark,
        surfacePage: SkStone.s950,
        surfaceSunken: SkRawColors.surfaceSunkenDark,
        surfaceCard: SkStone.s900,
        surfaceRaised: SkStone.s850,
        surfaceOverlay: SkStone.s800,
        surfaceInset: SkRawColors.surfaceSunkenDark,
        surfaceHover: SkStone.s800,
        surfaceActive: SkStone.s700,
        surfaceSelected: brand.wash,
        // warm black at 68%
        surfaceScrim: SkRawColors.scrimDark,
        textPrimary: SkRawColors.textPrimaryDark,
        textSecondary: SkStone.s400,
        textTertiary: SkStone.s500,
        textInverse: SkStone.s950,
        textAccent: brand.s300,
        textLink: brand.s300,
        textLinkHover: brand.s200,
        borderSubtle: SkRawColors.borderSubtleDark,
        borderDefault: SkRawColors.borderDefaultDark,
        borderStrong: SkRawColors.borderStrongDark,
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
        onDanger: SkRawColors.onDangerDark,
        fillDisabled: SkStone.s800,
        textDisabled: SkStone.s600,
        borderDisabled: SkRawColors.borderDisabledDark,
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
        surfaceScrim: SkRawColors.scrimLight,
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
        fillDisabled: SkStone.s100,
        textDisabled: SkStone.s400,
        borderDisabled: SkStone.s200,
      );
}

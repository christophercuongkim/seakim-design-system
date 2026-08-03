import 'package:flutter/material.dart';

import 'sk_theme.dart';

/// Puts SeaKim tokens in scope beneath a [MaterialApp], so `Sk*` widgets can be
/// mixed into an app that is otherwise Material.
///
/// The mode follows the ambient Material brightness, so one wrapper tracks
/// `themeMode` without being told twice:
///
///     MaterialApp(
///       theme: SkMaterialTheme.light(SkAppBrand.voyage),
///       darkTheme: SkMaterialTheme.dark(SkAppBrand.voyage),
///       builder: (context, child) =>
///           SkThemeScope(brand: SkAppBrand.voyage, child: child!),
///       home: MyScreen(),
///     )
class SkThemeScope extends StatelessWidget {
  const SkThemeScope({super.key, required this.brand, required this.child});

  final SkAppBrand brand;
  final Widget child;

  @override
  Widget build(BuildContext context) => SkTheme(
        data: SkThemeData.of(
          brand,
          Theme.of(context).brightness == Brightness.dark
              ? SkThemeMode.dark
              : SkThemeMode.light,
        ),
        child: child,
      );
}

/// SeaKim as a Material [ThemeData], for apps that already exist.
///
/// The rest of this package replaces Material rather than themes it. This is the
/// on-ramp for the other order of work: build the app with stock Material
/// widgets, get it functioning, then drop SeaKim in and have the whole thing
/// take the brand at once — no widget rewrites.
///
///     MaterialApp(
///       theme: SkMaterialTheme.light(SkAppBrand.voyage),
///       darkTheme: SkMaterialTheme.dark(SkAppBrand.voyage),
///       home: MyAlreadyWorkingScreen(),
///     )
///
/// **What this carries:** colour, typography, square corners, elevation
/// discipline, hairline dividers and borders, focus colour, and no ink ripple.
///
/// **What it cannot:** the scale-press (Material exposes no hook for it),
/// duotone empty states, and the exact focus-ring geometry. Those live in the
/// `Sk*` widgets. So the theme gets you the *look* and the widgets get you the
/// *feel* — adopt the theme first, then swap widgets where fidelity matters.
///
/// `Sk*` widgets read their tokens from [SkTheme], not from Material, so wrap
/// the app in [SkThemeScope] (or [SkApp]) if you intend to mix the two. Under a
/// [MaterialApp] the `Overlay`, `Navigator`, and `MediaQuery` that `SkToast`,
/// `SkDialog`, and `SkSelect` need are all present already.
class SkMaterialTheme {
  const SkMaterialTheme._();

  static ThemeData dark(SkAppBrand brand) =>
      _build(SkColors.dark(brand.ramp), Brightness.dark);

  static ThemeData light(SkAppBrand brand) =>
      _build(SkColors.light(brand.ramp), Brightness.light);

  /// Build from an explicit palette, e.g. one already resolved from an
  /// [SkThemeData].
  static ThemeData from(SkColors c) => _build(c, c.brightness);

  static ThemeData _build(SkColors c, Brightness brightness) {
    // Square, always. This is the decision Material resists hardest, so it is
    // restated on every component that ships its own default shape.
    const RoundedRectangleBorder square =
        RoundedRectangleBorder(borderRadius: BorderRadius.zero);
    final BorderSide hairline =
        BorderSide(color: c.borderDefault, width: SkDepth.hairline);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.fillAccent,
      onPrimary: c.onAccent,
      secondary: c.fillNeutral,
      onSecondary: c.textPrimary,
      error: c.fillDanger,
      onError: c.onDanger,
      surface: c.surfaceCard,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceRaised,
      surfaceContainerHigh: c.surfaceOverlay,
      surfaceContainerLow: c.surfaceSunken,
      outline: c.borderDefault,
      outlineVariant: c.borderSubtle,
      shadow: const Color(0xFF000000),
      scrim: c.surfaceScrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.textInverse,
    );

    final TextTheme text = TextTheme(
      displayLarge: SkText.display,
      displayMedium: SkText.title,
      displaySmall: SkText.title,
      headlineLarge: SkText.title,
      headlineMedium: SkText.heading,
      headlineSmall: SkText.heading,
      titleLarge: SkText.heading,
      titleMedium: SkText.subheading,
      titleSmall: SkText.subheading,
      bodyLarge: SkText.body,
      bodyMedium: SkText.bodySm,
      bodySmall: SkText.caption,
      labelLarge: SkText.label,
      labelMedium: SkText.label,
      labelSmall: SkText.eyebrow,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfacePage,
      canvasColor: c.surfacePage,
      dividerColor: c.borderSubtle,
      textTheme: text,
      fontFamily: SkFonts.sans,
      fontFamilyFallback: const <String>[SkFonts.sans],

      // No ink ripple anywhere. The system presses by scaling instead, which
      // Material cannot express — but suppressing the ripple is most of the
      // distance, and SkPressable covers the rest.
      splashFactory: NoSplash.splashFactory,
      highlightColor: c.surfaceHover,
      splashColor: const Color(0x00000000),
      hoverColor: c.surfaceHover,
      focusColor: c.borderFocus,

      dividerTheme: DividerThemeData(
        color: c.borderSubtle,
        thickness: SkDepth.hairline,
        space: SkDepth.hairline,
      ),

      // Shadows are for things that float. A card does not float.
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: hairline),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.surfacePage,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: SkText.subheading.copyWith(color: c.textPrimary),
        shape: Border(bottom: BorderSide(color: c.borderSubtle, width: SkDepth.hairline)),
      ),

      // These do float, so they keep their lift — via our shadow, not Material's.
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceOverlay,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: hairline),
        titleTextStyle: SkText.heading.copyWith(color: c.textPrimary),
        contentTextStyle: SkText.bodySm.copyWith(color: c.textSecondary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceOverlay,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: hairline),
        textStyle: SkText.bodySm.copyWith(color: c.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceOverlay,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceOverlay,
          border: Border.all(color: c.borderStrong, width: SkDepth.hairline),
        ),
        textStyle: SkText.caption.copyWith(color: c.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceOverlay,
        contentTextStyle: SkText.bodySm.copyWith(color: c.textPrimary),
        actionTextColor: c.textAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: hairline),
        behavior: SnackBarBehavior.floating,
      ),

      filledButtonTheme: FilledButtonThemeData(style: _button(c, square, filled: true)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _button(c, square, filled: true)),
      textButtonTheme: TextButtonThemeData(style: _button(c, square, filled: false)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _button(c, square, filled: false).copyWith(
          side: WidgetStatePropertyAll<BorderSide>(hairline),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SkSpace.s4,
          vertical: SkSpace.s4,
        ),
        hintStyle: SkText.bodySm.copyWith(color: c.textTertiary),
        labelStyle: SkText.bodySm.copyWith(color: c.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: hairline),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: hairline),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.borderFocus, width: SkDepth.emphasis),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.textDanger, width: SkDepth.hairline),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: square,
        side: BorderSide(color: c.borderDefault, width: SkDepth.hairline),
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.fillAccent : c.surfaceRaised),
        checkColor: WidgetStatePropertyAll<Color>(c.onAccent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.fillAccent : c.borderDefault),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll<Color>(c.onAccent),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.fillAccent : c.fillNeutral),
        trackOutlineColor: WidgetStatePropertyAll<Color>(c.borderDefault),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceRaised,
        selectedColor: c.surfaceSelected,
        labelStyle: SkText.caption.copyWith(color: c.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: hairline),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textAccent,
        unselectedLabelColor: c.textSecondary,
        labelStyle: SkText.label,
        unselectedLabelStyle: SkText.label,
        indicatorColor: c.fillAccent,
        dividerColor: c.borderSubtle,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.fillAccent,
        linearTrackColor: c.surfaceInset,
      ),
      iconTheme: IconThemeData(color: c.textSecondary, size: 20),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: SkText.bodySm.copyWith(color: c.textPrimary),
        subtitleTextStyle: SkText.caption.copyWith(color: c.textTertiary),
        shape: square,
      ),
    );
  }

  static ButtonStyle _button(SkColors c, OutlinedBorder shape, {required bool filled}) {
    return ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
      elevation: const WidgetStatePropertyAll<double>(0),
      splashFactory: NoSplash.splashFactory,
      textStyle: WidgetStatePropertyAll<TextStyle>(SkText.label),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: SkSpace.s5),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(0, SkControl.md)),
      backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (!filled) return const Color(0x00000000);
        if (s.contains(WidgetState.disabled)) return c.fillNeutral;
        if (s.contains(WidgetState.pressed)) return c.fillAccentActive;
        if (s.contains(WidgetState.hovered)) return c.fillAccentHover;
        return c.fillAccent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.disabled)) return c.textTertiary;
        return filled ? c.onAccent : c.textAccent;
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
          s.contains(WidgetState.hovered) ? c.surfaceHover : const Color(0x00000000)),
    );
  }
}

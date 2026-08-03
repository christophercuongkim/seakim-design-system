/// SeaKim design system for Flutter.
///
/// One warm-neutral chassis shared by every SeaKim product, with exactly one accent
/// hue live at a time. Dark is the default. Corners are square. Borders define,
/// shadows lift.
///
/// Getting started:
///
///     void main() => runApp(
///       const SkApp(
///         brand: SkAppBrand.voyage,
///         mode: SkThemeMode.dark,
///         child: MyHomeScreen(),
///       ),
///     );
///
/// Inside a widget, read tokens from the context:
///
///     final SkColors c = context.skColors;
///
/// Responsive layouts branch on a measured container width, not a MediaQuery:
///
///     SkResponsive(
///       builder: (context, bp, width) => bp.isSm ? const _Stacked() : const _Wide(),
///     )
library seakim_flutter;

export 'src/tokens/sk_glyph.dart';
export 'src/tokens/sk_icons.g.dart';
export 'src/tokens/sk_licenses.dart';

export 'src/theme/sk_theme.dart';
export 'src/theme/sk_material_theme.dart';
export 'src/theme/sk_breakpoints.dart';

export 'src/widgets/sk_avatar.dart';
export 'src/widgets/sk_badge.dart';
export 'src/widgets/sk_button.dart';
export 'src/widgets/sk_card.dart';
export 'src/widgets/sk_checkbox.dart';
export 'src/widgets/sk_dialog.dart';
export 'src/widgets/sk_empty_state.dart';
export 'src/widgets/sk_field.dart';
export 'src/widgets/sk_icon.dart';
export 'src/widgets/sk_icon_button.dart';
export 'src/widgets/sk_input.dart';
export 'src/widgets/sk_pressable.dart';
export 'src/widgets/sk_radio.dart';
export 'src/widgets/sk_segmented_control.dart';
export 'src/widgets/sk_select.dart';
export 'src/widgets/sk_side_nav.dart';
export 'src/widgets/sk_stat.dart';
export 'src/widgets/sk_switch.dart';
export 'src/widgets/sk_tab_bar.dart';
export 'src/widgets/sk_tabs.dart';
export 'src/widgets/sk_tag.dart';
export 'src/widgets/sk_textarea.dart';
export 'src/widgets/sk_toast.dart';
export 'src/widgets/sk_tooltip.dart';

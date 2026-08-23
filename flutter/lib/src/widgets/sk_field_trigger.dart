import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

/// The shared closed-state chrome for field-shaped pickers — [SkSelect] and
/// [SkCombobox]. A hairline-bordered box that thickens to a 2px inset accent
/// border on keyboard focus or while open (matching [SkInput]'s focus
/// treatment), a trailing caret, and the 44px touch floor (0023, via
/// [SkTouchTarget]).
///
/// Extracting it is the point of decision 0028: a picker never rebuilds this,
/// so it can never again ship a field trigger that forgot its focus ring — the
/// bug the ADR was written about. Both `SkSelect` and `SkCombobox` compose it;
/// it is not exported for consumers, who reach it through those components.
class SkFieldTrigger extends StatelessWidget {
  const SkFieldTrigger({
    super.key,
    required this.child,
    this.onPressed,
    this.open = false,
    this.invalid = false,
    this.enabled = true,
    this.size = SkControl.md,
    this.semanticLabel,
  });

  /// The value or placeholder shown in the field (given the remaining width).
  final Widget child;

  final VoidCallback? onPressed;

  /// The picker's overlay is open — holds the focus-border treatment even when
  /// pointer focus has moved into the overlay.
  final bool open;

  final bool invalid;
  final bool enabled;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return SkPressable(
      onPressed: enabled ? onPressed : null,
      disabled: !enabled,
      pressScale: 1,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, SkInteraction s) {
        // Focus ring: keyboard focus OR an open overlay thickens the border to
        // the inset accent treatment. Reading s.focused here is the fix 0028
        // names — the old select only lit borderFocus while open, so a
        // keyboard-focused-but-closed field showed no ring at all.
        final bool lit = open || s.focused;
        final Color border = !enabled
            ? c.borderDisabled
            : invalid
                ? c.textDanger
                : lit
                    ? c.borderFocus
                    : s.liveHover
                        ? c.borderStrong
                        : c.borderDefault;
        final Color caret = enabled ? c.textTertiary : c.textDisabled;

        return SkTouchTarget(
          extent: size,
          child: AnimatedContainer(
            duration: SkMotion.instant,
            curve: SkMotion.out,
            height: size,
            padding: const EdgeInsets.symmetric(horizontal: SkSpace.s4),
            decoration: BoxDecoration(
              color: enabled ? c.surfaceRaised : c.fillDisabled,
              // Inset accent border on focus, like SkInput — 2px, so a field in
              // a tight grid does not overlap its neighbour.
              border: Border.all(
                color: border,
                width: lit ? SkDepth.emphasis : SkDepth.hairline,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: child),
                const SizedBox(width: SkSpace.s4),
                SkIcon(SkIcons.caretDown, size: 14, color: caret),
              ],
            ),
          ),
        );
      },
    );
  }
}

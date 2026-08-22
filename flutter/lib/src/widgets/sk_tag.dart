import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

/// An interactive filter chip, or a removable token.
///
/// The interactive sibling of SkBadge: a tag is something the user can toggle or
/// dismiss. Selected state is an accent wash plus an accent border, never a
/// colour swap alone.
class SkTag extends StatelessWidget {
  const SkTag({
    super.key,
    required this.label,
    this.onPressed,
    this.onRemove,
    this.icon,
    this.selected = false,
    this.disabled = false,
  });

  final String label;

  /// Omit for a static token.
  final VoidCallback? onPressed;

  /// Adds a trailing dismiss affordance.
  final VoidCallback? onRemove;

  final SkGlyph? icon;
  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    // A chip is chrome-scale, so on a precise pointer it keeps its dense 28px.
    // On touch it grows to the 44px floor (0023) — the whole pill, and the dismiss
    // within it, become finger-sized rather than leaving a 28px tap on a phone.
    final bool coarse = skCoarsePointer(context);

    return SkPressable(
      onPressed: onPressed,
      disabled: disabled,
      semanticLabel: label,
      builder: (BuildContext context, SkInteraction s) {
        final Color fg = disabled
            ? c.textDisabled
            : selected
                ? c.textAccent
                : c.textSecondary;
        final Color bg = selected
            ? c.surfaceSelected
            : s.liveHover
                ? c.surfaceHover
                : const Color(0x00000000);
        final Color border = disabled
            ? c.borderDisabled
            : selected
                ? c.borderAccent
                : s.liveHover
                    ? c.borderStrong
                    : c.borderDefault;

        return SkFocusRing(
          visible: s.focused,
          child: AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              height: coarse ? SkControl.touch : SkControl.sm,
              padding: const EdgeInsets.symmetric(horizontal: SkSpace.s3),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                  color: border,
                  width: selected ? SkDepth.emphasis : SkDepth.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    SkIcon(icon!, size: 13, color: fg),
                    const SizedBox(width: SkSpace.s2),
                  ],
                  Text(
                    label,
                    style: SkText.label.copyWith(
                      fontSize: SkFontSize.xs,
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (onRemove != null) ...<Widget>[
                    const SizedBox(width: SkSpace.s2),
                    SkPressable(
                      onPressed: onRemove,
                      semanticLabel: 'Remove $label',
                      pressScale: 1,
                      builder: (BuildContext context, SkInteraction rs) =>
                          SkTouchTarget(
                        extent: 16,
                        square: true,
                        child: Opacity(
                          opacity: rs.liveHover ? 1 : 0.6,
                          child: Text(
                            _closeGlyph,
                            style: SkText.label.copyWith(
                              fontSize: 11,
                              color: fg,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
            ),
          ),
        );
      },
    );
  }

  /// A multiplication sign, not the letter x — the dismiss affordance is drawn
  /// from the text font so it aligns with the label at 11px.
  ///
  /// Deliberately a character in a [Text], not an [IconData]. Naming a text font
  /// in an IconData puts that font in front of `--tree-shake-icons`, which would
  /// happily subset Plus Jakarta Sans down to this one glyph and take every
  /// other character in the app with it.
  static const String _closeGlyph = '×';
}

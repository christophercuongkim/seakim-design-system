import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

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

    return SkPressable(
      onPressed: onPressed,
      disabled: disabled,
      semanticLabel: label,
      builder: (BuildContext context, SkInteraction s) {
        final Color fg = selected ? c.textAccent : c.textSecondary;
        final Color bg = selected
            ? c.surfaceSelected
            : s.liveHover
                ? c.surfaceHover
                : const Color(0x00000000);
        final Color border = selected
            ? c.borderAccent
            : s.liveHover
                ? c.borderStrong
                : c.borderDefault;

        return SkFocusRing(
          visible: s.focused,
          child: AnimatedOpacity(
            opacity: disabled ? 0.4 : 1,
            duration: SkMotion.instant,
            child: AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              height: SkControl.sm,
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
                      builder: (BuildContext context, SkInteraction rs) => Opacity(
                        opacity: rs.liveHover ? 1 : 0.6,
                        child: Icon(
                          _closeGlyph,
                          size: 11,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// A multiplication sign, not the letter x — the dismiss affordance is drawn
  /// from the text font so it aligns with the label at 11px.
  static const IconData _closeGlyph =
      IconData(0x00D7, fontFamily: SkFonts.sans);
}

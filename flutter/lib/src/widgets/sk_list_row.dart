import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

/// One row of a list: [leading] (an avatar, a logo, a checkbox, an icon),
/// [eyebrow], [title], [meta] stacked in the middle, [trailing] on the right (a
/// value, a time, a chevron, a kebab, a toggle).
///
/// The same box serves a one-line settings row and a three-line inbox row; the
/// height comes from what is in it, never from a density parameter. The
/// references show exactly those two families and nothing between.
///
/// [onPressed] makes it a button; without it the row is a static block.
/// [selected] is a fill (0037), not a bar, and sets [Semantics.selected]. A row
/// is square-cornered and carries no hairline of its own; [SkListGroup] draws
/// the dividers between rows so a lone row and a grouped row look the same.
class SkListRow extends StatelessWidget {
  const SkListRow({
    super.key,
    required this.title,
    this.leading,
    this.eyebrow,
    this.meta,
    this.trailing,
    this.selected = false,
    this.onPressed,
    this.disabled = false,
  });

  final Widget? leading;
  final Widget? eyebrow;
  final Widget title;
  final Widget? meta;
  final Widget? trailing;

  /// The current row in a split view.
  final bool selected;
  final VoidCallback? onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool coarse = skCoarsePointer(context);

    Widget body(SkInteraction s) => AnimatedContainer(
          duration: SkMotion.instant,
          curve: SkMotion.out,
          constraints: BoxConstraints(
              minHeight: coarse ? SkControl.touch : SkControl.lg),
          padding: const EdgeInsets.symmetric(
              vertical: SkSpace.s4, horizontal: SkSpace.s5),
          color: selected
              ? c.surfaceSelected
              : s.livePress
                  ? c.surfaceActive
                  : s.liveHover
                      ? c.surfaceHover
                      : const Color(0x00000000),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(color: c.textSecondary),
                  child: leading!,
                ),
                const SizedBox(width: SkSpace.s4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (eyebrow != null)
                      DefaultTextStyle.merge(
                        style: SkText.eyebrow.copyWith(color: c.textTertiary),
                        child: eyebrow!,
                      ),
                    DefaultTextStyle.merge(
                      style: SkText.body.copyWith(color: c.textPrimary),
                      child: title,
                    ),
                    if (meta != null)
                      DefaultTextStyle.merge(
                        style: SkText.bodySm.copyWith(color: c.textSecondary),
                        child: meta!,
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: SkSpace.s4),
                DefaultTextStyle.merge(
                  style: SkText.bodySm.copyWith(color: c.textSecondary),
                  child: trailing!,
                ),
              ],
            ],
          ),
        );

    final Widget row = onPressed == null
        ? body(const SkInteraction())
        : SkPressable(
            onPressed: onPressed,
            disabled: disabled,
            builder: (BuildContext context, SkInteraction s) =>
                SkFocusRing(visible: s.focused, child: body(s)),
          );

    return Semantics(selected: selected, child: row);
  }
}

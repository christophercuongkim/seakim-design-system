import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

@immutable
class SkSegment<T> {
  const SkSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;

  /// Switches to fill weight when this segment is selected.
  final SkGlyph? icon;
}

/// Two to four mutually exclusive short options, all visible at once.
///
/// The default choice for view and filter switches. Selection is a wash plus accent
/// text — there is no sliding pill. For changing screen, use SkTabs. For five or
/// more options, SkSelect.
class SkSegmentedControl<T> extends StatelessWidget {
  const SkSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    this.onChanged,
    this.size = SkControl.md,
    this.fullWidth = false,
  });

  final List<SkSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final double size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool dense = size <= SkControl.sm;

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < segments.length; i++) {
      final SkSegment<T> seg = segments[i];
      final bool on = seg.value == value;

      final Widget button = SkPressable(
        onPressed: onChanged == null ? null : () => onChanged!(seg.value),
        semanticLabel: seg.label,
        pressScale: 1,
        builder: (BuildContext context, SkInteraction s) {
          final Color fg = on
              ? c.textAccent
              : s.liveHover
                  ? c.textPrimary
                  : c.textSecondary;
          return SkTouchTarget(
            extent: size,
            child: AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              height: size,
              padding: EdgeInsets.symmetric(
                  horizontal: dense ? SkSpace.s4 : SkSpace.s5),
              decoration: BoxDecoration(
                color: on
                    ? c.surfaceSelected
                    : s.liveHover
                        ? c.surfaceHover
                        : const Color(0x00000000),
                border: Border(
                  left: i == 0
                      ? BorderSide.none
                      : BorderSide(
                          color: c.borderSubtle, width: SkDepth.hairline),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (seg.icon != null) ...<Widget>[
                    SkIcon(
                      seg.icon!,
                      size: dense ? 13 : 15,
                      weight: on ? SkIconWeight.fill : SkIconWeight.regular,
                      color: fg,
                    ),
                    const SizedBox(width: SkSpace.s3),
                  ],
                  Text(
                    seg.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.label.copyWith(
                      fontSize: dense ? SkFontSize.xs : SkFontSize.sm,
                      color: fg,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      children.add(fullWidth ? Expanded(child: button) : button);
    }

    return Container(
      height: size,
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

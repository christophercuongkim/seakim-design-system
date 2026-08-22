import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_badge.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

@immutable
class SkTab<T> {
  const SkTab(
      {required this.value, required this.label, this.icon, this.count});

  final T value;
  final String label;
  final SkGlyph? icon;

  /// Omit at zero rather than showing 0.
  final int? count;
}

/// Switches between sections of one screen, keeping the surrounding chrome.
///
/// The 2px accent indicator springs into place; the labels never move. For two to
/// four short options that filter rather than navigate, use SkSegmentedControl.
class SkTabs<T> extends StatelessWidget {
  const SkTabs({
    super.key,
    required this.tabs,
    required this.value,
    this.onChanged,
    this.dense = false,
  });

  final List<SkTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs.map((SkTab<T> tab) {
            final bool on = tab.value == value;
            return SkPressable(
              onPressed: onChanged == null ? null : () => onChanged!(tab.value),
              semanticLabel: tab.label,
              pressScale: 1,
              builder: (BuildContext context, SkInteraction s) {
                final Color fg =
                    on || s.liveHover ? c.textPrimary : c.textSecondary;
                // Painted height: vertical padding plus the label line box
                // (SkText.label line-height 1.3). Sub-floor, so on touch the
                // tap band grows to SkControl.touch; desktop keeps the density.
                final double tabHeight = 2 * (dense ? 7 : 10) +
                    (dense ? SkFontSize.xs : SkFontSize.sm) * 1.3;
                // Wrap only the content, not the Stack, so on touch the tab grows
                // to the floor while the bottom-anchored accent indicator stays
                // pinned to the tab-bar edge.
                return Stack(
                  children: <Widget>[
                    SkTouchTarget(
                      extent: tabHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: dense ? SkSpace.s4 : SkSpace.s5,
                          vertical: dense ? 7 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (tab.icon != null) ...<Widget>[
                              SkIcon(
                                tab.icon!,
                                size: dense ? 14 : 16,
                                weight: on
                                    ? SkIconWeight.fill
                                    : SkIconWeight.regular,
                                color: fg,
                              ),
                              const SizedBox(width: SkSpace.s3),
                            ],
                            Text(
                              tab.label,
                              style: SkText.label.copyWith(
                                fontSize: dense ? SkFontSize.xs : SkFontSize.sm,
                                color: fg,
                                fontWeight:
                                    on ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            if (tab.count != null) ...<Widget>[
                              const SizedBox(width: SkSpace.s3),
                              SkBadge(
                                label: '${tab.count}',
                                tone: on
                                    ? SkBadgeTone.accent
                                    : SkBadgeTone.neutral,
                                mono: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: on ? 1 : 0),
                        duration: SkMotion.base,
                        curve: SkMotion.spring,
                        builder: (BuildContext context, double t, _) =>
                            Transform.scale(
                          scaleX: t.clamp(0, 1),
                          child: Container(
                            height: SkDepth.emphasis,
                            color: c.fillAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

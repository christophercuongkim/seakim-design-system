import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

@immutable
class SkTabBarItem<T> {
  const SkTabBarItem({required this.value, required this.label, required this.icon});

  final T value;
  final String label;
  final SkGlyph icon;
}

/// Bottom navigation for narrow viewports.
///
/// Three to five top-level destinations, never more — if you need six, one of them
/// is not top-level. Labels are always visible; there are no icon-only bars. Every
/// target clears [SkControl.touch], and the safe-area inset is added below the bar
/// rather than inside the targets.
class SkTabBar<T> extends StatelessWidget {
  const SkTabBar({
    super.key,
    required this.items,
    required this.active,
    this.onChanged,
  });

  final List<SkTabBarItem<T>> items;
  final T active;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: safeBottom),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        border: Border(
          top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
        ),
      ),
      child: SizedBox(
        height: SkChrome.tabBar,
        child: Row(
          children: items.map((SkTabBarItem<T> item) {
            final bool on = item.value == active;
            return Expanded(
              child: SkPressable(
                onPressed: onChanged == null ? null : () => onChanged!(item.value),
                semanticLabel: item.label,
                pressScale: 1,
                builder: (BuildContext context, SkInteraction s) {
                  final Color fg = on ? c.textAccent : c.textTertiary;
                  return Semantics(
                    selected: on,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // The active icon springs up 1px — the only motion in the bar.
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: on ? 1 : 0),
                          duration: SkMotion.base,
                          curve: SkMotion.spring,
                          builder: (BuildContext context, double t, Widget? child) =>
                              Transform.translate(
                            offset: Offset(0, -t),
                            child: Transform.scale(scale: 1 + t * 0.04, child: child),
                          ),
                          child: SkIcon(
                            item.icon,
                            size: 22,
                            weight: on ? SkIconWeight.fill : SkIconWeight.regular,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: SkText.label.copyWith(
                            fontSize: SkFontSize.xs2,
                            color: fg,
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

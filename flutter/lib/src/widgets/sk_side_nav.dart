import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

@immutable
class SkNavItem<T> {
  const SkNavItem({
    required this.value,
    required this.label,
    required this.icon,
    this.trailing,
  });

  final T value;
  final String label;
  final SkGlyph icon;

  /// Right-aligned count or badge. Hidden when collapsed.
  final Widget? trailing;
}

@immutable
class SkNavGroup<T> {
  const SkNavGroup({required this.items, this.label});

  final List<SkNavItem<T>> items;

  /// Uppercase mono eyebrow. Omit for the first, unlabelled group.
  final String? label;
}

/// Persistent leading navigation for wide viewports.
///
/// 232px, collapsing to 56px icons at the md breakpoint. The active item is the only
/// accent-coloured thing in the nav — if two items read as accent, one is wrong.
class SkSideNav<T> extends StatelessWidget {
  const SkSideNav({
    super.key,
    required this.groups,
    required this.active,
    this.onNavigate,
    this.brand,
    this.collapsed = false,
    this.footer,
  });

  final List<SkNavGroup<T>> groups;
  final T active;
  final ValueChanged<T>? onNavigate;

  /// Wordmark. Renders its first letter when collapsed. No logo mark was supplied,
  /// so this is type, deliberately.
  final String? brand;

  final bool collapsed;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return AnimatedContainer(
      duration: SkMotion.slow,
      curve: SkMotion.out,
      width: collapsed ? SkChrome.sideNavCollapsed : SkChrome.sideNav,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        border: Border(
          right: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (brand != null)
            Container(
              height: SkChrome.topBar,
              alignment: collapsed ? Alignment.center : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 0 : SkSpace.s5),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
                ),
              ),
              child: Text(
                collapsed ? brand!.characters.first : brand!,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: SkText.subheading.copyWith(color: c.textPrimary),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  vertical: SkSpace.s4, horizontal: SkSpace.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int g = 0; g < groups.length; g++) ...<Widget>[
                    if (g > 0) const SizedBox(height: SkSpace.s6),
                    if (groups[g].label != null && !collapsed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            SkSpace.s4, 0, SkSpace.s4, SkSpace.s3),
                        child: Text(
                          groups[g].label!.toUpperCase(),
                          style: SkText.eyebrow.copyWith(color: c.textTertiary),
                        ),
                      ),
                    for (final SkNavItem<T> item in groups[g].items)
                      _NavRow<T>(
                        item: item,
                        active: item.value == active,
                        collapsed: collapsed,
                        onTap: onNavigate == null
                            ? null
                            : () => onNavigate!(item.value),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(SkSpace.s4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
                ),
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

class _NavRow<T> extends StatelessWidget {
  const _NavRow({
    required this.item,
    required this.active,
    required this.collapsed,
    this.onTap,
  });

  final SkNavItem<T> item;
  final bool active;
  final bool collapsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return SkPressable(
      onPressed: onTap,
      semanticLabel: item.label,
      pressScale: 1,
      builder: (BuildContext context, SkInteraction s) {
        final Color fg = active
            ? c.textAccent
            : s.liveHover
                ? c.textPrimary
                : c.textSecondary;
        return AnimatedContainer(
          duration: SkMotion.instant,
          curve: SkMotion.out,
          height: 34,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : SkSpace.s4),
          alignment: collapsed ? Alignment.center : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: active
                ? c.surfaceSelected
                : s.liveHover
                    ? c.surfaceHover
                    : const Color(0x00000000),
            border: Border(
              left: BorderSide(
                color: active ? c.fillAccent : const Color(0x00000000),
                width: SkDepth.emphasis,
              ),
            ),
          ),
          child: collapsed
              ? SkIcon(item.icon,
                  size: 18,
                  weight: active ? SkIconWeight.fill : SkIconWeight.regular,
                  color: fg)
              : Row(
                  children: <Widget>[
                    SkIcon(item.icon,
                        size: 18,
                        weight:
                            active ? SkIconWeight.fill : SkIconWeight.regular,
                        color: fg),
                    const SizedBox(width: SkSpace.s4),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SkText.label.copyWith(
                          color: fg,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (item.trailing != null) item.trailing!,
                  ],
                ),
        );
      },
    );
  }
}

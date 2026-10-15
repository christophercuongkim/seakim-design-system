import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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
/// The 2px accent indicator slides into place; the labels never move. For two to
/// four short options that filter rather than navigate, use SkSegmentedControl.
///
/// [fill] spans the row and its track across the width given. When every tab
/// fits at its natural width they share that width (equally, when the widest
/// one allows it); when they do not, the row scrolls at natural widths as it
/// does without [fill]. The choice comes from the measured width, never the
/// breakpoint.
///
/// When [value] changes, from a tap or from outside (a scroll-spy), the row
/// scrolls the least distance that brings the active tab into view; a tab
/// already in view does not move the row. Reduced motion jumps.
class SkTabs<T> extends StatefulWidget {
  const SkTabs({
    super.key,
    required this.tabs,
    required this.value,
    this.onChanged,
    this.dense = false,
    this.fill = false,
  });

  final List<SkTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool dense;

  /// Span the width given; share it when the tabs fit, scroll when not.
  final bool fill;

  @override
  State<SkTabs<T>> createState() => _SkTabsState<T>();
}

class _SkTabsState<T> extends State<SkTabs<T>> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _active = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(false));
  }

  @override
  void didUpdateWidget(SkTabs<T> old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final bool still = MediaQuery.disableAnimationsOf(context);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(!still));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Least scroll that shows the active tab whole. Scrolls only this row's own
  /// viewport (Scrollable.ensureVisible would also move the page under a
  /// scroll-spy, which is the opposite of what it wants).
  void _reveal(bool animate) {
    final RenderObject? tab = _active.currentContext?.findRenderObject();
    if (!mounted || tab == null || !_scroll.hasClients) return;
    final ScrollPosition p = _scroll.position;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(tab);
    final double atEnd = viewport.getOffsetToReveal(tab, 1).offset;
    final double atStart = viewport.getOffsetToReveal(tab, 0).offset;
    final double to = p.pixels
        .clamp(math.min(atEnd, atStart), math.max(atEnd, atStart))
        .clamp(p.minScrollExtent, p.maxScrollExtent)
        .toDouble();
    if (to == p.pixels) return;
    if (animate) {
      _scroll.animateTo(to, duration: SkMotion.base, curve: SkMotion.out);
    } else {
      _scroll.jumpTo(to);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final List<SkTab<T>> tabs = widget.tabs;
    final T value = widget.value;
    final ValueChanged<T>? onChanged = widget.onChanged;
    final bool dense = widget.dense;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
        ),
      ),
      child: _scroller(
        children: tabs.map((SkTab<T> tab) {
          final bool on = tab.value == value;
          return SkPressable(
            key: on ? _active : null,
            onPressed: onChanged == null ? null : () => onChanged(tab.value),
            semanticLabel: tab.label,
            builder: (BuildContext context, SkInteraction s) {
              final Color fg = on || s.liveHover || s.livePress
                  ? c.textPrimary
                  : c.textSecondary;
              // Painted height: vertical padding plus the label line box
              // (SkText.label line-height 1.3). Sub-floor, so on touch the
              // tap band grows to SkControl.touch; desktop keeps the density.
              final double tabHeight = 2 * (dense ? 7 : 10) +
                  (dense ? SkFontSize.xs : SkFontSize.sm) * 1.3;
              // Wrap only the content, not the Stack, so on touch the tab grows
              // to the floor while the bottom-anchored accent indicator stays
              // pinned to the tab-bar edge.
              return Stack(
                // Centred when fill gives the tab more than its natural width.
                alignment: Alignment.center,
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
                              weight:
                                  on ? SkIconWeight.fill : SkIconWeight.regular,
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
                              tone:
                                  on ? SkBadgeTone.accent : SkBadgeTone.neutral,
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
                      curve: SkMotion.out,
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
    );
  }

  Widget _scroller({required List<Widget> children}) {
    if (!widget.fill) {
      return SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double width = box.maxWidth.isFinite ? box.maxWidth : 0;
        return SizedBox(
          width: box.maxWidth.isFinite ? width : null,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: _FillRow(width: width, children: children),
          ),
        );
      },
    );
  }
}

/// Lays the tabs out across [width] when their natural widths fit: equal
/// shares when the widest tab allows it, otherwise each natural width plus an
/// equal part of the slack. When they do not fit, natural widths, and the row
/// is as wide as their sum (the scroll view then scrolls it).
class _FillRow extends MultiChildRenderObjectWidget {
  const _FillRow({required this.width, required super.children});

  final double width;

  @override
  _RenderFillRow createRenderObject(BuildContext context) =>
      _RenderFillRow(width);

  @override
  void updateRenderObject(BuildContext context, _RenderFillRow r) =>
      r.width = width;
}

class _FillParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderFillRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FillParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FillParentData> {
  _RenderFillRow(this._width);

  double _width;
  set width(double v) {
    if (v == _width) return;
    _width = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FillParentData) {
      child.parentData = _FillParentData();
    }
  }

  List<RenderBox> get _kids {
    final List<RenderBox> out = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      out.add(child);
      child = childAfter(child);
    }
    return out;
  }

  /// Widths for [natural] inside [width]; null when they do not fit.
  static List<double>? shares(List<double> natural, double width) {
    final double total = natural.fold(0, (double a, double b) => a + b);
    if (natural.isEmpty || total > width) return null;
    final double equal = width / natural.length;
    if (natural.every((double w) => w <= equal)) {
      return List<double>.filled(natural.length, equal);
    }
    final double extra = (width - total) / natural.length;
    return <double>[for (final double w in natural) w + extra];
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      computeMaxIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _kids.fold(
      0, (double a, RenderBox k) => a + k.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) => _kids.fold(
      0,
      (double a, RenderBox k) =>
          math.max(a, k.getMinIntrinsicHeight(double.infinity)));

  @override
  double computeMaxIntrinsicHeight(double width) => _kids.fold(
      0,
      (double a, RenderBox k) =>
          math.max(a, k.getMaxIntrinsicHeight(double.infinity)));

  @override
  void performLayout() {
    final List<RenderBox> kids = _kids;
    final List<double> natural = <double>[
      for (final RenderBox k in kids) k.getMaxIntrinsicWidth(double.infinity)
    ];
    final List<double> widths = shares(natural, _width) ?? natural;
    double height = 0;
    for (int i = 0; i < kids.length; i++) {
      kids[i].layout(BoxConstraints.tightFor(width: widths[i]),
          parentUsesSize: true);
      height = math.max(height, kids[i].size.height);
    }
    double x = 0;
    for (int i = 0; i < kids.length; i++) {
      kids[i].layout(BoxConstraints.tightFor(width: widths[i], height: height));
      (kids[i].parentData! as _FillParentData).offset = Offset(x, 0);
      x += widths[i];
    }
    size = constraints.constrain(Size(x, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import 'sk_badge.dart';
import 'sk_pressable.dart';
import 'sk_tabs.dart';

/// Kanban columns. Each [SkBoardColumn] has a header (label, count, an
/// optional status dot, a menu), its cards, and a footer for the add row; the
/// column is a sunken fill against the page, 352 wide with an [SkSpace.s4]
/// gap, where ClickUp, Wrike, Asana, Programa, Slack and Trello all land.
///
/// Empty columns collapse by default to a narrow vertical header that expands
/// on press ([collapseEmpty], the job-search board pick; ClickUp has the same
/// toggle). Under `md`, measured on the container, the row becomes a
/// [PageView] with one column at 85% and the next peeking, an [SkTabs] row of
/// the stages with counts above it that jumps the strip, and page dots under
/// it: the pick's phone option over Jira's and Asana's peek alone.
class SkBoard extends StatefulWidget {
  const SkBoard({
    super.key,
    required this.columns,
    this.collapseEmpty = true,
    this.columnWidth = 352,
  });

  final List<SkBoardColumn> columns;
  final bool collapseEmpty;
  final double columnWidth;

  @override
  State<SkBoard> createState() => _SkBoardState();
}

class _SkBoardState extends State<SkBoard> {
  final PageController _pages = PageController(viewportFraction: 0.85);
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) {
        final bool narrow = bp.isSm;
        final Widget strip = narrow
            ? PageView.builder(
                controller: _pages,
                padEnds: false,
                itemCount: widget.columns.length,
                onPageChanged: (int i) => setState(() => _page = i),
                itemBuilder: (BuildContext context, int i) => Padding(
                  padding: const EdgeInsets.only(right: SkSpace.s4),
                  child: widget.columns[i],
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < widget.columns.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: SkSpace.s4),
                      widget.columns[i],
                    ],
                  ],
                ),
              );
        return SkBoardScope(
          narrow: narrow,
          collapseEmpty: widget.collapseEmpty,
          columnWidth: widget.columnWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (narrow && widget.columns.length > 1) ...<Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: SkSpace.s5),
                  child: SkTabs<int>(
                    dense: true,
                    value: _page,
                    onChanged: (int i) => _pages.animateToPage(i,
                        duration: SkMotion.slow, curve: SkMotion.out),
                    tabs: <SkTab<int>>[
                      for (int i = 0; i < widget.columns.length; i++)
                        SkTab<int>(
                          value: i,
                          label: widget.columns[i].label,
                          count: widget.columns[i].count,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SkSpace.s3),
              ],
              Expanded(
                child: narrow
                    ? Padding(
                        padding: const EdgeInsets.only(left: SkSpace.s5),
                        child: strip,
                      )
                    : strip,
              ),
              if (narrow && widget.columns.length > 1) ...<Widget>[
                const SizedBox(height: SkSpace.s3),
                ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < widget.columns.length; i++)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(
                              horizontal: SkSpace.s1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                i == _page ? c.textSecondary : c.borderStrong,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// What [SkBoardColumn] reads from its [SkBoard].
class SkBoardScope extends InheritedWidget {
  const SkBoardScope({
    super.key,
    required this.narrow,
    required this.collapseEmpty,
    required this.columnWidth,
    required super.child,
  });

  final bool narrow;
  final bool collapseEmpty;
  final double columnWidth;

  static SkBoardScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SkBoardScope>();

  @override
  bool updateShouldNotify(SkBoardScope old) =>
      narrow != old.narrow ||
      collapseEmpty != old.collapseEmpty ||
      columnWidth != old.columnWidth;
}

/// One column of an [SkBoard].
class SkBoardColumn extends StatefulWidget {
  const SkBoardColumn({
    super.key,
    required this.label,
    this.count,
    this.tone,
    this.menu,
    this.footer,
    this.children = const <Widget>[],
    this.empty,
  });

  final String label;
  final int? count;

  /// A status dot before the label, in the status colour.
  final SkBadgeTone? tone;
  final Widget? menu;
  final Widget? footer;
  final List<Widget> children;

  /// Override the empty check.
  final bool? empty;

  @override
  State<SkBoardColumn> createState() => _SkBoardColumnState();
}

class _SkBoardColumnState extends State<SkBoardColumn> {
  bool _expanded = false;

  Color _toneColor(SkColors c, SkBadgeTone tone) => switch (tone) {
        SkBadgeTone.success => c.textSuccess,
        SkBadgeTone.warning => c.textWarning,
        SkBadgeTone.danger => c.textDanger,
        SkBadgeTone.info => c.textInfo,
        SkBadgeTone.accent => c.textAccent,
        SkBadgeTone.neutral => c.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final SkBoardScope? scope = SkBoardScope.maybeOf(context);
    final bool narrow = scope?.narrow ?? false;
    final bool isEmpty = widget.empty ?? widget.children.isEmpty;
    final bool collapsed =
        (scope?.collapseEmpty ?? false) && isEmpty && !narrow && !_expanded;
    final Widget? dot = widget.tone == null
        ? null
        : Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _toneColor(c, widget.tone!),
            ),
          );
    final TextStyle eyebrow = SkText.eyebrow.copyWith(color: c.textTertiary);
    final TextStyle countStyle =
        SkText.data.copyWith(fontSize: SkFontSize.xs, color: c.textTertiary);

    if (collapsed) {
      return SkPressable(
        onPressed: () => setState(() => _expanded = true),
        semanticLabel: '${widget.label}, ${widget.count ?? 0}, collapsed',
        builder: (BuildContext context, SkInteraction s) => SkFocusRing(
          visible: s.focused,
          child: Container(
            width: SkSpace.s10,
            constraints: const BoxConstraints(minHeight: SkSpace.s12),
            padding: const EdgeInsets.symmetric(vertical: SkSpace.s4),
            decoration: BoxDecoration(
              color: s.liveHover ? c.surfaceHover : c.surfaceSunken,
              borderRadius: BorderRadius.circular(SkRadius.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (dot != null) ...<Widget>[
                  dot,
                  const SizedBox(height: SkSpace.s3)
                ],
                RotatedBox(
                  quarterTurns: 1,
                  child: Text(widget.label.toUpperCase(), style: eyebrow),
                ),
                const SizedBox(height: SkSpace.s3),
                Text('${widget.count ?? 0}', style: countStyle),
              ],
            ),
          ),
        ),
      );
    }

    final Widget column = Container(
      width: narrow ? null : scope?.columnWidth ?? 352,
      padding: const EdgeInsets.all(SkSpace.s4),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(SkRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SkControl.sm),
            child: Row(
              children: <Widget>[
                if (dot != null) ...<Widget>[
                  dot,
                  const SizedBox(width: SkSpace.s3)
                ],
                Flexible(
                  child: Semantics(
                    header: true,
                    child: Text(
                      widget.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eyebrow,
                    ),
                  ),
                ),
                if (widget.count != null) ...<Widget>[
                  const SizedBox(width: SkSpace.s3),
                  Text('${widget.count}', style: countStyle),
                ],
                const Spacer(),
                if (widget.menu != null) widget.menu!,
              ],
            ),
          ),
          const SizedBox(height: SkSpace.s3),
          // The cards scroll inside a bounded column (a board given a height)
          // and take their own height in an unbounded one.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < widget.children.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: SkSpace.s3),
                    widget.children[i],
                  ],
                ],
              ),
            ),
          ),
          if (widget.footer != null) ...<Widget>[
            const SizedBox(height: SkSpace.s3),
            widget.footer!,
          ],
        ],
      ),
    );
    return Semantics(container: true, label: widget.label, child: column);
  }
}

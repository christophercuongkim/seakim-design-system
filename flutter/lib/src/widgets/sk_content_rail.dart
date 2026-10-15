import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import 'sk_page_body.dart';

/// layout.md pattern 2, content + rail: a detail screen's primary [content]
/// beside a 300 to 320px [rail] of secondary panels. Measured on its own
/// container ([SkResponsive]), like [SkSplitPane]. Not a split pane: there is
/// no list and no selection, and the rail is not the properties of an item.
///
/// At `lg` the two sit side by side with a [SkColors.borderSubtle] hairline
/// between, as [SkSplitPane] separates its columns, and each scrolls on its
/// own, so the rail stays put while the content moves. Below `lg`:
///
/// * [railBelow] true (the default, layout.md): one column, the content then
///   the rail panels in order, scrolling together. Never a drawer or a tab.
/// * [railBelow] false: the rail is hidden. Only for a pane that cannot have
///   anything under it, such as a chat thread whose bottom edge is the
///   composer; anything a phone needs belongs in the content.
///
/// With [railBelow] the widget owns the content's scroll, so pass a
/// non-scrolling widget. With it false the content gets a bounded box and owns
/// its own scroll, which is what a chat thread needs. The rail panels take
/// [skPagePad] and the section gap between them; the content's padding is the
/// content's (an [SkPageBody], usually). Give it a height.
class SkContentRail extends StatelessWidget {
  const SkContentRail({
    super.key,
    required this.content,
    required this.rail,
    this.railWidth = 300,
    this.railBelow = true,
  }) : assert(railWidth >= 300 && railWidth <= 320,
            'layout.md: the rail is 300 to 320.');

  final Widget content;

  /// The secondary panels, top to bottom.
  final List<Widget> rail;

  final double railWidth;

  /// Below `lg`, move the rail under the content (true) or hide it (false).
  final bool railBelow;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) {
        final Widget panels = Padding(
          padding: skPagePad(bp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < rail.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: SkSpace.s7),
                rail[i],
              ],
            ],
          ),
        );
        final Widget main =
            railBelow ? SingleChildScrollView(child: content) : content;

        if (bp.isLg) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: main),
              Container(width: 1, color: c.borderSubtle),
              SizedBox(
                width: railWidth,
                child: Semantics(
                  container: true,
                  label: 'Related',
                  child: SingleChildScrollView(child: panels),
                ),
              ),
            ],
          );
        }
        if (!railBelow) return content;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[content, panels],
          ),
        );
      },
    );
  }
}

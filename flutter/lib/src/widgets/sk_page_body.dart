import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';

/// The content ceilings in `guidelines/layout.md`, by what the page holds.
enum SkPageWidth {
  /// Single-column lists and feeds: 768 (48rem). A list of rows has no
  /// columns to compare, so a wider one only moves the chevron away.
  list,

  /// Forms: 620.
  form,

  /// Prose: 68ch of body text.
  prose,

  /// Tables, boards, split panes, maps, dashboards: everything given.
  full,
}

/// Page padding for a breakpoint, per `guidelines/layout.md`: 16 at the sides
/// and top on a phone, 20 and 24 from `md`, and a larger bottom (40, 64) so the
/// last row has air under it. React's `pagePad(bp)` returns the same values.
EdgeInsets skPagePad(SkBreakpoint bp) => bp.isSm
    ? const EdgeInsets.fromLTRB(SkSpace.s5, SkSpace.s5, SkSpace.s5, SkSpace.s9)
    : const EdgeInsets.fromLTRB(
        SkSpace.s6, SkSpace.s7, SkSpace.s6, SkSpace.s11);

/// The body of a page inside the shell's main area: [skPagePad] for the
/// measured breakpoint outside, a [width] ceiling inside, the column centred.
/// A route, its loading state and its error state all wrap in the same one,
/// so they cannot disagree about where the content starts.
///
/// It does not scroll; put it inside the page's scroll view. The child gets
/// the full ceiling width (a list's rows stretch to it), never more.
class SkPageBody extends StatelessWidget {
  const SkPageBody({super.key, required this.width, required this.child});

  final SkPageWidth width;
  final Widget child;

  /// The ceiling in logical pixels; [SkPageWidth.prose] measures 68 zeros of
  /// body text, which is what `68ch` means on the web.
  static double maxWidthOf(SkPageWidth width) => switch (width) {
        SkPageWidth.list => 768,
        SkPageWidth.form => 620,
        SkPageWidth.prose => _proseWidth,
        SkPageWidth.full => double.infinity,
      };

  static final double _proseWidth = () {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: '0' * 68, style: SkText.body),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double w = tp.width;
    tp.dispose();
    return w;
  }();

  @override
  Widget build(BuildContext context) {
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) => Padding(
        padding: skPagePad(bp),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidthOf(width)),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

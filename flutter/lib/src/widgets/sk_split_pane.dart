import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon_button.dart';

/// A list beside its detail, with an optional properties column: the shape of
/// every mail client, CRM and inbox the references showed. Layout only: it
/// decides which columns show at which width and lets each scroll on its own;
/// the selection is the app's.
///
/// Measured on its own container ([SkResponsive]): under `md` it shows the
/// list, or the detail when [detailOpen] (the phone push every reference
/// uses); from `md` the list and the detail; from `lg` the [aside] too. A
/// [SkColors.borderSubtle] hairline separates columns, the one place 0037
/// allows an edge between panels. Put an [SkSplitPaneHeader] at the top of
/// the detail: it shows a back control on the phone and a close control
/// otherwise.
class SkSplitPane extends StatelessWidget {
  const SkSplitPane({
    super.key,
    required this.list,
    required this.detail,
    this.aside,
    this.detailOpen = false,
    this.onBack,
    this.listWidth = 384,
    this.asideWidth = 320,
  });

  final Widget list;
  final Widget detail;

  /// A properties column right of the detail. Shown from `lg`.
  final Widget? aside;

  /// On a narrow container, show the detail instead of the list.
  final bool detailOpen;

  /// Called by the header's back control on a narrow container.
  final VoidCallback? onBack;

  final double listWidth;
  final double asideWidth;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) {
        final bool narrow = bp.isSm;
        final bool showList = !narrow || !detailOpen;
        final bool showDetail = !narrow || detailOpen;
        final bool showAside = bp.isLg && aside != null;
        final Widget hairline = Container(width: 1, color: c.borderSubtle);
        return SkSplitPaneScope(
          narrow: narrow,
          onBack: onBack,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (showList)
                narrow
                    ? Expanded(child: list)
                    : SizedBox(width: listWidth, child: list),
              if (showList && showDetail) hairline,
              if (showDetail)
                Expanded(
                  child: Semantics(
                    container: true,
                    label: 'Detail',
                    child: detail,
                  ),
                ),
              if (showAside) ...<Widget>[
                hairline,
                SizedBox(width: asideWidth, child: aside),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// What [SkSplitPaneHeader] reads to choose back over close.
class SkSplitPaneScope extends InheritedWidget {
  const SkSplitPaneScope({
    super.key,
    required this.narrow,
    required this.onBack,
    required super.child,
  });

  final bool narrow;
  final VoidCallback? onBack;

  static SkSplitPaneScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SkSplitPaneScope>();

  @override
  bool updateShouldNotify(SkSplitPaneScope old) =>
      narrow != old.narrow || onBack != old.onBack;
}

/// The detail column's own header: back on the phone or close otherwise, the
/// title, a counter ('3 of 12'), prev/next, and the pane's actions. Place it
/// first in the detail; pin it with a sticky scroll if the detail scrolls.
class SkSplitPaneHeader extends StatelessWidget {
  const SkSplitPaneHeader({
    super.key,
    required this.title,
    this.counter,
    this.onClose,
    this.onPrev,
    this.onNext,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? counter;
  final VoidCallback? onClose;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final SkSplitPaneScope? scope = SkSplitPaneScope.maybeOf(context);
    final bool back = (scope?.narrow ?? false) && scope?.onBack != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfacePage,
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: SkSpace.s3, horizontal: SkSpace.s5),
        child: Row(
          children: <Widget>[
            if (back)
              SkIconButton(
                icon: SkIcons.arrowLeft,
                label: 'Back',
                size: SkControl.sm,
                onPressed: scope!.onBack,
              )
            else if (onClose != null)
              SkIconButton(
                icon: SkIcons.x,
                label: 'Close',
                size: SkControl.sm,
                onPressed: onClose,
              ),
            if (back || onClose != null) const SizedBox(width: SkSpace.s3),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SkText.subheading.copyWith(color: c.textPrimary),
                ),
              ),
            ),
            if (counter != null) ...<Widget>[
              const SizedBox(width: SkSpace.s3),
              Text(
                counter!,
                style: SkText.caption.copyWith(
                  color: c.textSecondary,
                  fontFeatures: SkText.tabular,
                ),
              ),
            ],
            if (onPrev != null || onNext != null) ...<Widget>[
              const SizedBox(width: SkSpace.s3),
              SkIconButton(
                icon: SkIcons.caretUp,
                label: 'Previous',
                size: SkControl.sm,
                onPressed: onPrev,
                disabled: onPrev == null,
              ),
              SkIconButton(
                icon: SkIcons.caretDown,
                label: 'Next',
                size: SkControl.sm,
                onPressed: onNext,
                disabled: onNext == null,
              ),
            ],
            for (final Widget a in actions) ...<Widget>[
              const SizedBox(width: SkSpace.s3),
              a,
            ],
          ],
        ),
      ),
    );
  }
}

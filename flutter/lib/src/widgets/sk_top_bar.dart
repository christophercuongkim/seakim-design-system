import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_icon_button.dart';
import 'sk_popover.dart';
import 'sk_pressable.dart';

/// The bar at the top of main: layout.md's 52px top bar, and the screen header
/// on a phone. A back or close control, the title, up to two trailing icon
/// actions; the trip screens in Tripadvisor, Wanderlog and Vrbo, and the Jira
/// and Trello web bars.
///
/// [onTitleTap] makes the title a button with a caret. [titleMenu] is shown in
/// an [SkPopover] under the title while [titleMenuOpen]; the bar does not own
/// that state, the app does, the same way [SkPopover] works. The menu's
/// content is the app's.
///
/// A [SkColors.surfaceCard] fill with no hairline (0037). It wears
/// [SkDepth.raisedTopBar] only while [scrolledUnder], the sticky rule in
/// layout.md: the app knows its scroll offset and passes it. The top safe-area
/// inset is added above the 52px row, inside the fill, so the bar's targets
/// never sit under a notch.
class SkTopBar extends StatelessWidget {
  const SkTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onClose,
    this.onTitleTap,
    this.titleMenu,
    this.titleMenuOpen = false,
    this.onTitleMenuDismiss,
    this.actions = const <Widget>[],
    this.scrolledUnder = false,
  });

  /// The screen's name. Styled as a subheading; one line, ellipsised.
  final Widget title;

  /// Shows a back control first. Wins over [onClose].
  final VoidCallback? onBack;

  /// Shows a close control first, when there is no [onBack].
  final VoidCallback? onClose;

  /// Makes the title a button with a caret.
  final VoidCallback? onTitleTap;

  /// Shown in a popover under the title while [titleMenuOpen].
  final WidgetBuilder? titleMenu;
  final bool titleMenuOpen;

  /// Escape or a tap outside the open [titleMenu].
  final VoidCallback? onTitleMenuDismiss;

  /// Up to two [SkIconButton]s. A third belongs in a menu.
  final List<Widget> actions;

  /// Content is scrolled under the bar: show the raised shadow.
  final bool scrolledUnder;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double inset = MediaQuery.paddingOf(context).top;

    Widget heading = DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SkText.subheading.copyWith(color: c.textPrimary),
      child: Semantics(header: true, child: title),
    );
    if (onTitleTap != null) {
      final Widget label = heading;
      heading = SkPressable(
        onPressed: onTitleTap,
        builder: (BuildContext context, SkInteraction s) => Semantics(
          expanded: titleMenu == null ? null : titleMenuOpen,
          // 44 tall: the bar is 52, and a title that opens a menu is a target.
          child: SizedBox(
            height: SkControl.touch,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(child: label),
                const SizedBox(width: SkSpace.s2),
                SkIcon(SkIcons.caretDown, size: 16, color: c.textSecondary),
              ],
            ),
          ),
        ),
      );
    }
    if (titleMenu != null) {
      heading = SkPopover(
        open: titleMenuOpen,
        onDismiss: onTitleMenuDismiss,
        overlayBuilder: titleMenu!,
        child: heading,
      );
    }

    return AnimatedContainer(
      duration: SkMotion.base,
      curve: SkMotion.out,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        boxShadow:
            scrolledUnder ? SkDepth.raisedTopBar(c.brightness) : SkDepth.none,
      ),
      // The inset is a plain Padding, not the container's: an animated
      // padding would slide the bar when the inset changes.
      child: Padding(
        padding: EdgeInsets.only(top: inset),
        child: SizedBox(
          height: SkChrome.topBar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SkSpace.s3),
            child: Row(
              children: <Widget>[
                if (onBack != null)
                  SkIconButton(
                      icon: SkIcons.arrowLeft, label: 'Back', onPressed: onBack)
                else if (onClose != null)
                  SkIconButton(
                      icon: SkIcons.x, label: 'Close', onPressed: onClose),
                const SizedBox(width: SkSpace.s3),
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: heading),
                ),
                for (final Widget a in actions) ...<Widget>[
                  const SizedBox(width: SkSpace.s2),
                  a,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

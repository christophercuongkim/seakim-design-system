import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/sk_theme.dart';
import 'sk_icon_button.dart';

/// A modal that interrupts.
///
/// Reserve it for decisions that must be made now — destructive confirmations,
/// payment, a required choice. Never for information; that is an SkToast. The title
/// is a sentence-case statement and the confirm button repeats its verb.
class SkDialog extends StatelessWidget {
  const SkDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions,
    this.onClose,
    this.width = 440,
  });

  final String? title;

  /// One or two sentences: what happens, and what it costs.
  final String? description;

  final Widget? content;

  /// Trailing-aligned buttons. Cancel is ghost and says what keeping means; the
  /// action is primary or danger.
  final List<Widget>? actions;

  /// Omit to make the dialog non-dismissible.
  final VoidCallback? onClose;

  final double width;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return Container(
      width: width,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - SkSpace.s7 * 2,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
        boxShadow: SkDepth.dialog(c.brightness),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                SkSpace.s5, SkSpace.s5, SkSpace.s5, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (title != null)
                        Text(title!,
                            style: SkText.heading.copyWith(color: c.textPrimary)),
                      if (description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: SkSpace.s3),
                          child: Text(
                            description!,
                            style:
                                SkText.bodySm.copyWith(color: c.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onClose != null) ...<Widget>[
                  const SizedBox(width: SkSpace.s5),
                  SkIconButton(
                    icon: PhosphorIcons.x,
                    label: 'Close',
                    size: SkControl.sm,
                    onPressed: onClose,
                    tooltip: false,
                  ),
                ],
              ],
            ),
          ),
          if (content != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SkSpace.s5),
                child: content!,
              ),
            ),
          if (actions != null && actions!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(SkSpace.s5),
              margin: EdgeInsets.only(top: content == null ? SkSpace.s5 : 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  for (int i = 0; i < actions!.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: SkSpace.s4),
                    actions![i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Presents an [SkDialog] with the system scrim and enter motion.
///
/// The barrier is [SkColors.surfaceScrim] — warm black, not Material's cool grey.
Future<T?> showSkDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final SkThemeData theme = SkTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: dismissible,
      barrierColor: theme.colors.surfaceScrim,
      transitionDuration: SkMotion.base,
      reverseTransitionDuration: SkMotion.fast,
      pageBuilder: (BuildContext context, _, __) => SkTheme(
        data: theme,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(SkSpace.s7),
            child: builder(context),
          ),
        ),
      ),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondary, Widget child) {
        // Enters spring, exits do not.
        final bool leaving = animation.status == AnimationStatus.reverse;
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: leaving ? SkMotion.out : SkMotion.spring,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: SkMotion.out),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Bottom sheet at sm, centred panel from md up.
///
/// The species change is deliberate: on a phone a sheet is thumb-reachable, on a
/// desktop a bottom sheet is a long way from the pointer. Mirrors PlayerSheet in
/// the web kit.
Future<T?> showSkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final SkThemeData theme = SkTheme.of(context);
  final bool narrow = MediaQuery.sizeOf(context).width < 640;

  if (!narrow) {
    return showSkDialog<T>(context: context, builder: builder, dismissible: dismissible);
  }

  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: dismissible,
      barrierColor: theme.colors.surfaceScrim,
      transitionDuration: SkMotion.slow,
      reverseTransitionDuration: SkMotion.fast,
      pageBuilder: (BuildContext context, _, __) => SkTheme(
        data: theme,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            decoration: BoxDecoration(
              color: theme.colors.surfaceOverlay,
              border: Border(
                top: BorderSide(
                    color: theme.colors.borderDefault, width: SkDepth.hairline),
              ),
              boxShadow: SkDepth.sheet(theme.brightness),
            ),
            child: builder(context),
          ),
        ),
      ),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondary, Widget child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: SkMotion.out)),
        child: child,
      ),
    ),
  );
}

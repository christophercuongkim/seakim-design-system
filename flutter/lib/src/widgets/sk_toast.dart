import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_icon_button.dart';
import 'sk_pressable.dart';

enum SkToastTone { neutral, success, warning, danger }

/// Transient confirmation of something that already happened.
///
/// Past tense, no exclamation mark, no emoji. One at a time, bottom-trailing on
/// desktop and full-width above the tab bar on mobile. Pops in with [SkMotion.pop]
/// and fades out — arrival is the only thing that overshoots.
///
/// Not for errors that need a decision; that is an SkDialog.
class SkToast extends StatelessWidget {
  const SkToast({
    super.key,
    required this.message,
    this.tone = SkToastTone.neutral,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;
  final SkToastTone tone;

  /// One optional recovery action, usually Undo.
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final (SkGlyph glyph, Color tint) = switch (tone) {
      SkToastTone.success => (SkIcons.checkCircle, c.textSuccess),
      SkToastTone.warning => (SkIcons.warning, c.textWarning),
      SkToastTone.danger => (SkIcons.xCircle, c.textDanger),
      SkToastTone.neutral => (SkIcons.info, c.textSecondary),
    };

    return Semantics(
      liveRegion: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: SkMotion.base,
        curve: SkMotion.pop,
        builder: (BuildContext context, double t, Widget? child) => Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: child,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
          padding: const EdgeInsets.fromLTRB(
              SkSpace.s5, SkSpace.s4, SkSpace.s4, SkSpace.s4),
          decoration: BoxDecoration(
            color: c.surfaceOverlay,
            border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
            boxShadow: SkDepth.toast(c.brightness),
          ),
          child: Row(
            children: <Widget>[
              SkIcon(glyph, size: 16, weight: SkIconWeight.fill, color: tint),
              const SizedBox(width: SkSpace.s4),
              // Expanded so the action/dismiss anchor to the trailing edge
              // instead of floating mid-panel when the message is short.
              Expanded(
                child: Text(
                  message,
                  style: SkText.bodySm.copyWith(color: c.textPrimary),
                ),
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(width: SkSpace.s4),
                SkPressable(
                  onPressed: onAction,
                  semanticLabel: actionLabel,
                  pressScale: 1,
                  builder: (BuildContext context, SkInteraction s) => Text(
                    actionLabel!,
                    style: SkText.label.copyWith(
                      color: s.liveHover ? c.textLinkHover : c.textAccent,
                    ),
                  ),
                ),
              ],
              if (onDismiss != null) ...<Widget>[
                const SizedBox(width: SkSpace.s3),
                SkIconButton(
                  icon: SkIcons.x,
                  label: 'Dismiss',
                  size: SkControl.sm,
                  onPressed: onDismiss,
                  tooltip: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a [SkToast] in the nearest [Overlay], bottom-trailing on wide viewports
/// and full-width above the safe area on narrow ones. Auto-dismisses.
///
/// Returns the entry so a caller can remove it early.
OverlayEntry showSkToast(
  BuildContext context, {
  required String message,
  SkToastTone tone = SkToastTone.neutral,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  final SkThemeData theme = SkTheme.of(context);
  final bool narrow = MediaQuery.sizeOf(context).width < 640;
  late final OverlayEntry entry;

  void remove() {
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (BuildContext overlayContext) => SkTheme(
      data: theme,
      child: Positioned(
        right: SkSpace.s6,
        left: narrow ? SkSpace.s6 : null,
        bottom: MediaQuery.paddingOf(overlayContext).bottom + SkSpace.s6,
        child: SkToast(
          message: message,
          tone: tone,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  remove();
                  onAction();
                },
          onDismiss: remove,
        ),
      ),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
  Future<void>.delayed(duration, remove);
  return entry;
}

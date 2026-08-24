import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_button.dart';
import 'sk_icon.dart';

/// A region or route that failed (decision 0029). Says what broke, what it means,
/// and the one way forward — a retry, or a navigational escape when retrying
/// cannot help (a 403). The recovery action is the point.
///
/// It reuses [SkLoadingState]/[SkEmptyState]'s centred frame — the same centring
/// and title/description rhythm — but takes none of empty's identity: **no dashed
/// border** (that belongs to empty alone) and an **error-toned glyph**, so the
/// state reads as *wrong*, not *absent*. Empty is static, loading is polite-busy
/// (0021), error is an alert — the three must not read alike.
///
/// The frame is a [Semantics.liveRegion] carrying the failure, so it is announced
/// when it mounts. (Flutter's live region has no polite/assertive split — the
/// assertive obligation 0029 names is expressed where the platform allows it, e.g.
/// `role="alert"` in the React binding.)
///
/// Not a toast: a failed page or region needs a persistent state to return to and
/// act on. [SkToast] keeps a failed *incidental* action; this owns the region or
/// route failure.
class SkErrorState extends StatelessWidget {
  const SkErrorState({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.action,
    this.icon = SkIcons.warning,
    this.compact = false,
  });

  /// States the failure.
  final String title;

  /// Cause, consequence, next step — one sentence each, max.
  final String? description;

  /// Retry handler. Renders the default `Try again` recovery button.
  final VoidCallback? onRetry;
  final String retryLabel;

  /// Overrides the default retry button — use for a terminal error's navigational
  /// escape (go back / go home) where retrying cannot help.
  final Widget? action;

  final SkGlyph icon;

  /// Tighter padding, for a panel rather than a full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final Widget? recovery = action ??
        (onRetry == null
            ? null
            : SkButton(
                label: retryLabel,
                variant: SkButtonVariant.secondary,
                iconLeft: SkIcons.arrowClockwise,
                onPressed: onRetry,
              ));

    return Semantics(
      liveRegion: true,
      container: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(color: c.surfaceSunken),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? SkSpace.s6 : SkSpace.s7,
            vertical: compact ? SkSpace.s8 : SkSpace.s11,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Error-toned glyph: a danger hue, so the state reads as *wrong*, not
              // *absent*, before the copy is read.
              SkIcon(
                icon,
                size: compact ? 24 : 32,
                weight: SkIconWeight.fill,
                color: c.textDanger,
              ),
              const SizedBox(height: SkSpace.s5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: SkText.subheading.copyWith(color: c.textPrimary),
              ),
              if (description != null) ...<Widget>[
                const SizedBox(height: SkSpace.s3),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: SkText.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
              if (recovery != null) ...<Widget>[
                const SizedBox(height: SkSpace.s5),
                recovery,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

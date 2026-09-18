import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';

/// What a container says before it has contents.
///
/// Always names the thing that goes here and offers the action that creates it.
/// Never an apology, never an emoji. A sunken fill with no outline (0037).
class SkEmptyState extends StatelessWidget {
  const SkEmptyState({
    super.key,
    required this.title,
    this.description,
    this.glyph,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? description;

  /// Drawn in duotone, the only place decorative icon weight is used.
  final SkGlyph? glyph;

  /// Usually a single primary SkButton.
  final Widget? action;

  /// Tighter padding, for empty panels rather than empty pages.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return DecoratedBox(
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
              SkIcon(
                glyph ?? SkIcons.tray,
                size: compact ? 24 : 32,
                weight: SkIconWeight.duotone,
                color: c.textTertiary,
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
              if (action != null) ...<Widget>[
                const SizedBox(height: SkSpace.s5),
                action!,
              ],
            ],
          ),
        ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Loading when you know only that something is arriving — a route boot, a gate
/// (decision 0021).
///
/// It names the thing being fetched and announces itself busy. It reuses
/// [SkEmptyState]'s centred frame — the same centring and title/description
/// rhythm — but deliberately NOT the dashed border and NOT as an [SkEmptyState]
/// variant: empty means "nothing here, do something", loading means "something is
/// coming, wait", and they must not read alike. The indicator is a static linear
/// bar, never a spinner — SeaKim has none. [Semantics.liveRegion] makes it
/// announce busy, then completion when it is replaced by content.
class SkLoadingState extends StatelessWidget {
  const SkLoadingState({
    super.key,
    required this.title,
    this.description,
    this.compact = false,
  });

  /// Names the thing being fetched, e.g. 'Checking 40 airlines…'.
  final String title;
  final String? description;

  /// Tighter padding, for a panel rather than a full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return Semantics(
      liveRegion: true,
      label: title,
      container: true,
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
              // A static linear bar — a token-coloured hint that something is in
              // flight. Never a spinner, never a rotation.
              DecoratedBox(
                decoration: BoxDecoration(color: c.surfaceShimmer),
                child: const SizedBox(width: 96, height: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}

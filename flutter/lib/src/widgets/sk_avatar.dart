import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

enum SkAvatarSize { xs, sm, md, lg, xl }

/// Availability marker. Only use it where availability actually matters.
enum SkAvatarStatus { live, out, idle }

/// A person, team, or account. Falls back to initials when no image is supplied.
///
/// One of the only circular shapes in a square system — see [SkRadius].
class SkAvatar extends StatelessWidget {
  const SkAvatar({
    super.key,
    required this.name,
    this.image,
    this.size = SkAvatarSize.md,
    this.status,
  });

  /// Used for the initials and the semantics label.
  final String name;

  /// Real imagery when you have it. No generated or stock fallbacks.
  final ImageProvider? image;

  final SkAvatarSize size;
  final SkAvatarStatus? status;

  double get _px => switch (size) {
        SkAvatarSize.xs => 20,
        SkAvatarSize.sm => 24,
        SkAvatarSize.md => 32,
        SkAvatarSize.lg => 44,
        SkAvatarSize.xl => 64,
      };

  double get _fontSize => switch (size) {
        SkAvatarSize.xs || SkAvatarSize.sm => SkFontSize.xs2,
        SkAvatarSize.md => SkFontSize.xs,
        SkAvatarSize.lg => SkFontSize.sm,
        SkAvatarSize.xl => SkFontSize.lg,
      };

  String get _initials {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return parts.take(2).map((String p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double dot = (_px * 0.28).clamp(6, 14);

    return Semantics(
      label: name,
      image: image != null,
      child: SizedBox(
        width: _px,
        height: _px,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: _px,
              height: _px,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: image != null ? c.surfaceInset : c.fillNeutral,
                border: Border.all(color: c.borderSubtle, width: SkDepth.hairline),
              ),
              child: image != null
                  ? Image(image: image!, fit: BoxFit.cover, width: _px, height: _px)
                  : Text(
                      _initials,
                      style: SkText.label.copyWith(
                        fontSize: _fontSize,
                        color: c.textSecondary,
                        height: 1,
                      ),
                    ),
            ),
            if (status != null)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: switch (status!) {
                      SkAvatarStatus.live => c.textSuccess,
                      SkAvatarStatus.out => c.textDanger,
                      SkAvatarStatus.idle => c.textTertiary,
                    },
                    border: Border.all(color: c.surfaceCard, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

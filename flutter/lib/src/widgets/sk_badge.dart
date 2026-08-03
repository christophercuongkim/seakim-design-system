import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';

/// What the badge is reporting. [accent] is for selection and counts, not status.
enum SkBadgeTone { neutral, accent, success, warning, danger, info }

enum SkBadgeVariant { subtle, solid }

/// A small, non-interactive state label.
///
/// One or two words, sentence case, no terminal punctuation. If it can be clicked
/// it is an SkTag, not a badge.
class SkBadge extends StatelessWidget {
  const SkBadge({
    super.key,
    required this.label,
    this.tone = SkBadgeTone.neutral,
    this.variant = SkBadgeVariant.subtle,
    this.icon,
    this.dot = false,
    this.mono = false,
    this.pill = false,
  });

  final String label;
  final SkBadgeTone tone;
  final SkBadgeVariant variant;

  /// Leading glyph. Drawn at 11px, so it uses bold weight.
  final SkGlyph? icon;

  /// A leading status dot instead of an icon. Use for live and confirmed states.
  final bool dot;

  /// Set for codes and figures — confirmation codes, flight numbers, counts.
  final bool mono;

  /// Pill shape. Reserved for pure counts, which are conceptually round.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final (Color bg, Color fg) = _palette(c);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: pill ? SkSpace.s3 : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: pill ? BorderRadius.circular(SkRadius.pill) : null,
        border: variant == SkBadgeVariant.subtle
            ? Border.all(color: fg.withValues(alpha: 0.22), width: SkDepth.hairline)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (dot) ...<Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...<Widget>[
            SkIcon(icon!, size: 11, weight: SkIconWeight.bold, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (mono ? SkText.data : SkText.label).copyWith(
              fontSize: SkFontSize.xs,
              color: fg,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _palette(SkColors c) {
    final bool solid = variant == SkBadgeVariant.solid;
    switch (tone) {
      case SkBadgeTone.accent:
        return solid ? (c.fillAccent, c.onAccent) : (c.surfaceSelected, c.textAccent);
      case SkBadgeTone.success:
        return solid
            ? (c.textSuccess, c.surfacePage)
            : (c.fillSuccessSubtle, c.textSuccess);
      case SkBadgeTone.warning:
        return solid
            ? (c.textWarning, c.surfacePage)
            : (c.fillWarningSubtle, c.textWarning);
      case SkBadgeTone.danger:
        return solid ? (c.fillDanger, c.onDanger) : (c.fillDangerSubtle, c.textDanger);
      case SkBadgeTone.info:
        return solid ? (c.textInfo, c.surfacePage) : (c.fillInfoSubtle, c.textInfo);
      case SkBadgeTone.neutral:
        return solid
            ? (c.fillNeutralActive, c.textPrimary)
            : (c.fillNeutral, c.textSecondary);
    }
  }
}

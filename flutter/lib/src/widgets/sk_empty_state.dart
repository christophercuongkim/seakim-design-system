import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';

/// What a container says before it has contents.
///
/// Always names the thing that goes here and offers the action that creates it.
/// Never an apology, never an emoji. The one place a dashed border is allowed.
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
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        // The dashed border is drawn by the painter below, since Flutter's Border
        // has no dash support. It exists here and nowhere else in the system.
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: c.borderDefault),
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
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;
  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = SkDepth.hairline;

    void run(Offset from, Offset to) {
      final double total = (to - from).distance;
      final Offset step = (to - from) / total;
      double travelled = 0;
      while (travelled < total) {
        final double end = (travelled + _dash).clamp(0, total);
        canvas.drawLine(from + step * travelled, from + step * end, paint);
        travelled = end + _gap;
      }
    }

    final Offset tl = Offset.zero;
    final Offset tr = Offset(size.width, 0);
    final Offset br = Offset(size.width, size.height);
    final Offset bl = Offset(0, size.height);
    run(tl, tr);
    run(tr, br);
    run(br, bl);
    run(bl, tl);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

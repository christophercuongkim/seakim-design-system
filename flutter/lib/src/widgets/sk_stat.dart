import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';

enum SkStatSize { sm, md, lg }

/// A single measured figure: uppercase mono label, tabular mono value, optional
/// delta.
///
/// Fares and durations in Voyage, points and projections in Bench. Never animate
/// the value — the container may animate, the number cuts.
class SkStat extends StatelessWidget {
  const SkStat({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.deltaDown,
    this.hint,
    this.size = SkStatSize.md,
    this.alignRight = false,
  });

  final String label;
  final String value;

  /// Small trailing unit — pts, kg, percent.
  final String? unit;

  /// Signed change, e.g. +2.4 or -18. A leading minus implies a downward delta.
  final String? delta;

  /// Overrides the sign sniffing when the string has no sign.
  final bool? deltaDown;

  /// One short line under the value.
  final String? hint;

  final SkStatSize size;

  /// Set inside tables so figures align on their right edge.
  final bool alignRight;

  double get _labelSize =>
      size == SkStatSize.sm ? SkFontSize.xs2 : SkFontSize.xs;

  double get _valueSize => switch (size) {
        SkStatSize.sm => SkFontSize.lg,
        SkStatSize.md => SkFontSize.xl2,
        SkStatSize.lg => SkFontSize.xl4,
      };

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool down = deltaDown ?? (delta?.trimLeft().startsWith('-') ?? false);
    final String? deltaText = delta == null
        ? null
        : (delta!.startsWith('-') ? delta!.substring(1) : delta!);

    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: SkText.eyebrow.copyWith(
            fontSize: _labelSize,
            color: c.textTertiary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: SkSpace.s2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              value,
              style: SkText.data.copyWith(
                fontSize: _valueSize,
                color: c.textPrimary,
                height: 1,
                letterSpacing: _valueSize * -0.018,
              ),
            ),
            if (unit != null)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  unit!,
                  style: SkText.data.copyWith(
                    fontSize: _valueSize * 0.6,
                    color: c.textTertiary,
                    height: 1,
                  ),
                ),
              ),
            if (deltaText != null) ...<Widget>[
              const SizedBox(width: SkSpace.s3),
              SkIcon(
                down ? SkIcons.arrowDownRight : SkIcons.arrowUpRight,
                size: 11,
                weight: SkIconWeight.bold,
                color: down ? c.textDanger : c.textSuccess,
              ),
              Text(
                deltaText,
                style: SkText.data.copyWith(
                  fontSize: SkFontSize.xs,
                  color: down ? c.textDanger : c.textSuccess,
                ),
              ),
            ],
          ],
        ),
        if (hint != null) ...<Widget>[
          const SizedBox(height: SkSpace.s2),
          Text(hint!, style: SkText.caption.copyWith(color: c.textTertiary)),
        ],
      ],
    );
  }
}

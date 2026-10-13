import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

enum SkMeterSize { sm, md }

/// A labelled measurement: the label above-left, the value above-right in
/// mono, a thin bar beneath. A fact about something, read at a glance and
/// never in motion. [SkProgress] is for a thing moving towards an end and
/// shares the track style.
///
/// One accent fill, no thresholds: colour-coding a measurement red, amber or
/// green is a judgement the component should not make. [Semantics] carries
/// the label and the value text.
class SkMeter extends StatelessWidget {
  const SkMeter({
    super.key,
    required this.label,
    required this.value,
    this.max = 1,
    this.valueText,
    this.size = SkMeterSize.sm,
  });

  /// What is measured: 'Skills', 'Seniority'.
  final String label;

  /// Current value, clamped to `0..max`.
  final double value;
  final double max;

  /// The figure shown right of the label. Defaults to the percentage.
  final String? valueText;

  /// `sm` is a 4px track (default); `md` is 8px.
  final SkMeterSize size;

  double get _height => size == SkMeterSize.sm ? SkSpace.s2 : SkSpace.s3;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double clamped = max > 0 ? value.clamp(0, max).toDouble() : 0;
    final double fraction = max > 0 ? clamped / max : 0;
    final String text = valueText ?? '${(fraction * 100).round()}%';

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: label,
      value: text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SkText.bodySm.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(width: SkSpace.s4),
              Text(
                text,
                style: SkText.data.copyWith(
                  color: c.textSecondary,
                  fontFeatures: SkText.tabular,
                ),
              ),
            ],
          ),
          const SizedBox(height: SkSpace.s2),
          ClipRRect(
            borderRadius: BorderRadius.circular(SkRadius.pill),
            child: SizedBox(
              height: _height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.surfaceSunken),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: fraction,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.fillAccent,
                        borderRadius: BorderRadius.circular(SkRadius.pill),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

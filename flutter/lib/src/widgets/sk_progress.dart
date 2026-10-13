import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

enum SkProgressSize { sm, md }

/// A determinate linear progress bar: a thin track, an accent fill, an optional
/// label after it ("4 of 13").
///
/// For a thing in motion towards a known end — a wizard, an upload, a trial
/// counter. For a measurement that is not going anywhere, use [SkMeter]; for
/// "something is loading and we do not know how much", [SkSkeleton] or
/// [SkLoadingState] (0021).
///
/// The fill width animates on [SkMotion.base] / [SkMotion.out] and nothing else
/// moves; reduced motion ([MediaQuery.disableAnimations]) renders the new width
/// at once (§0.9). Track and fill take [SkRadius.pill], the rung for toggle
/// tracks and pills (§0.1). [Semantics] carries the value and the label.
class SkProgress extends StatelessWidget {
  const SkProgress({
    super.key,
    required this.value,
    this.max = 100,
    this.label,
    this.size = SkProgressSize.sm,
    this.semanticLabel,
  });

  /// Current value, clamped to `0..max`.
  final double value;
  final double max;

  /// Caption after the bar, e.g. '4 of 13'. Also the semantic label unless
  /// [semanticLabel] is set.
  final String? label;

  /// `sm` is a 4px track (the default, what a wizard uses); `md` is 8px.
  final SkProgressSize size;

  /// What the bar measures when [label] is absent or not descriptive.
  final String? semanticLabel;

  double get _height => size == SkProgressSize.sm ? SkSpace.s2 : SkSpace.s3;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double clamped = max > 0 ? value.clamp(0, max).toDouble() : 0;
    final double fraction = max > 0 ? clamped / max : 0;
    final bool still = MediaQuery.disableAnimationsOf(context);
    final Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(SkRadius.pill),
      child: SizedBox(
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: c.surfaceSunken),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: fraction, end: fraction),
              duration: still ? Duration.zero : SkMotion.base,
              curve: SkMotion.out,
              builder: (BuildContext context, double f, Widget? _) =>
                  FractionallySizedBox(
                widthFactor: f,
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
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel ?? label,
      value: '${(fraction * 100).round()}%',
      child: Row(
        children: <Widget>[
          Expanded(child: bar),
          if (label != null) ...<Widget>[
            const SizedBox(width: SkSpace.s4),
            Text(
              label!,
              style: SkText.caption.copyWith(
                color: c.textSecondary,
                fontFeatures: SkText.tabular,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

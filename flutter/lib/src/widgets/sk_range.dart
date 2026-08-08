import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

enum SkRangeSize { sm, md }

/// A floor/mid/ceiling interval on a shared scale: an achromatic band from [low]
/// to [high] with a marker at [mid], drawn on a shared [domain] so a column of
/// them compares on one scale.
///
/// Achromatic on purpose — a column of intervals is the shared layer, so it stays
/// grey and reads as calm structure. Promote a single instance with [accent], on
/// hover or focus only: never a whole column, and never a *selected* row, whose
/// accent is already spent on its leading border (0003). Colour never encodes the
/// value — floor/expected/ceiling read by position, not hue.
///
/// See decision 0017 and `spec/Range.md`. An output glyph, not a control: no hit
/// area, no hover growth, not focusable.
class SkRange extends StatelessWidget {
  const SkRange({
    super.key,
    required this.low,
    required this.mid,
    required this.high,
    this.domain,
    this.size = SkRangeSize.md,
    this.accent = false,
    this.label,
  });

  /// Interval floor — the left edge of the band.
  final double low;

  /// The point marker inside the band: a mean, median, or current value.
  final double mid;

  /// Interval ceiling — the right edge of the band.
  final double high;

  /// `(min, max)` scale shared across sibling ranges so they compare. Defaults to
  /// `(0, high)` (self-scaled) — a lone glyph only; a column that does not share a
  /// domain is off-spec.
  final (double, double)? domain;

  final SkRangeSize size;

  /// Promote this one instance to the accent fill — one at a time, never a whole
  /// column and never a selected row.
  final bool accent;

  /// Accessible label; defaults to "{low} to {high}, {mid}".
  final String? label;

  double get _track => size == SkRangeSize.sm ? 5 : 7;

  static double _pct(double v, double lo, double hi) {
    if (hi <= lo) return 0;
    final double p = (v - lo) / (hi - lo);
    return p < 0 ? 0 : (p > 1 ? 1 : p);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double d0 = domain?.$1 ?? 0;
    final double d1 = domain?.$2 ?? high;
    final double lo = low < high ? low : high;
    final double hi = low < high ? high : low;
    // --border-emphasis: the marker width, and the band's min-width so a
    // near-zero-spread interval still reads as a tight band, not a smudge (0017).
    const double kEmphasis = 2;

    return Semantics(
      label: label ?? '$lo to $hi, $mid',
      container: true,
      child: SizedBox(
        height: _track,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cn) {
            final double w = cn.maxWidth;
            final double bandL = _pct(lo, d0, d1) * w;
            double bandW = (_pct(hi, d0, d1) * w) - bandL;
            if (bandW < kEmphasis) bandW = kEmphasis;
            final double markL = _pct(mid, d0, d1) * w;
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // Track — full domain width, square corners.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surfaceInset,
                      border: Border.all(color: c.borderSubtle),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                // Band — grey by default, accent when promoted.
                Positioned(
                  left: bandL,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: bandW,
                    color: accent ? c.fillAccent : c.textTertiary,
                  ),
                ),
                // Marker — overshoots the track by 1px top and bottom.
                Positioned(
                  left: markL - kEmphasis / 2,
                  top: -1,
                  bottom: -1,
                  child: Container(width: kEmphasis, color: c.textPrimary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

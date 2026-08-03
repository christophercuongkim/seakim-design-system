// Regenerates lib/src/tokens/palette.g.dart from the CSS token layer.
//
//   dart run tool/gen_tokens.dart
//
// The CSS is the single source of truth for colour. This script exists because
// the brand ramps are written as oklch(L C H) with the hue rotating per app, and
// Dart has no oklch: every step has to be baked to sRGB. Doing that by hand is
// roughly 50 values per app, which is exactly where a design system quietly dies.
//
// Adding an app: add a --hue-<name> to tokens/colors.css and its binding to
// tokens/apps.css, add it to _apps below, re-run. Do not hand-edit the .g.dart.

import 'dart:io';
import 'dart:math' as math;

/// Ramp steps, read from the --brand-* declarations in tokens/colors.css.
const List<(String, double, double)> _ramp = [
  ('s050', 0.96, 0.022),
  ('s100', 0.91, 0.045),
  ('s200', 0.84, 0.075),
  ('s300', 0.80, 0.100),
  ('s400', 0.72, 0.130),
  ('s500', 0.64, 0.140),
  ('s600', 0.56, 0.140),
  ('s700', 0.46, 0.120),
  ('s800', 0.36, 0.095),
  ('s900', 0.26, 0.070),
  ('wash', 0.24, 0.045),
];

/// Dart field name -> (hue, comment).
const Map<String, (double, String)> _apps = {
  'clay': (55, 'SeaKim house, decks'),
  'sea': (245, 'Voyage, travel'),
  'turf': (145, 'Bench, fantasy sport'),
  'plum': (320, 'reserved for app three'),
};

void main() {
  final StringBuffer out = StringBuffer();
  for (final MapEntry<String, (double, String)> app in _apps.entries) {
    final double hue = app.value.$1;
    out.writeln();
    out.writeln('  /// oklch(L C ${hue.toInt()}) — ${app.value.$2}');
    out.writeln('  static const SkBrandRamp ${app.key} = SkBrandRamp(');
    for (final (String step, double l, double c) in _ramp) {
      out.writeln('    $step: Color(${_hex(l, c, hue)}),');
    }
    out.writeln('  );');
  }
  stdout.writeln(out);
  stdout.writeln(
      'Paste the above into the SkBrandRamps class in lib/src/tokens/palette.g.dart,');
  stdout.writeln('or wire this script to rewrite the file in place.');
}

/// oklch -> sRGB hex, with chroma-reduction gamut mapping.
///
/// Naive clipping of out-of-gamut linear RGB shifts hue, which would break the
/// promise that every app's ramp differs only in H. Reducing chroma until the
/// colour fits keeps hue and lightness intact instead.
String _hex(double lightness, double chroma, double hue) {
  List<double> linear = _oklchToLinearSrgb(lightness, chroma, hue);
  if (!_inGamut(linear)) {
    double lo = 0;
    double hi = chroma;
    for (int i = 0; i < 30; i++) {
      final double mid = (lo + hi) / 2;
      final List<double> attempt = _oklchToLinearSrgb(lightness, mid, hue);
      if (_inGamut(attempt)) {
        lo = mid;
        linear = attempt;
      } else {
        hi = mid;
      }
    }
  }
  final String body = linear
      .map((double v) => (_gamma(v).clamp(0.0, 1.0) * 255)
          .round()
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase())
      .join();
  return '0xFF$body';
}

List<double> _oklchToLinearSrgb(double lightness, double chroma, double hue) {
  final double h = hue * math.pi / 180;
  final double a = chroma * math.cos(h);
  final double b = chroma * math.sin(h);

  final double lp = lightness + 0.3963377774 * a + 0.2158037573 * b;
  final double mp = lightness - 0.1055613458 * a - 0.0638541728 * b;
  final double sp = lightness - 0.0894841775 * a - 1.2914855480 * b;

  final double l = lp * lp * lp;
  final double m = mp * mp * mp;
  final double s = sp * sp * sp;

  return <double>[
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
}

bool _inGamut(List<double> rgb) =>
    rgb.every((double v) => v >= -0.0005 && v <= 1.0005);

double _gamma(double v) =>
    v <= 0.0031308 ? 12.92 * v : 1.055 * math.pow(v, 1 / 2.4) - 0.055;

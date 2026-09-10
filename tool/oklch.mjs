/**
 * oklch → sRGB, gamut-mapped by chroma reduction rather than clipping.
 *
 * Lives here rather than inside build-tokens.mjs because the conformance
 * contrast gate needs the same maths, and two implementations of a colour
 * transform is two answers to "what colour is --brand-600 really".
 * Clipping shifts hue; reducing chroma keeps it.
 */
export const oklchToLinear = (L, C, hDeg) => {
  const h = (hDeg * Math.PI) / 180;
  const a = C * Math.cos(h);
  const b = C * Math.sin(h);
  const l_ = L + 0.3963377774 * a + 0.2158037573 * b;
  const m_ = L - 0.1055613458 * a - 0.0638541728 * b;
  const s_ = L - 0.0894841775 * a - 1.2914855480 * b;
  const l = l_ ** 3, m = m_ ** 3, s = s_ ** 3;
  return [
     4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
};

export const gamma = v => (v <= 0.0031308 ? 12.92 * v : 1.055 * v ** (1 / 2.4) - 0.055);
const inGamut = rgb => rgb.every(v => v >= -0.0005 && v <= 1.0005);

/** oklch → 8-bit sRGB, gamut-mapped by chroma reduction rather than clipping. */
export function oklchToRgb(L, C, h) {
  let rgb = oklchToLinear(L, C, h);
  if (!inGamut(rgb)) {
    let lo = 0, hi = C;
    for (let i = 0; i < 30; i++) {
      const mid = (lo + hi) / 2;
      const attempt = oklchToLinear(L, mid, h);
      if (inGamut(attempt)) { lo = mid; rgb = attempt; } else { hi = mid; }
    }
  }
  return rgb.map(v => Math.round(Math.min(1, Math.max(0, gamma(v))) * 255));
}

/** WCAG 2.1 relative luminance and contrast ratio, on 8-bit sRGB triples. */
export const luminance = ([r, g, b]) => {
  const f = c => { c /= 255; return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; };
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
};

export const contrast = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

#!/usr/bin/env node
/**
 * SeaKim conformance check.
 *
 *     node tool/conformance-check.mjs              # check this repo
 *     node tool/conformance-check.mjs ../voyage    # check a consuming repo
 *     node tool/conformance-check.mjs --json       # machine-readable
 *
 * Per decisions/0012. This script ships with the RULES and is invoked from each
 * consuming repo's CI, so Tier 0 has one interpretation rather than one per app.
 *
 * It only covers rules where a violation is unambiguous and a false positive is
 * rare. One accent per screen, whether a shadow is justified, and copy voice are
 * deliberately absent — those are judgement, and a linter that guesses at them
 * teaches people to ignore the linter. See conformance.md for the manual pass.
 *
 * Exit codes: 0 clean, 1 violations found, 2 could not run.
 */

import { readdirSync, readFileSync, statSync, existsSync } from 'node:fs';
import { join, relative, extname, basename } from 'node:path';
import { oklchToRgb, contrast } from './oklch.mjs';

const args = process.argv.slice(2);
const JSON_OUT = args.includes('--json');
const ROOT = args.find(a => !a.startsWith('--')) ?? '.';

if (!existsSync(ROOT)) {
  console.error(`conformance: no such directory: ${ROOT}`);
  process.exit(2);
}

/* ------------------------------------------------------------------ scope */

const SKIP_DIRS = new Set([
  'node_modules', '.git', 'build', 'dist', '.dart_tool', '.next',
  'coverage', 'ios', 'android', 'macos', 'windows', 'linux', 'web',
]);

const EXTS = new Set(['.css', '.jsx', '.tsx', '.ts', '.js', '.dart', '.html', '.mjs']);

/**
 * Files exempt from colour-literal rules because their subject IS the raw palette.
 * Every entry is a small admission that a rule has an edge — if this list grows past
 * a handful, the rule is wrong rather than the code.
 */
const PALETTE_FILES = [
  /tokens\/src\//,
  /tokens\/colors\.css$/,
  /tokens\/theme-light\.css$/,
  /tokens\/apps\.css$/,
  /tokens\/depth\.css$/,
  /tokens\/generated\//,
  /palette\.g\.dart$/,
  /sk_colors\.dart$/,          // maps the palette onto semantic names
  /guidelines\/colors-/,        // colour specimen cards
  /guidelines\/proposed-/,      // deliberately shows rejected alternatives
  /tool\/(build-tokens|conformance-check)\.mjs$/,
  /signoff\.html$/,             // shows the alternatives that lost
  /theme-toggle\.js$/,
  /ds-shim\.js$/,
];

/** Files exempt from the geometry rules — slides are a fixed-canvas medium. */
/** Files that legitimately NAME a typeface: the token file that declares them, the
 *  loader that fetches them, and the specimens whose subject is the face itself. */
const TYPE_EXEMPT = [
  /tokens\/fonts\.css$/,
  /fonts\.ts$/,
  /guidelines\/type-/,
  /index\.html$/,
  /signoff\.html$/,
];

const GEOMETRY_EXEMPT = [
  /tokens\/radius\.css$/,
  /tokens\/spacing\.css$/,
  /tokens\/layout\.css$/,
  /tokens\/depth\.css$/,
  /guidelines\//,
  /slides\//,
  /signoff\.html$/,
  /index\.html$/,
  /tool\//,
];

/**
 * The two sanctioned loading treatments own their motion, so the rotation rule
 * does not apply to their own source — the same kind of admission as the palette
 * exemptions above. The checker itself names the banned symbols, so exempt it too.
 */
const LOADING_TREATMENT_FILES = [
  /components\/feedback\/Skeleton\./,
  /components\/feedback\/LoadingState\./,
  /flutter\/lib\/src\/widgets\/sk_skeleton\.dart$/,
  /flutter\/lib\/src\/widgets\/sk_loading_state\.dart$/,
  /tool\/conformance-check\.mjs$/,
];

const exempt = (file, list) => list.some(re => re.test(file.replace(/\\/g, '/')));

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    if (entry.startsWith('.') && entry !== '.') continue;
    const full = join(dir, entry);
    let s;
    try { s = statSync(full); } catch { continue; }
    if (s.isDirectory()) {
      if (SKIP_DIRS.has(entry)) continue;
      walk(full, out);
    } else if (EXTS.has(extname(entry))) {
      out.push(full);
    }
  }
  return out;
}

/* ------------------------------------------------------------------ rules */

const violations = [];

function report(rule, file, line, text, detail) {
  violations.push({
    rule,
    file: relative(ROOT, file).replace(/\\/g, '/') || basename(file),
    line,
    detail,
    text: text.trim().slice(0, 100),
  });
}

/** Strip comments and string-literal noise that would cause false positives. */
function stripNoise(src) {
  return src
    .replace(/\/\*[\s\S]*?\*\//g, m => m.replace(/[^\n]/g, ' '))
    .replace(/(^|[^:])\/\/[^\n]*/g, (m, pre) => pre + ' '.repeat(m.length - pre.length));
}

/**
 * The corner ladder (0030). Encoded HERE, not merely referenced, because the old
 * rule asserted a vocabulary and never a value: it whitelisted three token names
 * and never opened tokens/radius.css, so a full non-zero ladder could be swapped
 * into the tokens with every gate still green (lesson 17). These numbers are the
 * assertion — tokens/radius.css and SkRadius are both checked against them below.
 */
const LADDER = [
  ['none', 0], ['xs', 2], ['sm', 4],
  ['lg', 8], ['xl', 12], ['full', 999],
];
// 0035 pruned `md` and `2xl` — no component named them after controls moved to `lg`
// and cards to `xl`. `pill` predates the ladder.
const DART_ALIAS = { full: 'pill' };
const CSS_RUNGS = [...LADDER.map(([n]) => n), 'circle'];
const DART_RUNGS = LADDER.map(([n]) => DART_ALIAS[n] ?? n);

const RULES = [
  {
    id: 'literal-colour',
    clause: '0.4',
    tier: 0,
    why: 'Semantic tokens only. A literal colour cannot follow the theme or the app accent.',
    skip: f => exempt(f, PALETTE_FILES),
    test(line) {
      // hex, rgb(), hsl() — but allow fully transparent and pure-black scrims
      const hex = line.match(/#[0-9a-fA-F]{3,8}\b/g) || [];
      const fn = line.match(/\b(?:rgba?|hsla?)\s*\(/g) || [];
      const real = hex.filter(h => !/^#(0{3,4}|0{6,8})$/i.test(h));
      if (real.length) return `literal colour ${real[0]}`;
      if (fn.length && !/\(\s*0\s*,\s*0\s*,\s*0\s*,\s*0/.test(line)) return `literal ${fn[0].trim()}`;
      return null;
    },
  },
  {
    id: 'composed-alpha',
    clause: '0.4',
    tier: 0,
    why: 'An alpha variant is a token, not a per-component constant — see decision 0013.',
    skip: f => exempt(f, PALETTE_FILES),
    test(line) {
      // Dart: c.fillAccent.withValues(alpha: 0.32) / .withOpacity(0.32)
      const dart = /\.with(?:Opacity\s*\(|Values\s*\([^)]*alpha\s*:)/.test(line);
      // CSS: rgb(var(--fill-accent) / 32%) and friends
      const css = /\b(?:rgba?|hsla?)\s*\(\s*var\(/.test(line);
      if (!dart && !css) return null;
      return 'alpha composed onto a colour in component code — give it a token';
    },
  },
  {
    id: 'raw-ramp-step',
    clause: '0.4',
    tier: 0,
    why: 'Components read the semantic layer, never a stone or brand ramp step directly.',
    skip: f => exempt(f, PALETTE_FILES),
    test(line) {
      const m = line.match(/var\(\s*--(?:stone|brand)-\d+/) || line.match(/\bSkStone\.s\d+/) || line.match(/\bSkBrandRamps?\.\w+/);
      return m ? `reads ${m[0]} instead of a semantic token` : null;
    },
  },
  {
    id: 'untokenised-radius',
    clause: '0.1',
    tier: 0,
    why: 'Every corner names a rung of the closed ladder — decision 0030. No literal radius, and no rung that is not in tokens/radius.css.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      // Cheap gate first: most lines are not about corners at all.
      if (!/border-?[Rr]adius|BorderRadius\.circular/.test(line)) return null;

      // A named rung must exist. This is the branch the old rule could not reach:
      // it whitelisted three token NAMES and never saw the camelCase
      // `borderRadius: 'var(...)'` form React actually writes.
      for (const m of line.matchAll(/--radius-([A-Za-z0-9]+)/g)) {
        if (!CSS_RUNGS.includes(m[1])) return `--radius-${m[1]} is not a rung in the ladder`;
      }
      for (const m of line.matchAll(/SkRadius\.([A-Za-z]+)/g)) {
        if (!DART_RUNGS.includes(m[1])) return `SkRadius.${m[1]} is not a rung in the ladder`;
      }

      // A literal in a radius position. Bare 0 stays legal — it renders as
      // --radius-none and reads unambiguously in a reset.
      const lit = line.match(/border-radius\s*:\s*([0-9.]+)(px|rem|em|%)/)
        || line.match(/borderRadius:\s*['"`]?([0-9.]+)(px|rem|em)/)
        || line.match(/BorderRadius\.circular\(\s*([0-9.]+)\s*\)/);
      if (lit && Number(lit[1]) !== 0) {
        return `literal radius ${lit[1]}${lit[2] ?? ''} — name a rung instead`;
      }
      return null;
    },
  },
  {
    id: 'literal-font-family',
    clause: '0.4',
    tier: 0,
    why: 'A typeface is a token. Tier 1 fixes the family set (0031) and leaves delivery free — but component code reads --font-* / SkFonts, never a family name.',
    skip: f => exempt(f, TYPE_EXEMPT),
    test(line) {
      const m = line.match(/font-?[Ff]amily\s*[:=]\s*(['"`])([^'"`]+)\1/);
      if (!m) return null;
      // A quoted value that RESOLVES a token is fine: the CSS var form, and Dart's
      // interpolation — ThemeData.fontFamily takes no package argument, so the
      // family has to be string-prefixed by hand around ${SkFonts.x}.
      if (/var\(--font-|\$\{?SkFonts\./.test(m[2])) return null;
      return `font family named directly: ${m[2].slice(0, 40)}`;
    },
  },
  {
    id: 'disabled-opacity',
    clause: '0.4',
    tier: 0,
    why: 'Disabled is a token. Blanket opacity survives dark and collapses in light — see decision 0005.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      // `enabled ? 1 : 0.5` is the same violation stated the other way round, and
      // read past this rule for months because it never says "disabled".
      if (!/disabled|\benabled\b|\boff\b/i.test(line)) return null;
      const m = line.match(/opacity[^;,)]*?(0?\.[1-9]\d*)/);
      return m ? `opacity ${m[1]} on a disabled state — use --fill-disabled / --text-disabled` : null;
    },
  },
  {
    id: 'suppressed-focus',
    clause: '0.6',
    tier: 0,
    why: 'Focus is always visible. Never remove the outline without providing a ring.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line, ctx) {
      if (!/outline\s*:\s*(none|0)\b/.test(line)) return null;
      // acceptable when a focus ring is provided nearby
      if (/box-shadow|focus-ring|--focus/.test(ctx)) return null;
      return 'outline removed with no replacement focus ring';
    },
  },
  {
    id: 'unlabelled-icon-control',
    clause: '0.6',
    tier: 0,
    why: 'Every icon-only control carries a label — it becomes the accessible name and the tooltip.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      const m = line.match(/<IconButton\b[^>]*\/?>/) || line.match(/SkIconButton\(/);
      if (!m) return null;
      const chunk = m[0];
      if (/\blabel\s*[:=]/.test(chunk)) return null;
      // multi-line JSX: only flag when the tag closes on this line
      if (/<IconButton\b[^>]*>/.test(chunk) && !/\blabel=/.test(chunk)) {
        return 'IconButton without a label';
      }
      return null;
    },
  },
  {
    id: 'hardcoded-touch-target',
    clause: '0.7',
    tier: 0,
    why: '44px is the touch floor. Use --control-h-touch so it moves with the token.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      if (!/(min-height|minHeight|height)\s*[:=]\s*['"`]?4[0-3]px/.test(line)) return null;
      if (!/touch|tap|row|item|button/i.test(line)) return null;
      const m = line.match(/4[0-3]px/);
      return `${m[0]} on what looks like a touch target — floor is 44px`;
    },
  },
  {
    id: 'indefinite-rotation',
    clause: '0.13',
    tier: 0,
    why: 'No indefinite rotation as a loading affordance — SeaKim has no spinner (0021). Use a skeleton (known shape) or the labeled loading state (unknown outcome).',
    skip: f => exempt(f, LOADING_TREATMENT_FILES),
    test(line) {
      // Flutter: the banned Material spinner, and the hand-rolled rotation that
      // is the same bug without the word "spinner" in it.
      if (/\bCircularProgressIndicator\b/.test(line)) return 'CircularProgressIndicator — a bare spinner (0021)';
      if (/\bRotationTransition\b/.test(line)) return 'RotationTransition as a loader — an indefinite rotation (0021)';
      // CSS/React: an infinite animation that rotates (or a spun round element).
      if (/animation[^;{]*\binfinite\b/.test(line) && /\brotate\b|\bspin\b/i.test(line)) {
        return 'infinite rotate animation as a loader (0021)';
      }
      return null;
    },
  },
  {
    id: 'press-transform',
    clause: '0.15',
    tier: 0,
    why: 'Press is a tint, and nothing overshoots (0034). No press scale, no spring or pop easing, no retired motion token.',
    skip: f => /tool\/conformance-(check|selftest)\.mjs$/.test(f.replace(/\\/g, '/')),
    test(line, ctx) {
      const tok = line.match(/--(?:press-scale(?:-lg)?|ease-spring|ease-pop|transition-spring)\b/)
        || line.match(/\bSkMotion\.(?:spring|pop|pressScale(?:Large)?)\b/);
      if (tok) return `${tok[0]} was retired by 0034 — press is a tint, easing is --ease-out / SkMotion.out`;
      // A transform that scales while pressed/active — CSS, inline React, or Dart.
      if (/scale\s*\(/.test(line) && /\b(?:press(?:ed)?|active)\b/i.test(line) && /transform|:active/.test(line)) {
        return 'scales on press — press feedback is a fill change, never a transform (0034)';
      }
      if (/\bAnimatedScale\s*\(/.test(line) && /\bpress(?:ed)?\b/i.test(ctx ?? '')) {
        return 'AnimatedScale driven by press — press feedback is a fill change (0034)';
      }
      return null;
    },
  },
  {
    id: 'inset-shadow-border',
    clause: '0.16',
    tier: 0,
    why: 'A ring, bar or edge is a border, never an inset or spread-only box-shadow standing in for one (0037). Shadows lift overlays; they do not draw lines.',
    // The depth tokens define the focus ring (a box-shadow by design, §0.6); components read it
    // by name, and a ring that names --border-focus is that ring, not a border in disguise.
    // The specimen pages that show rejected alternatives are exempt like the colour rules.
    skip: f => exempt(f, PALETTE_FILES) || /sk_depth\.dart$|tool\/conformance-(check|selftest)\.mjs$/.test(f.replace(/\\/g, '/')),
    test(line, ctx) {
      if (/box-?[Ss]hadow/.test(line) && !/--border-focus|focus-ring/.test(line)) {
        if (/\binset\s+-?\d+px\s+-?\d+px\s+0\b/.test(line) || /\binset\s+0\s+0\s+0\s+\d+px/.test(line)) {
          return 'inset box-shadow drawn as a border or bar — use a border (0037)';
        }
        if (/(?:^|[^-\w])0\s+0\s+0\s+\d+px\s+var\(/.test(line)) {
          return 'spread-only box-shadow drawn as a ring — use a border or outline (0037)';
        }
      }
      if (/\bBoxShadow\s*\(/.test(line) && /spreadRadius/.test(ctx ?? '')) {
        return 'spread-only BoxShadow drawn as a ring — use a Border (0037)';
      }
      return null;
    },
  },
];

/* ------------------------------------------------------------------- run */

const files = walk(ROOT);
let scanned = 0;

for (const file of files) {
  let src;
  try { src = readFileSync(file, 'utf8'); } catch { continue; }
  if (src.includes('conformance-check: ignore-file')) continue;
  scanned++;

  const clean = stripNoise(src);
  const lines = clean.split('\n');
  const rawLines = src.split('\n');

  for (const rule of RULES) {
    if (rule.skip && rule.skip(file)) continue;
    for (let i = 0; i < lines.length; i++) {
      if (/conformance-check: ignore/.test(rawLines[i])) continue;
      const ctx = lines.slice(Math.max(0, i - 3), i + 4).join('\n');
      const detail = rule.test(lines[i], ctx);
      if (detail) report(rule.id, file, i + 1, rawLines[i], detail);
    }
  }
}

/* -------------------------------------------------- cross-binding parity */

/**
 * Values shared across bindings that have no generated source yet (dimensions —
 * 0007 phase 2 is not started) are hand-authored in each binding, so they can
 * drift silently. The sheet width did exactly that (480 vs 460). Assert the
 * shared ones stay equal. A consuming repo that carries only one side is skipped.
 */
const PARITY = [
  {
    id: 'accent-text-step-parity',
    why: 'The light-theme accent text step is hand-mapped in both bindings. It drifted to a sub-4.5:1 step once already (lesson 18); if CSS and Dart name different rungs, one binding is under the contrast floor.',
    a: { file: 'tokens/theme-light.css', re: /--text-accent:\s*var\(--brand-(\d+)\)/ },
    b: {
      file: 'flutter/lib/src/tokens/sk_colors.dart',
      // Scoped to SkColors.light — the dark factory names textAccent too.
      scope: src => src.slice(src.indexOf('factory SkColors.light')),
      re: /textAccent: brand\.s(\d+),/,
    },
  },
  {
    id: 'overlay-width-parity',
    why: 'The dialog max-width is hand-authored in both bindings (no dimension token source yet, 0007 phase 2). Keep the Dart constant and the CSS token equal, or overlays drift across bindings.',
    a: { file: 'flutter/lib/src/tokens/sk_space.dart', re: /overlayDialogW\s*=\s*(\d+(?:\.\d+)?)/ },
    b: { file: 'tokens/spacing.css', re: /--overlay-w-dialog\s*:\s*(\d+(?:\.\d+)?)px/ },
  },
];

function readNumber({ file, re, scope }) {
  try {
    let src = readFileSync(join(ROOT, file), 'utf8');
    if (scope) src = scope(src);
    const m = src.match(re);
    return m ? Number(m[1]) : null;
  } catch { return null; }
}

/**
 * The ladder is a value contract, so read the values. CSS and Dart are each
 * compared to LADDER rather than to each other — comparing the two bindings alone
 * would pass happily if both drifted the same way.
 */
const LADDER_FILES = [
  {
    file: 'tokens/radius.css',
    re: n => new RegExp(`--radius-${n}\\s*:\\s*(\\d+(?:\\.\\d+)?)px`),
  },
  {
    file: 'flutter/lib/src/tokens/sk_space.dart',
    // Scoped to the SkRadius body: sk_space.dart also declares SkSpace and the
    // control heights, where `md = 34` is a control height, not a corner.
    scope: src => (src.match(/class SkRadius \{[\s\S]*?\n\}/) ?? [''])[0],
    re: n => new RegExp(`\\b${DART_ALIAS[n] ?? n}\\s*=\\s*(\\d+(?:\\.\\d+)?)\\s*;`),
  },
];

for (const { file, re, scope } of LADDER_FILES) {
  let src;
  try {
    src = readFileSync(join(ROOT, file), 'utf8');
  } catch {
    continue; // a consuming repo carrying only one binding
  }
  if (scope) src = scope(src);
  // A file that exists but carries no ladder at all — a consuming repo with its own
  // sk_space.dart, or a binding that has not adopted 0030 — is out of scope, not
  // eight missing rungs. Absent and empty mean the same thing here.
  if (!src.trim()) continue;
  for (const [name, want] of LADDER) {
    const m = src.match(re(name));
    const got = m ? Number(m[1]) : null;
    if (got === want) continue;
    violations.push({
      rule: 'radius-ladder-drift',
      file,
      line: 0,
      detail: got === null
        ? `rung \`${name}\` is missing — the ladder in 0030 has ${LADDER.length} rungs`
        : `rung \`${name}\` is ${got}, the ladder says ${want}`,
      text: 'The corner ladder is fixed by decision 0030. Change it there and in tool/conformance-check.mjs together, per 0012 — never in one binding alone.',
    });
  }
}

/**
 * Motion is a value contract too (0034): every curve eases out and every duration
 * sits at or under 150ms. Read the numbers from both bindings' token files rather
 * than trusting names — a `--ease-out` that overshoots is the lesson-17 shape.
 */
const MOTION_CEILING_MS = 150;
const MOTION_FILES = [
  {
    file: 'tokens/motion.css',
    curves: /cubic-bezier\(\s*([\d.]+)\s*,\s*(-?[\d.]+)\s*,\s*([\d.]+)\s*,\s*(-?[\d.]+)\s*\)/g,
    durations: /--dur-([\w-]+)\s*:\s*(\d+)ms/g,
  },
  {
    file: 'flutter/lib/src/tokens/sk_motion.dart',
    curves: /Cubic\(\s*([\d.]+)\s*,\s*(-?[\d.]+)\s*,\s*([\d.]+)\s*,\s*(-?[\d.]+)\s*\)/g,
    durations: /Duration\s+(\w+)\s*=\s*Duration\(milliseconds:\s*(\d+)\)/g,
  },
];

for (const { file, curves, durations } of MOTION_FILES) {
  let src;
  try {
    src = readFileSync(join(ROOT, file), 'utf8');
  } catch {
    continue; // a consuming repo carrying only one binding
  }
  src = src.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/[^\n]*/g, '');
  for (const m of src.matchAll(curves)) {
    if (Number(m[2]) > 1 || Number(m[4]) > 1) {
      violations.push({
        rule: 'overshoot-easing', clause: '0.15', file, line: 0,
        detail: `curve (${m[1]}, ${m[2]}, ${m[3]}, ${m[4]}) overshoots — a control point above 1`,
        text: 'Every easing eases out (0034). Change it there and in tool/conformance-check.mjs together, per 0012.',
      });
    }
  }
  for (const m of src.matchAll(durations)) {
    if (/shimmer/i.test(m[1])) continue; // a loop, not a transition (0021)
    if (Number(m[2]) > MOTION_CEILING_MS) {
      violations.push({
        rule: 'overshoot-easing', clause: '0.15', file, line: 0,
        detail: `duration ${m[1]} is ${m[2]}ms — the ceiling is ${MOTION_CEILING_MS}ms`,
        text: 'Every duration sits at or under 150ms (0034). The shimmer loop is the one exemption.',
      });
    }
  }
}

for (const p of PARITY) {
  const a = readNumber(p.a);
  const b = readNumber(p.b);
  if (a == null || b == null) continue; // one side absent — nothing to compare
  if (a !== b) {
    violations.push({
      rule: p.id,
      file: `${p.a.file} vs ${p.b.file}`,
      line: 0,
      detail: `${p.a.file}=${a} but ${p.b.file}=${b} — they must match`,
      text: p.why,
    });
  }
}

/* ------------------------------------------------------- contrast (0005) */

/**
 * guidelines/accessibility.md states the floors and nothing checked them: the
 * numbers were written down and the gate never read them. Resolve the semantic
 * pairs for real — every app, both themes — and measure.
 *
 * 0019 makes a revalue that "fails a documented contrast gate" Major. This is
 * that gate; before it existed the clause had nothing to point at.
 */
const CONTRAST_PAIRS = [
  ['--text-primary', '--surface-page', 4.5, true],
  ['--text-primary', '--surface-card', 4.5, true],
  ['--text-secondary', '--surface-page', 4.5, true],
  ['--text-secondary', '--surface-card', 4.5, true],
  ['--text-accent', '--surface-card', 4.5, true],
  ['--text-link', '--surface-card', 4.5, true],
  ['--text-danger', '--surface-card', 4.5, true],
  ['--on-accent', '--fill-accent', 4.5, true],
  ['--border-focus', '--surface-card', 3.0, true],
  ['--on-primary', '--fill-primary', 4.5, true],
  // Gated as of the stone-450/550 split. It sat at 4.12:1 / 4.38:1 on a single
  // mid step, which no grey can fix for both themes at once — see lesson 18.
  ['--text-tertiary', '--surface-card', 4.5, true],
  ['--text-tertiary', '--surface-page', 4.5, true],
];

const notes = [];

function cssDecls(src, want) {
  const out = {};
  for (const m of src.matchAll(/([^{}]+)\{([^}]*)\}/g)) {
    const sel = m[1].replace(/\s+/g, ' ').trim();
    if (want && !want.test(sel)) continue;
    for (const d of m[2].matchAll(/(--[\w-]+)\s*:\s*([^;]+)/g)) out[d[1]] = d[2].trim();
  }
  return out;
}

function toRgb(name, map, depth = 0) {
  if (depth > 8) return null;
  const v = map[name]?.trim();
  if (!v) return null;
  const ref = v.match(/^var\(\s*(--[\w-]+)/);
  if (ref) return toRgb(ref[1], map, depth + 1);
  const hx = v.match(/^#([0-9a-fA-F]{6})$/);
  if (hx) return [0, 2, 4].map(i => parseInt(hx[1].slice(i, i + 2), 16));
  const ok = v.match(/^oklch\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)/);
  if (ok) return oklchToRgb(+ok[1], +ok[2], +ok[3]);
  return null;
}

try {
  const strip = f => readFileSync(join(ROOT, f), 'utf8').replace(/\/\*[\s\S]*?\*\//g, '');
  const base = cssDecls(strip('tokens/colors.css'));
  const light = cssDecls(strip('tokens/theme-light.css'));
  const appsSrc = strip('tokens/apps.css');
  const apps = {};
  for (const m of appsSrc.matchAll(/\[data-app="(\w+)"\][^{]*\{([^}]*)\}/g)) {
    if (apps[m[1]]) continue;
    apps[m[1]] = cssDecls(`x{${m[2]}}`);
  }

  for (const [app, appVars] of Object.entries(apps)) {
    for (const [theme, over] of [['dark', {}], ['light', light]]) {
      const map = { ...base, ...appVars, ...over };
      for (const [fg, bg, min, gated] of CONTRAST_PAIRS) {
        const F = toRgb(fg, map), B = toRgb(bg, map);
        if (!F || !B) continue; // a consuming repo may not carry every token
        const r = contrast(F, B);
        if (r >= min) continue;
        const line = `${app}/${theme}: ${fg} on ${bg} is ${r.toFixed(2)}:1, floor is ${min}:1`;
        if (gated) {
          violations.push({
            rule: 'contrast-floor', clause: '0.8', file: 'tokens/', line: 0, detail: line,
            text: 'guidelines/accessibility.md sets the floor. A revalue that breaks it is Major per 0019.',
          });
        } else {
          notes.push(line);
        }
      }
    }
  }

  /* ------------------------------------------------- ink primary (0036) */

  // The primary action carries no hue in either theme. Read the resolved value:
  // a warm stone step spreads its channels by a few units; any brand step by dozens.
  const INK_SPREAD = 12;
  const firstApp = Object.values(apps)[0] ?? {};
  for (const [theme, over] of [['dark', {}], ['light', light]]) {
    const F = toRgb('--fill-primary', { ...base, ...firstApp, ...over });
    if (!F) continue;
    const scaled = Math.max(...F) <= 1 ? F.map(v => v * 255) : F;
    const spread = Math.max(...scaled) - Math.min(...scaled);
    if (spread > INK_SPREAD) {
      violations.push({
        rule: 'ink-primary', clause: '0.3', file: 'tokens/', line: 0,
        detail: `${theme}: --fill-primary resolves to rgb(${scaled.map(Math.round).join(', ')}) — channel spread ${spread.toFixed(0)}, ink allows ${INK_SPREAD}`,
        text: 'The primary action is ink (0036). Point --fill-primary at a stone step, not a brand step.',
      });
    }
  }
} catch {
  // Token files absent — a consuming repo running the checker over its own source.
}

/* ------------------------------------------------ alpha hairlines (0037) */

/**
 * A hairline is alpha in both themes so one token composes on any surface. Read the
 * resolved value of each border role: color-mix(... N%, transparent), rgba(), or an
 * oklch/hsl with a slash alpha all carry one; a hex or a stone var is opaque.
 */
const HAIRLINE_ROLES = ['--border-subtle', '--border-default', '--border-strong'];
function cssAlpha(v) {
  if (!v) return null;
  let m = v.match(/color-mix\([^,]+,\s*[^\s,]+\s+([\d.]+)%\s*,\s*transparent\s*\)/);
  if (m) return Number(m[1]) / 100;
  m = v.match(/\b(?:rgba?|hsla?)\([^)]*,\s*([\d.]+)\s*\)/);
  if (m) return Number(m[1]);
  m = v.match(/\/\s*([\d.]+)(%?)\s*\)/);
  if (m) return m[2] ? Number(m[1]) / 100 : Number(m[1]);
  return 1;
}
for (const [theme, file] of [['dark', 'tokens/colors.css'], ['light', 'tokens/theme-light.css']]) {
  let decls;
  try {
    decls = cssDecls(readFileSync(join(ROOT, file), 'utf8').replace(/\/\*[\s\S]*?\*\//g, ''));
  } catch {
    continue;
  }
  for (const role of HAIRLINE_ROLES) {
    if (!(role in decls)) continue;
    const a = cssAlpha(decls[role]);
    if (a >= 1) {
      violations.push({
        rule: 'alpha-hairline', clause: '0.16', file, line: 0,
        detail: `${theme}: ${role} is opaque (${decls[role]}) — a hairline is alpha (0037)`,
        text: 'Fills and gaps define; a hairline is the exception, and it is alpha. Give it an alpha raw token.',
      });
    }
  }
}
try {
  const dart = readFileSync(join(ROOT, 'flutter/lib/src/tokens/sk_colors.dart'), 'utf8');
  const palette = readFileSync(join(ROOT, 'flutter/lib/src/tokens/palette.g.dart'), 'utf8');
  for (const theme of ['dark', 'light']) {
    const at = dart.indexOf(`factory SkColors.${theme}`);
    if (at < 0) continue;
    const next = dart.indexOf('factory SkColors.', at + 1);
    const scope = dart.slice(at, next > 0 ? next : undefined);
    for (const role of ['borderSubtle', 'borderDefault', 'borderStrong']) {
      const m = scope.match(new RegExp(`${role}:\\s*(\\w+)\\.(\\w+)`));
      if (!m) continue;
      let opaque = m[1] !== 'SkRawColors';
      if (!opaque) {
        const c = palette.match(new RegExp(`static const Color ${m[2]} = Color\\(0x([0-9A-Fa-f]{2})`));
        opaque = !c || c[1].toUpperCase() === 'FF';
      }
      if (opaque) {
        violations.push({
          rule: 'alpha-hairline', clause: '0.16', file: 'flutter/lib/src/tokens/sk_colors.dart', line: 0,
          detail: `SkColors.${theme}: ${role} reads ${m[1]}.${m[2]}, which is opaque — a hairline is alpha (0037)`,
          text: 'Fills and gaps define; a hairline is the exception, and it is alpha, in every binding.',
        });
      }
    }
  }
} catch {
  // No Flutter binding here.
}

// The Dart side of the same rule: SkColors maps fillPrimary onto SkStone in both factories.
try {
  const dart = readFileSync(join(ROOT, 'flutter/lib/src/tokens/sk_colors.dart'), 'utf8');
  for (const theme of ['dark', 'light']) {
    const at = dart.indexOf(`factory SkColors.${theme}`);
    if (at < 0) continue;
    const scope = dart.slice(at, dart.indexOf('factory SkColors.', at + 1) > 0 ? dart.indexOf('factory SkColors.', at + 1) : undefined);
    const m = scope.match(/fillPrimary:\s*(\w+)\./);
    if (m && m[1] !== 'SkStone') {
      violations.push({
        rule: 'ink-primary', clause: '0.3', file: 'flutter/lib/src/tokens/sk_colors.dart', line: 0,
        detail: `SkColors.${theme}: fillPrimary reads ${m[1]} — ink is a stone step (0036)`,
        text: 'The primary action is ink in every binding (0036).',
      });
    }
  }
} catch {
  // No Flutter binding here.
}

/* ---------------------------------------------------------------- output */

if (JSON_OUT) {
  console.log(JSON.stringify({ scanned, violations }, null, 2));
  process.exit(violations.length ? 1 : 0);
}

const byRule = new Map();
for (const v of violations) {
  if (!byRule.has(v.rule)) byRule.set(v.rule, []);
  byRule.get(v.rule).push(v);
}

console.log(`\nSeaKim conformance — ${scanned} files in ${ROOT}\n`);

if (notes.length && !JSON_OUT) {
  console.log('  below the 4.5:1 floor, reported not failed:');
  for (const n of [...new Set(notes)]) console.log(`   \u00b7  ${n}`);
  console.log('');
}

if (!violations.length) {
  console.log('  clean\n');
  console.log('  Machine-checkable Tier 0 rules pass. The manual review in conformance.md');
  console.log('  still applies — one accent per screen, justified shadows, and copy voice');
  console.log('  are judgement, not lint.\n');
  process.exit(0);
}

for (const [ruleId, list] of byRule) {
  const rule = RULES.find(r => r.id === ruleId)
    ?? { tier: 0, why: PARITY.find(p => p.id === ruleId)?.why ?? '' };
  const clause = rule.clause ?? list[0]?.clause;
  console.log(`  TIER ${rule.tier}${clause ? `  §${clause}` : ''}  ${ruleId}  (${list.length})`);
  console.log(`          ${rule.why}\n`);
  for (const v of list.slice(0, 12)) {
    console.log(`    ${v.file}:${v.line}`);
    console.log(`      ${v.detail}`);
    console.log(`      | ${v.text}`);
  }
  if (list.length > 12) console.log(`    … and ${list.length - 12} more`);
  console.log('');
}

console.log(`  ${violations.length} violation(s).\n`);
console.log('  A legitimate exception gets a `conformance-check: ignore` comment on the line,');
console.log('  or `conformance-check: ignore-file` anywhere in the file. If you are adding more');
console.log('  than a handful, the rule is wrong rather than the code — write an ADR.\n');

process.exit(1);

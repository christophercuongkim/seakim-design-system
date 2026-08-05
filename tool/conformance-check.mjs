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

const RULES = [
  {
    id: 'literal-colour',
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
    id: 'raw-ramp-step',
    tier: 0,
    why: 'Components read the semantic layer, never a stone or brand ramp step directly.',
    skip: f => exempt(f, PALETTE_FILES),
    test(line) {
      const m = line.match(/var\(\s*--(?:stone|brand)-\d+/) || line.match(/\bSkStone\.s\d+/) || line.match(/\bSkBrandRamps?\.\w+/);
      return m ? `reads ${m[0]} instead of a semantic token` : null;
    },
  },
  {
    id: 'non-zero-radius',
    tier: 0,
    why: 'Corners are 0px. Round only where the shape is conceptually round — use --radius-full or --radius-circle.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      const css = line.match(/border-radius\s*:\s*([^;}]+)/);
      if (css) {
        const v = css[1].trim();
        if (/var\(--radius-(?:none|full|circle)\)/.test(v)) return null;
        if (/^0(px|rem|%)?$/.test(v)) return null;
        if (/50%|999/.test(v)) return null;
        return `border-radius: ${v}`;
      }
      const dart = line.match(/BorderRadius\.circular\(\s*([\d.]+)/);
      if (dart && Number(dart[1]) > 0 && Number(dart[1]) < 900) {
        return `BorderRadius.circular(${dart[1]})`;
      }
      if (/borderRadius:\s*['"`]?\d+px/.test(line)) {
        const m = line.match(/borderRadius:\s*['"`]?(\d+)px/);
        if (m && m[1] !== '0') return `borderRadius: ${m[1]}px`;
      }
      return null;
    },
  },
  {
    id: 'disabled-opacity',
    tier: 0,
    why: 'Disabled is a token. Blanket opacity survives dark and collapses in light — see decision 0005.',
    skip: f => exempt(f, GEOMETRY_EXEMPT),
    test(line) {
      if (!/disabled|\boff\b/i.test(line)) return null;
      const m = line.match(/opacity[^;,)]*?(0?\.[1-9]\d*)/);
      return m ? `opacity ${m[1]} on a disabled state — use --fill-disabled / --text-disabled` : null;
    },
  },
  {
    id: 'suppressed-focus',
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

if (!violations.length) {
  console.log('  clean\n');
  console.log('  Machine-checkable Tier 0 rules pass. The manual review in conformance.md');
  console.log('  still applies — one accent per screen, justified shadows, and copy voice');
  console.log('  are judgement, not lint.\n');
  process.exit(0);
}

for (const [ruleId, list] of byRule) {
  const rule = RULES.find(r => r.id === ruleId);
  console.log(`  TIER ${rule.tier}  ${ruleId}  (${list.length})`);
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

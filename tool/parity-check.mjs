#!/usr/bin/env node
// parity-check — every React component has a Flutter widget and vice versa
// (decision 0039). The two existing coverage gates each read one binding and
// never compare them, so a component could ship on one side only and both
// gates stay green. This one opens both.
//
// Correspondence is by name: React `PascalCase` ⇄ `flutter/lib/src/widgets/
// sk_<snake_case>.dart` exported from the barrel. Where Flutter's idiom is a
// function (Sheet → showSkSheet), the `flutter/README.md` mapping table is the
// declaration, and the named symbol must be defined in a barrel-exported file.
// Flutter-only primitives are allowlisted below, with the reason. Adding a
// component here instead of writing it is the failure this gate exists to catch.
import { readFileSync, existsSync } from 'node:fs';

const ROOT = new URL('..', import.meta.url).pathname.replace(/\/$/, '');

// Flutter-only primitives: building blocks other widgets sit on, with no React
// counterpart because React composes them from the platform.
const FLUTTER_ONLY = {
  sk_pressable: 'the hover/press/focus primitive every control sits on; React uses native :hover/:active',
};

// ---------------------------------------------------------------- the two sets
const indexSrc = readFileSync(`${ROOT}/index.js`, 'utf8');
const react = [...indexSrc.matchAll(
  /export\s*\{\s*([A-Za-z0-9_, ]+)\}\s*from\s*"(\.\/components\/[^"]+\.jsx)"/g,
)].flatMap(m => m[1].split(',').map(n => n.trim()).filter(Boolean));

const barrelSrc = readFileSync(`${ROOT}/flutter/lib/seakim_flutter.dart`, 'utf8');
const flutterFiles = [...barrelSrc.matchAll(/export 'src\/widgets\/(sk_[a-z0-9_]+)\.dart';/g)].map(m => m[1]);

const snake = name => 'sk_' + name.replace(/([a-z0-9])([A-Z])/g, '$1_$2').toLowerCase();
const pascal = stem => stem.replace(/^sk_/, '').split('_').map(s => s[0].toUpperCase() + s.slice(1)).join('');

// README mapping table: | `React` / `Other` | `SkFlutter` + `showSkThing` | notes |
const readme = readFileSync(`${ROOT}/flutter/README.md`, 'utf8');
const mapped = new Map();
for (const line of readme.split('\n')) {
  const cells = line.split('|').map(c => c.trim());
  if (cells.length < 4 || !cells[1].includes('`')) continue;
  const lhs = [...cells[1].matchAll(/`([A-Za-z0-9_]+)`/g)].map(m => m[1]);
  const rhs = [...cells[2].matchAll(/`([A-Za-z0-9_]+)`/g)].map(m => m[1]);
  if (lhs.length && rhs.length) for (const l of lhs) mapped.set(l, rhs);
}

// Every file the barrel exports (theme, tokens, widgets, util): a mapped symbol
// may live outside widgets/ (SkApp, SkResponsive), but never outside the barrel.
const barrelSources = [...barrelSrc.matchAll(/export '(src\/[^']+\.dart)';/g)]
  .map(m => readFileSync(`${ROOT}/flutter/lib/${m[1]}`, 'utf8')).join('\n');
const defined = sym => new RegExp(`\\b(class|mixin|enum|extension)\\s+${sym}\\b|\\b${sym}\\s*(<[^>]*>)?\\s*\\(`).test(barrelSources);

const fail = [];

// ------------------------------------------------------- React → Flutter
for (const name of react) {
  const stem = snake(name);
  if (flutterFiles.includes(stem)) continue;
  const syms = mapped.get(name);
  if (!syms) {
    fail.push(`${name}: no flutter/lib/src/widgets/${stem}.dart in the barrel and no row in flutter/README.md's mapping table`);
    continue;
  }
  const missing = syms.filter(s => !defined(s));
  if (missing.length) fail.push(`${name}: README maps it to ${syms.join(', ')} but ${missing.join(', ')} is not defined in any barrel-exported widget file`);
}

// ------------------------------------------------------- Flutter → React
for (const stem of flutterFiles) {
  if (react.includes(pascal(stem))) continue;
  if (FLUTTER_ONLY[stem]) continue;
  // A file may be the home of a mapped function (sk_dialog holds showSkSheet)
  // only if its own widget also has a React twin — the loop above checks that.
  fail.push(`${stem}.dart: exported from the Flutter barrel but index.js has no ${pascal(stem)} (allowlist it only if it is a primitive, 0039 §3)`);
}

// Every mapping row is checked, not only the ones the name rule fell back to:
// a stale row is documentation that lies, in both directions.
for (const [lhs, syms] of mapped) {
  if (!react.includes(lhs) && !/^(styles|PlayerSheet|Viewport|—)$/.test(lhs) && !lhs.startsWith('data-')) {
    fail.push(`flutter/README.md maps \`${lhs}\`, which index.js does not export`);
  }
  for (const s of syms) {
    if (!defined(s)) fail.push(`flutter/README.md maps \`${lhs}\` to \`${s}\`, which no barrel-exported file defines`);
  }
}

console.log(`\nSeaKim parity-check — ${react.length} React components, ${flutterFiles.length} Flutter widget files, ${Object.keys(FLUTTER_ONLY).length} allowlisted\n`);
if (fail.length) {
  console.error('FAIL:');
  for (const f of fail) console.error(`  ✗ ${f}`);
  process.exit(1);
}
console.log('  clean — every component exists in both bindings');

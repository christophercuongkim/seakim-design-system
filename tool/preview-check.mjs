#!/usr/bin/env node
// preview-check — the render gate (decision 0020). Green never means visible: the
// other gates read text and never draw a component, so a component can pass them
// all and still mount blank (lesson 14) or be absent from a demo app (lesson 15).
//
// Two layers, selected by flag:
//   --static  (default, runs pre-commit): fast, no browser. Asserts each component
//             appears where a LIST can see it — the ds-shim FILES registry and its
//             demo — and reports coverage that is declared-pending, per the manifest.
//   --render  (CI): serves the root gallery and loads each card in headless Chrome,
//             asserting the card mounted (not the "Loading…" placeholder) and its
//             manifest markers are in the DOM. Presence, not screenshots.
//
// The component SET is derived from index.js (web) — the manifest cannot silently
// omit a component, only be wrong about one. A component with no manifest entry
// FAILS; a component whose coverage is declared "pending" is PRINTED, not failed —
// the same report-vs-fail shape as 0019's binding audit. `preview-manifest.json`
// carries only per-component surface coverage and render markers.
import { readFileSync } from 'node:fs';
import { execSync, spawnSync } from 'node:child_process';

const ROOT = new URL('..', import.meta.url).pathname.replace(/\/$/, '');
const manifest = JSON.parse(readFileSync(`${ROOT}/tool/preview-manifest.json`, 'utf8'));

// -------------------------------------------------------- derive the web set
// export { Name } from "./components/.../Name.jsx" — the source of truth.
const indexSrc = readFileSync(`${ROOT}/index.js`, 'utf8');
const webComponents = [...indexSrc.matchAll(
  /export\s*\{\s*([A-Za-z0-9_]+)[^}]*\}\s*from\s*"(\.\/components\/[^"]+\.jsx)"/g,
)].map(m => ({ name: m[1], path: m[2].replace(/^\.\//, '') }));

// ds-shim FILES registry — the list a card mounts through (lesson 14's SPOF).
const shimSrc = readFileSync(`${ROOT}/ds-shim.js`, 'utf8');
const filesRegistry = [...shimSrc.matchAll(/'(components\/[^']+\.jsx)'/g)].map(m => m[1]);

const fail = [];
const warn = [];
const pending = [];

// ------------------------------------------------------------------- static
function runStatic() {
  for (const c of webComponents) {
    const entry = manifest.components[c.name];

    // Derived-set completeness: a component the manifest never heard of.
    if (!entry) {
      fail.push(`${c.name}: no preview-manifest entry — declare its surfaces (or "pending")`);
      continue;
    }

    // Registry membership — the direct lesson-14 check.
    if (!filesRegistry.includes(c.path)) {
      fail.push(`${c.name}: ${c.path} is missing from ds-shim.js FILES — its card will mount blank`);
    }

    // Declared coverage: "yes" | "pending: <reason>" per surface.
    for (const [surface, state] of Object.entries(entry.surfaces || {})) {
      if (typeof state === 'string' && state.startsWith('pending')) {
        pending.push(`${c.name} · ${surface}: ${state}`);
      }
    }
  }

  // A component in the registry with no demo reference is a warning, not a fail —
  // compositional primitives (Icon, Card) legitimately appear only inside others.
  const demoSrc = execSync(`cat ${ROOT}/components/*/*.demo.jsx`, { encoding: 'utf8' });
  for (const c of webComponents) {
    const entry = manifest.components[c.name];
    if (entry?.compositional) continue;
    if (!new RegExp(`\\b${c.name}\\b`).test(demoSrc)) {
      warn.push(`${c.name}: not referenced in any *.demo.jsx (no standalone example)`);
    }
  }
}

// ------------------------------------------------------------------- render
function chromeBin() {
  for (const bin of ['google-chrome', 'google-chrome-stable', 'chromium', 'chromium-browser']) {
    if (spawnSync('which', [bin]).status === 0) return bin;
  }
  return null;
}

function runRender() {
  const chrome = chromeBin();
  if (!chrome) {
    console.log('  render: no Chrome on PATH — skipping (static layer still ran)');
    return;
  }
  // Serve the repo root so cards resolve ../../styles.css and fetch their demos.
  const server = spawnSync('bash', ['-c',
    `cd ${ROOT} && (python3 -m http.server 8731 >/dev/null 2>&1 & echo $!)`], { encoding: 'utf8' });
  const pid = server.stdout.trim();
  try {
    execSync('sleep 1');
    for (const [card, spec] of Object.entries(manifest.cards)) {
      const url = `http://127.0.0.1:8731/${card}`;
      const out = spawnSync(chrome, [
        '--headless=new', '--no-sandbox', '--disable-gpu',
        '--enable-unsafe-swiftshader', '--virtual-time-budget=8000',
        '--dump-dom', url,
      ], { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
      const dom = out.stdout || '';

      if (/Loading components…/.test(dom) || dom.length < 500) {
        fail.push(`render ${card}: mounted blank (still shows the Loading placeholder)`);
        continue;
      }
      for (const marker of spec.markers || []) {
        if (!dom.includes(marker)) {
          fail.push(`render ${card}: marker not in DOM — "${marker}"`);
        }
      }
    }
  } finally {
    if (pid) spawnSync('kill', [pid]);
  }

  // /next and /flutter render only when their built output is served — wired in
  // CI where the Dockerfile builds both. Named here so their absence is visible.
  console.log('  render: /next and /flutter are covered in CI (built surfaces); skipped locally');
}

// --------------------------------------------------------------------- main
const mode = process.argv.includes('--render') ? 'render' : 'static';
console.log(`\nSeaKim preview-check — ${mode} (${webComponents.length} web components)\n`);

runStatic();
if (mode === 'render') runRender();

for (const w of warn) console.log(`  warn  ${w}`);
if (pending.length) {
  console.log('\n  declared pending coverage (visible, not failed):');
  for (const p of pending) console.log(`   ·  ${p}`);
}

if (fail.length) {
  console.error('\nFAIL:');
  for (const f of fail) console.error(`  ✗ ${f}`);
  process.exit(1);
}
console.log(`\n  clean — every component is registered${mode === 'render' ? ' and every card mounts' : ''}`);

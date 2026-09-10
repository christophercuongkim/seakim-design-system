#!/usr/bin/env node
/**
 * SeaKim conformance self-test.
 *
 *     node tool/conformance-selftest.mjs
 *
 * The conformance gate has no test. A green run is indistinguishable from a regex
 * that never matched anything — lesson 7 ("Test the hook; do not trust it"), applied
 * to the checker instead of the hook. This drives the real program the way a
 * consuming repo does (lesson 4): as a subprocess, over synthetic inputs, asserting
 * the exit code and the reported rule id.
 *
 * Every rule in RULES owes two fixtures under .conformance-fixtures/<rule-id>/ —
 * a bad/ that must be flagged as exactly that rule, and a good/ that must be clean.
 * A rule with no fixture directory is a failure here, so adding a rule without a
 * test cannot pass silently.
 *
 * Exit codes: 0 all assertions hold, 1 an assertion failed, 2 could not run.
 */

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { join } from 'node:path';

const ROOT = new URL('..', import.meta.url).pathname.replace(/\/$/, '');
const CHECKER = join(ROOT, 'tool', 'conformance-check.mjs');
const FIXTURES = join(ROOT, '.conformance-fixtures');

if (!existsSync(FIXTURES)) {
  console.error(`selftest: no fixtures at ${FIXTURES}`);
  process.exit(2);
}

/* ------------------------------------------------- the rule set under test */

// Read the ids out of the checker's own RULES array rather than restating them, so
// a new rule shows up here as a missing fixture instead of being quietly untested.
// PARITY entries also carry an `id`, and they are not line rules — cut before them.
const src = readFileSync(CHECKER, 'utf8');
const rulesRegion = src.slice(src.indexOf('const RULES = ['), src.indexOf('const PARITY = ['));
const RULE_IDS = [...rulesRegion.matchAll(/^\s*id: '([a-z-]+)',$/gm)].map(m => m[1]);

if (RULE_IDS.length === 0) {
  console.error('selftest: could not read any rule ids out of conformance-check.mjs');
  process.exit(2);
}

/* ------------------------------------------------------------------ runner */

function run(dir) {
  const r = spawnSync(process.execPath, [CHECKER, '--json', dir], { encoding: 'utf8' });
  if (r.status === 2) return { status: 2, violations: [], scanned: 0 };
  let parsed;
  try {
    parsed = JSON.parse(r.stdout);
  } catch {
    return { status: r.status, violations: null, scanned: 0, raw: r.stdout + r.stderr };
  }
  return { status: r.status, violations: parsed.violations, scanned: parsed.scanned };
}

const failures = [];
const notes = [];

function fail(what, detail) {
  failures.push({ what, detail });
}

/* ------------------------------------------------------------- assertions */

for (const id of RULE_IDS) {
  const bad = join(FIXTURES, id, 'bad');
  const good = join(FIXTURES, id, 'good');

  if (!existsSync(bad) || !existsSync(good)) {
    fail(id, `no fixtures — expected .conformance-fixtures/${id}/{bad,good}/`);
    continue;
  }

  // bad/ must be flagged, and flagged as THIS rule — not merely non-clean.
  const b = run(bad);
  if (b.violations === null) {
    fail(id, `bad/ produced no parseable JSON: ${(b.raw || '').trim().slice(0, 200)}`);
  } else if (b.status !== 1) {
    fail(id, `bad/ exited ${b.status}, expected 1 (${b.scanned} files scanned)`);
  } else if (!b.violations.some(v => v.rule === id)) {
    const got = [...new Set(b.violations.map(v => v.rule))].join(', ') || 'none';
    fail(id, `bad/ was flagged, but as [${got}] — not as ${id}`);
  } else {
    const stray = [...new Set(b.violations.map(v => v.rule))].filter(r => r !== id);
    if (stray.length) {
      // Not a failure: the fixture is still proving this rule fires. But a fixture
      // that trips a second rule makes the assertion muddier than it reads.
      notes.push(`${id}: bad/ also tripped [${stray.join(', ')}] — consider narrowing the fixture`);
    }
  }

  // good/ must be clean.
  const g = run(good);
  if (g.violations === null) {
    fail(id, `good/ produced no parseable JSON: ${(g.raw || '').trim().slice(0, 200)}`);
  } else if (g.status !== 0) {
    const got = g.violations.map(v => `${v.rule} (${v.file}:${v.line})`).join(', ');
    fail(id, `good/ exited ${g.status}, expected 0 — flagged: ${got}`);
  }
}

/* ------------------------------------------- documented blind spots */

// Inputs the checker is currently known NOT to catch. Asserted so the gap stays a
// recorded fact rather than a surprise, and so closing one is a visible change here.
const BLIND_SPOTS = [
  {
    dir: 'radius-token-camelcase',
    why: 'camelCase borderRadius holding a non-whitelisted var() — invisible to every branch of non-zero-radius. ADR 0030 closes it.',
  },
];

for (const spot of BLIND_SPOTS) {
  const dir = join(FIXTURES, '_blindspot', spot.dir);
  if (!existsSync(dir)) {
    fail(`_blindspot/${spot.dir}`, 'blind-spot fixture is missing');
    continue;
  }
  const r = run(dir);
  if (r.violations === null) {
    fail(`_blindspot/${spot.dir}`, 'produced no parseable JSON');
  } else if (r.status !== 0) {
    // Not a regression — the checker got BETTER. But the record is now stale.
    fail(
      `_blindspot/${spot.dir}`,
      `now caught (${r.violations.map(v => v.rule).join(', ')}) — good news; remove it from BLIND_SPOTS`,
    );
  }
}

/* ---------------------------------------------------------------- output */

const fixtureDirs = readdirSync(FIXTURES, { withFileTypes: true })
  .filter(d => d.isDirectory() && !d.name.startsWith('_'))
  .map(d => d.name);
const orphans = fixtureDirs.filter(d => !RULE_IDS.includes(d));
for (const o of orphans) fail(o, 'fixture directory matches no rule id in RULES');

console.log(`\nSeaKim conformance self-test — ${RULE_IDS.length} rules, ${BLIND_SPOTS.length} recorded blind spot(s)\n`);

for (const n of notes) console.log(`  note  ${n}`);
if (notes.length) console.log('');

if (failures.length === 0) {
  console.log(`  every rule fires on its bad fixture and stays quiet on its good one.\n`);
  console.log(`  A green gate now means the rules were exercised, not merely that`);
  console.log(`  nothing matched. See decisions/0012 and docs/lessons.md lesson 7.\n`);
  process.exit(0);
}

console.log(`  ${failures.length} assertion(s) failed:\n`);
for (const f of failures) console.log(`  FAIL  ${f.what}\n        ${f.detail}\n`);
process.exit(1);

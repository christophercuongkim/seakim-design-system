#!/usr/bin/env node
// VERSION, package.json, and the newest CHANGELOG heading must agree — and each
// binding's declared version must be honest about the rules it targets.
//
// They drifted before: VERSION said 2.1.0 while nothing in git marked it and the
// package did not exist yet. Three places holding the same number is a standing
// invitation for two of them to be right.
//
// The binding audit (decision 0019) is the same job over a wider set of inputs —
// "are the declared version numbers mutually consistent" — extended to each
// binding's `seakim_rules`. Lag is legitimate (0010, 0011) and only PRINTED; the
// audit FAILS only on the states that cannot be honest: a binding claiming rules
// that do not exist yet (ahead), or one a full Major step behind (2.x under 3.x
// rules — a Tier 0 rule moved or a token vanished, so it is broken or unreviewed).
// It cannot tell an intentional lag from a forgotten bump — that is intent, which
// no check reads. `seakim_rules` is a claim, not a measurement.
import { readFileSync } from 'node:fs';

const version = readFileSync('VERSION', 'utf8').trim();
const pkg = JSON.parse(readFileSync('package.json', 'utf8')).version;
const changelog = (readFileSync('CHANGELOG.md', 'utf8')
  .match(/^## \[([0-9]+\.[0-9]+\.[0-9]+)\]/m) || [])[1];

const rows = [['VERSION', version], ['package.json', pkg], ['CHANGELOG.md', changelog]];
const bad = rows.filter(([, v]) => v !== version);

for (const [where, v] of rows) {
  console.log(`  ${v === version ? 'ok  ' : 'MISMATCH'} ${where.padEnd(14)} ${v ?? '(none found)'}`);
}

// ---------------------------------------------------------------- binding audit
// Bindings that carry their own semver and a `seakim_rules` claim. The React
// reference binding is the npm package above — its version IS the rules version,
// so it is not audited here; only bindings that can legitimately lag are.
const BINDINGS = [
  { name: 'flutter', file: 'flutter/pubspec.yaml' },
];

const [rulesMajor, rulesMinor] = version.split('.').map(Number);
const bindingFailures = [];

console.log('\n  bindings (seakim_rules vs rules ' + version + '):');
for (const b of BINDINGS) {
  let src;
  try { src = readFileSync(b.file, 'utf8'); }
  catch { console.log(`  SKIP ${b.name.padEnd(10)} ${b.file} not found`); continue; }

  const ver = (src.match(/^version:\s*(\S+)/m) || [])[1];
  const claim = (src.match(/^seakim_rules:\s*["']?([0-9]+\.[0-9]+)["']?/m) || [])[1];

  if (!claim) {
    bindingFailures.push(`${b.name}: no seakim_rules declared in ${b.file}`);
    console.log(`  FAIL ${b.name.padEnd(10)} ${ver ?? '?'}  — no seakim_rules`);
    continue;
  }

  const [cMajor, cMinor] = claim.split('.').map(Number);
  const ahead = cMajor > rulesMajor || (cMajor === rulesMajor && cMinor > rulesMinor);
  const majorStepBehind = cMajor < rulesMajor;

  let status, note;
  if (ahead) {
    status = 'FAIL';
    note = `claims rules ${claim} — ahead of ${version} (rules that do not exist)`;
    bindingFailures.push(`${b.name}: seakim_rules ${claim} is ahead of ${version}`);
  } else if (majorStepBehind) {
    status = 'FAIL';
    note = `claims rules ${claim} — a full Major step behind ${version} (re-review or bump)`;
    bindingFailures.push(`${b.name}: seakim_rules ${claim} is a Major step behind ${version}`);
  } else if (cMajor === rulesMajor && cMinor === rulesMinor) {
    status = 'ok  ';
    note = `current (rules ${claim})`;
  } else {
    status = 'lag ';
    note = `rules ${claim} — behind ${version} (legitimate lag, per 0010)`;
  }
  console.log(`  ${status} ${b.name.padEnd(10)} v${ver ?? '?'}  ${note}`);
}

if (bad.length || bindingFailures.length) {
  if (bad.length) console.error(`\n${bad.length} source(s) disagree with VERSION (${version}).`);
  for (const f of bindingFailures) console.error(`binding audit: ${f}`);
  process.exit(1);
}
console.log(`\nversion ${version} is consistent; bindings honest`);

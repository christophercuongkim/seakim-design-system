#!/usr/bin/env node
// VERSION, package.json, and the newest CHANGELOG heading must agree.
//
// They drifted before: VERSION said 2.1.0 while nothing in git marked it and the
// package did not exist yet. Three places holding the same number is a standing
// invitation for two of them to be right.
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

if (bad.length) {
  console.error(`\n${bad.length} source(s) disagree with VERSION (${version}).`);
  process.exit(1);
}
console.log(`\nversion ${version} is consistent`);

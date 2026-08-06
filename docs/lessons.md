# Lessons

Things that went wrong here, what they cost, and the rule that prevents a repeat. Each
one is from a real incident — if a lesson could have been written before the incident, it
belongs in `CLAUDE.md` as a rule, not here as a lesson.

Newest last.

---

## 1. Generated files drift from their source, and the source is not automatically right

**Twice.** `tool/build-tokens.mjs` lost its chart-emitting stage, so regenerating silently
deleted `--chart-1..6` and `SkChartPalette`. Separately, `tokens/src/` still said
`clay: 55` while every generated output said `brick: 8` — regenerating would have reverted
the house accent from crimson to orange across every product surface.

The trap in both: the instinct is *"the generator is authoritative, regenerate."* That
would have destroyed correct work both times. The outputs held the intent; the source and
generator lagged.

**Rule.** When outputs and source disagree, do not assume either. Establish which is
authoritative by asking whether the generator *can reproduce* the outputs — feed the
source through the generator's own helpers and compare. In both cases the outputs turned
out to be this generator's own work from a version whose stage had been lost, which is
knowable only by that test. Byte-match is the proof; plausibility is not.

## 2. Byte-size comparison cannot see same-length edits

Used as the integrity check on every sync, and it silently missed:

- `VERSION` `3.0.0` → `3.0.1` — six bytes either way
- `package.json` `3.0.1` → `3.1.0` — five characters either way
- `color.tokens.json` `clay`→`brick` (+1) cancelling `55`→`8` (−1)

The last one was the house-hue fix — the single most important file in that push.

**Rule.** Size is excellent for truncation and corruption, which is the failure that
actually recurs, and blind to same-length edits. Use `git diff --name-only <since>..HEAD`
to decide *what* changed; use size to verify *how it arrived*. For a same-length edit,
read the content back and assert on it.

## 3. A clean analyzer says nothing about runtime

`SkApp` never provided a `Directionality`, despite its own doc comment claiming it did.
`flutter analyze` was clean; the first widget test crashed on the first `Icon`. Any app
using `SkApp` without a `WidgetsApp` above it would have died immediately.

Six bugs in one session were invisible to static checks: that one, two silent font
fallbacks, a cross-font code point in the icon generator, a text font exposed to the icon
tree-shaker, and three widgets that would not compile.

**Rule.** Static checks prove a narrow thing. Run it, render it, build it for release.

## 4. Verification has to sit as far from the code as a real consumer does

`next/example` consumed the package by `file:` path and built fine. A brand-new app
installing the published tag failed immediately with `TS7016` — the barrel had no type
declarations. The `file:` install resolved types differently, so the example could not
see the bug it existed to catch.

**Rule.** An example inside the repo verifies less than it appears to. Before claiming a
package is consumable, install it the way a stranger would — from the published ref, in a
directory that shares nothing with this one.

## 5. Removing a file to stop it being edited invites it being recreated

`palette.g.dart` and `tokens/generated/colors.ts` were deleted from the Claude Design
project so they could not be hand-edited there. The next session read their absence as a
gap and regenerated both by hand — reintroducing exactly the drift the deletion was meant
to prevent.

Both files carried a `GENERATED — DO NOT EDIT` header at the time. The header did not
help, and neither did a document explaining the exclusion.

**Rule.** A missing file is a visible prompt to create one; a note is not. Put the
instruction where the actor reads instructions — for the design project that is
`SKILL.md`, its brief — and keep the file present.

## 6. A rule that binds one binding is worse than no rule

`literal-colour` caught `rgb(var(--x) / 0.5)` in CSS but never saw Dart's
`.withValues(alpha:)`, so Flutter had been composing alpha freely since it was written
while CSS could not. Neither position had been chosen; the difference was an artefact of
which patterns the checker happened to match.

Separately, `disabled-opacity` only fired on lines containing "disabled" or "off" — so
`opacity: widget.enabled ? 1 : 0.5` read straight past it in three widgets for months.

**Rule.** When adding or changing a Tier 0 rule, write the check for **every** binding and
for the inverse phrasing. Decision 0012 exists because divergent interpretations are the
failure mode.

## 7. Test the hook; do not trust it

The pre-push gate stage had two bugs that only running it revealed:

- it consumed stdin, leaving the design-mirror stage with nothing to read — a silent
  failure in which the mirror would simply never fire again
- `DS_SKIP_DESIGN_PUSH` returned before the gates, so every push that session would have
  skipped the checks entirely

**Rule.** A hook is a program. Drive it with synthetic stdin and assert the exit code for
every path: pass, fail, out-of-scope, and override.

## 8. A history rewrite takes open PRs with it

Rewriting `main` to strip commit trailers moved three tags — anticipated — and also
**closed PR #1**, which GitHub then refused to reopen because its head commit was
unreachable. The PR had to be recreated.

**Rule.** Before rewriting published history, enumerate everything that references a
commit: tags, open PRs, lockfiles that pinned a SHA, CI caches. Tags are the obvious one
and not the only one.

## 9. `json.dumps` mangles non-ASCII by default

Bumping a version with `json.dumps(d, indent=2)` silently rewrote an em dash in
`package.json` as a `—` escape. Valid JSON, identical when parsed, three bytes
different on disk — enough to make local and remote disagree forever.

Related: a literal `\uXXXX` **escape sequence** in source cannot survive an MCP JSON
string field. It arrives decoded as the character, every time, whatever the escaping.

**Rule.** `ensure_ascii=False` when rewriting any file a human wrote. If a file needs a
literal backslash-u sequence, do not transport it through a JSON field — write the real
character instead, which is more readable anyway.

## 10. The design agent is strong on decisions and cannot verify anything

Every failure originating from the Claude Design side traced to one cause: it cannot run
code. It produced genuinely good design work — the Tier 1 reasoning in decision 0014, the
four-step sequential ramp in 0015 — and alongside it shipped three Dart files that would
not compile, a duplicate JSON key that deleted six tokens, a generator that crashed, and a
version that went backwards.

**Rule.** Take its decisions seriously and its code as a draft. Run the gates before
believing any of it. Do not round-trip code through it; the round trip adds a corruption
surface without adding confidence.

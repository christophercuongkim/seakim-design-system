# SeaKim Design System

Design system with two bindings and a rules layer between them. **Read
[`docs/lessons.md`](docs/lessons.md) before non-trivial work** — it records what has
actually gone wrong here, and most of it is not guessable from the code.

## Shape

| Layer | Where | Owned by |
| --- | --- | --- |
| Token source | `tokens/src/color.tokens.json` | **source of truth** |
| Generated outputs | `tokens/*.css`, `tokens/generated/`, `flutter/lib/src/tokens/palette.g.dart` | `tool/build-tokens.mjs` — never hand-edit |
| Rules | `decisions/` (ADRs), `spec/`, `conformance.md` | platform-neutral, binding-free |
| React binding | `components/`, `index.js` | reference binding |
| Flutter binding | `flutter/` | `flutter/lib/src/` |
| Next adapter | `next/` | thin; re-exports `index.js` |

## Gates — all four must pass

```bash
node tool/version-check.mjs        # VERSION == package.json == newest CHANGELOG heading
node tool/build-tokens.mjs --check # generated outputs match their source
node tool/conformance-check.mjs    # Tier 0 rules, see conformance.md
cd flutter && flutter analyze && flutter test
```

CI runs them; `scripts/hooks/pre-push` runs the fast three before any push to `main`.
Enable with `git config core.hooksPath scripts/hooks` — a fresh clone has no hook.

## Rules that bite

**Generated files.** Edit the source, run the generator. A generated file that looks
missing or stale is never an invitation to write one — see lessons 1 and 5.

**Tier 0 conformance is law.** Fix the code, not the rule. If a rule is genuinely wrong,
change it in `tool/conformance-check.mjs` **and** write an ADR — decision 0012 requires
the rule and its check to move together.

**A rule must bind every binding.** One that catches CSS but not Dart is how two
interpretations become three. Check both when adding one.

**Versioning** follows [`decisions/0011`](decisions/0011-versioning.md). Major = a Tier 0
rule changed or a token was removed/renamed. Minor = something added. The npm package
tracks the rules version.

**`main` is PR-only.** GitHub cannot enforce it on this plan (private repo, needs Pro),
so it holds by convention. Branch, PR, let CI run.

## Claude Design

`.design-sync/` mirrors part of this repo to a Claude Design project. The design side
**cannot run code** — it is strong on decisions and unreliable on anything needing
verification. Treat its code as a draft and run the gates before believing it.

Sync only when a decision lands. Do not sync code back and forth; it costs more than it
returns.

## Writing lessons

When something goes wrong in a way the next person would not predict, add it to
`docs/lessons.md`: what happened, what it cost, and the rule that prevents it. Concrete
over general — a lesson that could have been written before the incident is not a lesson.

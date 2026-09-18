# Domain docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- `CONTEXT.md` at the repo root, if it exists. It does not yet; the vocabulary currently lives in `spec/`, `conformance.md`, and `readme.md`.
- `decisions/`: the ADRs. This repo keeps them in `decisions/`, not `docs/adr/`. Read `decisions/README.md` for the index, the status values, and the five-heading format, then the ADRs that touch the area you are about to work in.
- `docs/lessons.md`: what has gone wrong here. `CLAUDE.md` already requires it before non-trivial work.

If `CONTEXT.md` does not exist, proceed silently. Don't flag its absence; don't suggest creating it upfront. The `/domain-modeling` skill creates it lazily when terms actually get resolved.

## File structure

Single-context repo:

```
/
├── CONTEXT.md          ← not yet written
├── decisions/          ← ADRs, numbered NNNN-slug.md, indexed in decisions/README.md
│   ├── 0001-platform-neutral-spec-layer.md
│   └── ...
├── spec/               ← platform-neutral component rules
└── conformance.md      ← Tier 0 rules every binding must obey
```

## Writing an ADR

Follow `decisions/README.md`: five headings (Context, Decision, Consequences, Rejected alternatives, plus the Status/Date/Affects header), append-only, next number in sequence, add a row to the README index. Correct an ADR by writing its successor, never by editing it. Decision 0012 requires a Tier 0 rule change to ship with its check in `tool/conformance-check.mjs`.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as the repo uses it: `spec/` and `conformance.md` until `CONTEXT.md` exists. Don't drift to synonyms the docs explicitly avoid.

If the concept you need isn't defined yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts 0021 (no bare spinners), but worth reopening because…_

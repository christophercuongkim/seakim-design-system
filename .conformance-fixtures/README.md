# Conformance fixtures

Synthetic inputs for `tool/conformance-selftest.mjs`.

## `<rule-id>/` — the line rules

Each rule in `RULES` gets a `bad/` case that must be flagged **as that rule** and a `good/`
case that must not be.

**The leading dot on this directory is load-bearing.** `walk()` in
`tool/conformance-check.mjs` prunes any entry starting with `.`, so these files are
invisible to the real gate while remaining addressable as an explicit ROOT. Do not move it
under `tool/` — `GEOMETRY_EXEMPT` contains `/tool\//`, which would silently skip five of the
rules and make their fixtures pass for the wrong reason.

Do not add a `conformance-check: ignore-file` marker to a `bad/` fixture. That would make it
pass and prove nothing.

## `_gates/` — the whole-repo gates

Seven gates do not scan lines. They read token files and compare values: `radius-ladder-drift`,
`accent-text-step-parity`, `overlay-width-parity`, `contrast-floor`, `overshoot-easing`,
`ink-primary`, `alpha-hairline`. A rule fixture cannot
reach them, so each gets a tree here mirroring the paths it reads, with one value drifted.

**No `good/` on purpose.** The real repository is the good case and CI asserts it on every
run. A hand-maintained second copy of `colors.css` would go stale and prove less than the
original already does.

Writing these found a real defect: `radius-ladder-drift` reported eight missing rungs for a
file that existed but carried no `SkRadius` class at all — a false positive for any
consuming repo with its own `sk_space.dart`. Absent and empty now mean the same thing.

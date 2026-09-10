# Conformance fixtures

Synthetic inputs for `tool/conformance-selftest.mjs`. Each rule id gets a `bad/` case that
must be flagged and a `good/` case that must not be.

**The leading dot is load-bearing.** `walk()` in `tool/conformance-check.mjs` prunes any
entry starting with `.`, so these files are invisible to the real gate while remaining
addressable as an explicit ROOT. Do not move this directory under `tool/` —
`GEOMETRY_EXEMPT` contains `/tool\//`, which would silently skip five of the nine rules and
make their fixtures pass for the wrong reason.

Do not add a `conformance-check: ignore-file` marker to a `bad/` fixture. That would make
it pass and prove nothing.

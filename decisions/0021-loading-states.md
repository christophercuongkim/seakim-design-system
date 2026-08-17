# 0021 — Loading is a skeleton or a labeled fallback, never a bare spinner

- **Status** Proposed
- **Date** 2026-08-17
- **Affects** every binding; adds a skeleton primitive and a labeled loading
  treatment to `spec/` and both bindings; `conformance.md`; relates to [0002],
  [0005], and `guidelines/voice-and-tone.md` ("Empty, loading, error")

## Context

SeaKim states a loading *rule* but ships no loading *component*.

Two places already say what loading should look like:

- `guidelines/voice-and-tone.md` ("Empty, loading, error"): *"Loading — name the
  thing being fetched if it takes over a second. **Never a bare spinner on a full
  page.**"* (example: "Checking 40 airlines…")
- The `SkButton` / React `Button` doc: *"the control keeps its width. **There are
  no spinners in this system.**"* — an in-control submit shows an in-place loading
  label ("Working…"), not a spinner.

So the intent is unambiguous: no spinners; name what is loading. But the binding
surface offers nothing for the two loading contexts that are not a button:

1. **Content-shaped regions** — a list, card grid, table, or a detail body whose
   eventual layout is known.
2. **Unknown-shape / full-page** — a route boot or a gate (e.g. a membership
   check) where there is no content layout yet to stand in for.

With no sanctioned treatment, an adopter falls back to the platform spinner
(Flutter `CircularProgressIndicator`, a CSS spinner) — bare, unlabeled, and
off-token, drawing in the platform's own color rather than the token layer [0005]
depends on. This is not hypothetical: the Flutter adopter (TripTogether) ships
full-page bare `CircularProgressIndicator`s in five screens (trips list, groups
list, the trip-workspace gate, create-trip, verify) because there is nothing else
to reach for. **The rule cannot be obeyed, because the component that would obey it
does not exist.** A rule with no component is how each binding invents its own
answer — the drift [0010] and [0013] exist to prevent.

## Decision

**Loading has two sanctioned treatments and no general spinner.**

### 1. A skeleton primitive — the default, for content-shaped loading

A placeholder that mirrors the geometry of the content that is coming: a rounded
block on `surfaceSunken` with a subtle shimmer driven by the motion tokens.
Composable, so a list renders N skeleton rows matching card geometry, a stat
renders a skeleton figure, a table renders skeleton cells. This is the default for
**any region whose shape is known**, because it says both "content is coming" and
"roughly what shape," and it removes the layout shift a centered spinner causes
when real content replaces it.

### 2. A labeled loading state — the constrained fallback, for unknown shape

Where there is no layout to skeleton (a route boot, a gate), show the sanctioned
caption — **name the thing being fetched** — with at most a minimal, token-colored
(brand-accent) progress indicator. Never a bare, unlabeled spinner. This is the
direct component form of the voice-and-tone rule, and likely belongs as a `loading`
affordance on the empty state (which already owns the centered glyph/title/
description frame) rather than a new widget — to be settled in `spec/`.

**In-control loading is unchanged.** The button's in-place loading label remains the
answer for submit/action buttons; neither treatment above applies there.

## Consequences

- Additive: two treatments added, nothing removed or renamed. **MINOR** per [0011],
  in the rules layer and in each binding as it implements them.
- The existing "never a bare spinner" rule becomes obeyable; it stops being a rule
  no binding can satisfy.
- Bindings can then replace their bare platform spinners — skeleton rows for lists
  and grids, the labeled state for boots and gates. For the Flutter adopter this
  unblocks TripTogether's TT-57.
- Two more components to keep at parity across bindings ([0010]) — the cost of any
  addition, paid here for a treatment every product screen needs.

## Enforceability

Per [0012], a rule that needs a check names it. A check can flag a raw platform
spinner (`CircularProgressIndicator` in Dart; a spinner keyframe/class in CSS) in
binding *component* source, outside the two loading treatments — the same family as
the existing literal-color check, and it must bind **both** bindings or it splits
one interpretation into three. "Is this skeleton shaped like the content it stands
in for?" is judgment, like [0017]'s shared-domain rule and 0012's "is this shadow
justified?", and stays unenforced.

## Rejected alternatives

- **A general spinner component (`SkSpinner`).** Contradicts "there are no spinners
  in this system," says nothing about what is loading or its shape, and shifts
  layout when content arrives. The button already shows sanctioned in-control
  loading without one. This was the original framing of the request; it is rejected
  on the system's own stated grounds.
- **Do nothing; let adopters keep the platform spinner.** The guideline forbids a
  bare full-page spinner but ships no alternative, so every binding either violates
  it or hand-rolls a skeleton — the exact drift [0010]/[0013] prevent.
- **Skeleton only, no labeled fallback.** Unknown-shape boots (route/gate) have no
  layout to stand in for; they need the labeled state.
- **A labeled spinner everywhere (caption + platform spinner).** Better than bare,
  but still a spinner, still off-token, and still shifts layout where a skeleton
  would not. Allowed only as the fallback's minimal indicator, never the primary
  answer.

# 0028 — A long-list picker is its own primitive, not a hand-rolled trigger

- **Status** Proposed
- **Date** 2026-08-23
- **Affects** `spec/` (a new `Select`/`Combobox` spec), the field/overlay conformance checks (`conformance.md`); every binding — `flutter/` first (`SkSelect` today, a searchable `SkSelect` mode or new `SkCombobox` tomorrow)

## Context

`SkSelect` is an anchored-popover (0022) picker for a **short, closed set**: it opens a
list under the trigger and you tap a row. It has no filter box, by design — a five-item
role menu does not need one, and a search field there is noise.

But the system has no answer for the **long** list — currency (~160 rows), timezone,
country, language. Scrolling 160 rows in an anchored popover is not a picker, it is a
punishment. So the consumer stops using `SkSelect` and hand-rolls the whole thing:

1. a **fake trigger** — an `SkPressable` wrapping a bordered `Container` that
   re-implements the select's closed-state chrome (hairline border, the field label, the
   caret, the 44px touch target) by eye, and
2. a **`showSkSheet` + `SkInput` + `ListView`** filter surface stitched together at the
   call site, with its own matching logic.

Both halves are a re-derivation of chrome the system already owns, and the re-derivation
is where it goes wrong. In a binding consumer (TripTogether's currency picker), the
hand-rolled trigger shipped **without the focus ring** — because a bare `SkPressable`
applies the press-scale and keyboard activation but not the focus ring, and nothing
reminded the author that a field trigger owes one. That is not a consumer mistake so much
as a missing primitive: every long-list picker that will ever exist has to re-solve the
trigger chrome, the overlay wiring, the touch floor, and the a11y, and each one solves a
slightly different subset. The focus-ring omission is just the first bug the gap
produced; the divergent match logic (substring here, fuzzy there, prefix somewhere else)
is the second.

There is also no shared **matcher**. Each consumer invents its filter — TripTogether
wrote a scored-subsequence `fuzzyScore` for the currency list — so ranking and
empty-state behaviour drift picker to picker with nothing to point at as correct.

## Decision

**Add a searchable long-list picker as a first-class primitive** — either a `searchable`
mode on `SkSelect` or a distinct `SkCombobox`/`SkPickerField` — that owns the trigger
chrome *and* the filter surface, so bindings stop stitching them together.

The primitive owns, as one unit:

- **The trigger.** Identical chrome to `SkSelect`'s closed state — hairline border, field
  label via the standard field wrapper, caret, hover/focus border transition, the focus
  ring, and the 44px touch floor (0023). A consumer never rebuilds this; that it can
  today is the bug.
- **The overlay.** The anchored-popover species (0022) with a filter input pinned at the
  top over a scrollable, keyboard-navigable option list — resolving on `sm` to the sheet
  species, exactly as the overlay-species rule already dictates, rather than each picker
  choosing a surface by hand.
- **Type-to-filter.** A default matcher (substring at minimum; a scored subsequence is a
  reasonable default for code+name lists), a defined empty-result state, and a selection
  highlight. The matcher lives in the binding as shared code, not re-invented per call
  site — TripTogether's `fuzzyScore` is contributed up on this branch as `skFuzzyScore`
  (a standalone util, not yet wired to any widget), so the picker, if accepted, adopts,
  replaces, or rejects it without churn.
- **The a11y.** Field label wired to the trigger; on open, focus moves into the filter
  input; arrow keys move the active option; Enter selects; Escape and outside-press close
  (0022); the selection is announced. The overlay obligations are the primitive's job,
  not the consumer's to remember.

`SkSelect` stays as-is for short closed sets. The split is by **list length and
searchability**, not cosmetics: a bounded menu you scan at a glance keeps the plain
select; an open-ended list you must type to navigate uses the searchable primitive. The
spec should give a rough threshold (order of a dozen rows) so the choice is not a coin
flip.

## Consequences

- The hand-rolled trigger disappears, and with it the class of bug it produced — a field
  trigger that forgets the focus ring, the touch floor, or the border transition, because
  the consumer no longer builds a field trigger at all.
- One matcher, one empty-state, one keyboard model across every long list, instead of
  per-picker drift.
- Per 0012, the field-trigger conformance check can finally assert "a select/combobox
  trigger carries a focus ring and a 44px target" against a real primitive — today there
  is nothing to check because the trigger is an anonymous `SkPressable`+`Container`.
- This is a new component surface: per 0001 it owes a `spec/` file, and per 0020 a
  preview entry and manifest row before it can ship. A `searchable` mode on `SkSelect`
  narrows that to a spec amendment plus preview coverage of the new mode.
- Versioning (0019): **Minor** — adds a component/mode and a spec; no Tier 0 rule moves.

## Rejected alternatives

- **Leave it to consumers.** The status quo, and it already shipped a trigger with no
  focus ring and N divergent matchers. An anchored field pattern that every long list
  re-derives is a spec gap, not a non-decision.
- **Make `SkSelect` always searchable.** A five-item role menu does not want a filter
  box; forcing one adds a focus target and a keyboard mode to a control that needed
  neither. Searchability is a property of the list, so it belongs behind a mode/variant,
  not on by default.
- **Widen `showSkSheet` into a "picker sheet" helper.** That standardises the *overlay*
  half but leaves every consumer still hand-building the trigger — which is the half the
  focus-ring bug lived in. Half a primitive re-opens the same gap.
- **Pull a third-party combobox.** Imports someone else's tokens, focus model, and
  overlay species; the whole point of 0022/0023 is that these are ours to define.

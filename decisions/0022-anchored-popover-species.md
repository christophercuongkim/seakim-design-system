# 0022 — Anchored contextual popover is a third overlay species

- **Status** Proposed
- **Date** 2026-08-22
- **Affects** the overlay-species rule (`conformance.md`), `spec/`; every binding — `flutter/` in particular (`SkSelect`, `SkDatePicker`, `SkHoverLabel` today, a new `SkPopover` tomorrow)

## Context

The overlay-species rule fixes exactly two shapes: a centred panel at `md`+ and a
bottom sheet at `sm`. Both are *modal and screen-anchored* — they ignore where the
thing that opened them lives.

A contextual overlay that is **anchored to its trigger** is neither. A reaction bar
above a long-pressed message, a menu under a "more" button, an autocomplete list under
a field — these must sit next to the element that spawned them, because their whole
meaning is "this, here". Forcing them into a centred panel or a bottom sheet severs the
spatial link that is the point.

The system already builds this shape repeatedly and pretends it hasn't. `SkSelect`,
`SkDatePicker`, and `SkHoverLabel` each hand-roll an `OverlayPortal` +
`CompositedTransformFollower`, none of them exported or shared. So the pattern exists
three times with three implementations and **no name**, which produces two failures:

1. **Consumers re-derive it badly.** A binding consumer that needs an anchored menu
   (chat reactions were the trigger for this ADR) drops to a raw `Overlay` and, with no
   primitive to lean on, skips the overlay obligations — focus does not move in, Tab is
   not trapped, focus is not restored on close, and there is no Escape-to-dismiss. The
   accessibility rules require all four for any overlay; a hand-rolled one gets none.
2. **The surface reads wrong.** With no species definition, the ad-hoc popover picks
   the wrong tokens — a raised card surface and no lift shadow — when every *defined*
   floating surface in the system (dialog, select, sheet, tooltip) uses the overlay
   surface plus `--shadow-popover`. "Borders define, shadows lift": an anchored popover
   genuinely floats and must say so.

## Decision

**Add the anchored popover as a third overlay species**, and grow a primitive that owns
it so bindings stop re-deriving it.

The species, in the Tier-1 overlay table:

| Species | Trigger | Surface | Dismissal | Focus |
| --- | --- | --- | --- | --- |
| Centred panel | modal, `md`+ | overlay + `--shadow-dialog` | scrim tap, Escape | trap + restore |
| Bottom sheet | modal, `sm` | overlay + `--shadow-sheet` | scrim tap, Escape, drag | trap + restore |
| **Anchored popover** | **contextual, any size** | **overlay + `--shadow-popover`, hairline border** | **scrim tap (if scrim), Escape, outside-press** | **moves in, restores on close** |

An anchored popover positions against its trigger's rect, flips to stay on-screen, and
may or may not carry a scrim (a reaction bar does; an autocomplete does not). Escape and
outside-press always close it; focus moves into it on open and returns to the trigger on
close.

**Primitive.** Add `SkPopover` (React and Flutter): given an anchor rect/target and a
child, it produces the positioned surface with the popover shadow, optional scrim,
on-screen flipping, focus management, and keyboard dismissal. `SkSelect`,
`SkDatePicker`, and `SkHoverLabel` are refactored onto it rather than each carrying
their own `OverlayPortal` plumbing.

## Consequences

- Consumers get a sanctioned, accessible anchored overlay instead of a raw `Overlay`
  that fails the focus and Escape rules.
- The three existing hand-rolled anchored overlays converge on one implementation;
  their a11y and shadow behaviour stop drifting apart.
- Per 0012, the overlay-species conformance check must grow the third row so a floating
  surface with no lift shadow, or an anchored overlay with no Escape handler, is caught.

## Rejected alternatives

- **Keep two species; push contextual actions into a bottom sheet on `sm`.** A bottom
  sheet for "react to *this* message" throws away the anchoring that carries the
  meaning, and on `md`+ there is no answer at all.
- **Leave it unspecified and let bindings hand-roll.** That is the status quo, and it
  already produced three divergent implementations and an inaccessible consumer copy.
  An un-named pattern that ships three times is a spec gap, not a non-decision.
- **A primitive with no species rule.** The check has nothing to enforce, so the wrong
  surface and missing Escape reappear the first time someone bypasses the primitive.

# 0023 — A control may render below the touch floor only if its hit area is not

- **Status** Proposed
- **Date** 2026-08-22
- **Affects** the 44px touch-target rule (`guidelines/accessibility`, `conformance.md`), `spec/`; every binding

## Context

The touch-target rule is a hard 44px minimum for anything tappable. It already carries
one documented escape: the slider thumb renders at 12px but is legal because its **hit
area** is 44px — the visible mark and the touch target are decoupled, and only the mark
is allowed to shrink.

Dense chrome wants the same latitude the slider already has, and the rule doesn't say so
in general terms. The trigger was a chat reaction pill: a count chip that sits *on* a
message bubble's edge. At 44px it swallows the bubble it annotates; at ~28px it reads
correctly as chrome on the message — but 28px is below the floor, and the slider's
"decouple the mark" precedent is written as a one-off for sliders rather than a rule.

Absent a general statement, an implementer faces a bad choice: inflate the visual to
44px and wreck the layout, or drop the hit area to 28px and quietly break the floor for
keyboard and motor-impaired users. The first is what the reaction pill looked like
before this ADR; the second is what "it's just chrome" tempts you into.

The distinction that matters is not *visual size* — it is whether the **target** is
reachable. A 12px slider thumb and a 28px reaction pill are both fine when their pointer
hit area and their accessibility bounds are 44px. Neither is fine when they are not.

## Decision

**Generalise the slider precedent.** A control may render its *visible mark* below the
44px floor if and only if its **hit area — both pointer and assistive-technology
bounds — is at least 44px**. The mark may shrink; the target may not.

Concretely:

- The tappable/`Semantics` bounds are padded out to ≥44px even when the painted pill,
  thumb, or glyph is smaller. In Flutter this is a transparent hit region
  (`behavior: HitTestBehavior.opaque` on a padded box), not a smaller opaque one.
- This covers a named class of **dense chrome**: reaction pills, message-attached
  affordances, chip-scale counts that annotate another element. It is not a licence for
  small standalone buttons — a button that is the primary way to do a thing is not
  chrome and takes the full 44px, visual included.

**Optional primitive.** If the reaction pill recurs across bindings, add `SkReactionPill`
(or fold it into an `SkChip` size) that bakes the 44px hit area in, so the exception
lives in one component rather than being re-argued in a comment at each call site.

## Consequences

- The chat reaction pill keeps its ~28px visual and gains a 44px hit area — conformant,
  and no longer swallowing the bubble.
- The rule now reads as a principle (decouple mark from target) with the slider as one
  instance, rather than a slider carve-out plus an unwritten "chrome is different".
- Per 0012, the touch-target check must measure the **hit area**, not the painted box,
  or it will false-positive on every legal small mark and miss the real violation (a
  small mark with a small target).

## Rejected alternatives

- **Force 44px visuals on dense chrome.** Produces the swallowed-bubble reaction pill and
  pushes implementers toward removing the affordance entirely. The slider already proved
  this is the wrong trade.
- **Allow sub-44px hit areas for anything labelled "chrome".** There is no principled
  boundary to "chrome", so this collapses the floor for everyone within a sprint. The hit
  area is the line precisely because it is measurable and non-negotiable.
- **A per-component exception list.** Exceptions accrete; a rule about the hit area
  covers the slider, the reaction pill, and the next dense control without a new entry.

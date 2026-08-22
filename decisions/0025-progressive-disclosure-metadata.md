# 0025 — Metadata on demand is allowed; the disclosure must have a non-pointer path

- **Status** Proposed
- **Date** 2026-08-22
- **Affects** `guidelines/accessibility`, `spec/`; every binding

## Context

Dense, high-volume surfaces hide secondary metadata until asked. A chat that stamped
every bubble with a visible timestamp would be unreadable; Messenger, iMessage, and
Slack all hide the per-message time behind a tap or a hover and show a coarse separator
only on a gap. The chat build did the same — tap a bubble to reveal its time, long-press
to open the reaction picker — and hit two unwritten questions.

1. **Is hiding metadata behind an interaction allowed at all?** SeaKim has no rule on
   progressive disclosure of secondary information. The instinct to reduce noise is
   right, but "the timestamp is one tap away" quietly assumes a pointer and sighted use.
2. **What about the interaction itself?** A tap-to-reveal and a long-press-to-react are
   *pointer* gestures. The accessibility rules already say that anything reachable only
   by pointer "does not exist" for a keyboard or assistive-technology user. A timestamp
   that only a tap reveals is invisible to a screen reader; a reaction picker that only a
   long-press opens is unreachable from a keyboard.

The tension is real: the density argument for hiding metadata is sound, and the
accessibility argument against pointer-only disclosure is also sound. They are
reconciled by separating *what is shown* from *what is announced*.

## Decision

**Metadata may be disclosed on demand — visually — provided it is always present in the
accessible name of the element**, and **any pointer-only affordance carries a documented
non-pointer trigger.**

- **Time-on-demand.** A bubble may hide its timestamp from view and reveal it on tap.
  The timestamp must nonetheless be part of the message's accessible name at all times,
  so a screen-reader user hears "Ana, 3:42 PM, see you there" without needing the reveal.
  The visual reveal is a sighted-density convenience, not the source of truth.
- **Non-pointer trigger for gestures.** Any hover- or long-press-driven action (the
  reaction picker) must also be reachable without a pointer: the host element is
  focusable, an activation key opens the same affordance, or a visible control appears in
  the focus/hover state. "Long-press only" is not a complete implementation.
- **No animated reveal of a value being read.** The disclosed metadata cuts in; it does
  not count up or slide, per the existing "never animate a value the user is reading"
  rule.

## Consequences

- Chat keeps its clean, timestamp-free column and its long-press reactions, and gains a
  keyboard/AT path to both — the timestamp in the accessible name, the reaction picker
  behind focus-plus-key or a visible affordance.
- Any surface tempted to hide metadata behind a gesture now has a rule to meet rather
  than an omission to exploit.
- Per 0012, the check can assert the weaker, automatable half — that a bubble exposing a
  hidden timestamp still carries it in its accessible name — even though "has a
  non-pointer trigger" needs human review.

## Rejected alternatives

- **Require all metadata to be permanently visible.** Kills the density that makes a
  chat or a log readable, and pushes teams to invent the hiding anyway, unspecified.
- **Allow pointer-only disclosure.** Directly contradicts the rule that pointer-only
  affordances do not exist for keyboard and AT users; a timestamp no screen reader can
  reach is not "disclosed", it is missing.
- **Make the reveal a persistent per-message toggle in state.** Solves nothing for AT
  (the value still is not announced) and adds state to every message for a sighted
  convenience the accessible name already delivers for free.

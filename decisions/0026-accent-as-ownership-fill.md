# 0026 — Accent as a repeated ownership fill is exempt from the single-accent rule

- **Status** Proposed
- **Date** 2026-08-22
- **Affects** the accent-emphasis rule (`conformance.md`), `spec/`; every binding

## Context

A Tier-0 identity rule says one accent hue is live at a time: "if two things on a screen
are accent-coloured, one of them is wrong." It exists to stop a screen from having three
things shouting "click me" — competing accent *actions* that destroy the hierarchy the
accent is supposed to create.

A chat thread breaks the letter of that rule on purpose. The convention for "this message
is mine" is an accent-filled bubble with on-accent text — and a normal thread has a dozen
of them on screen at once, plus an accent send button and accent-tinted reaction
highlights. By a literal reading, eleven of those bubbles are "wrong". They are not; the
thread reads perfectly, because the accent here is not eleven competing calls to action —
it is one **identity wash** repeated: every accent bubble means the same thing, "mine".

The rule conflates two different uses of accent that happen to share a colour:

- **Accent as emphasis** — a call to action, a primary button, a selected tab. Here the
  scarcity rule is right: two primaries compete, and one loses.
- **Accent as identity/ownership** — own message bubbles, the selected rows in a
  multi-select list. Here repetition is the *point*: the wash marks a category, and it
  must appear as many times as the category does.

Left undocumented, this reads as an oversight — a conformance pass flags every own-bubble
after the first, and a reviewer either waives the whole rule (bad) or repaints ownership
in a neutral colour (worse: it discards the strongest, most conventional ownership signal
there is).

## Decision

**The single-accent rule governs competing accent *actions*, not identity washes.**
Accent used as a systematic ownership/identity fill — own-message bubbles, selected rows,
the "you" marker in a list — is exempt, subject to two conditions:

1. **One meaning per surface.** On a given screen the ownership accent means exactly one
   thing. You may not also use the same accent as a selection wash *and* an ownership
   wash in the same view; pick one identity for the accent to carry.
2. **It must not compete with an accent primary action for attention.** If a screen has
   an accent identity wash and also an accent primary action, the primary action stays
   the single most prominent accent element — by size, position, and weight — so the
   hierarchy the original rule protects still holds.

## Consequences

- Own-message bubbles keep the conventional accent fill; the rule text now says so
  instead of implying they are violations.
- The scarcity rule keeps its teeth where it matters — two primary buttons, three
  "featured" cards — because the carve-out is narrowly for repeated *identity*, not for
  emphasis.
- Per 0012, the accent check distinguishes accent *actions* (still capped) from accent
  identity surfaces (bubbles, selected rows — exempt), rather than counting every accent
  fill on the screen.

## Rejected alternatives

- **Paint own bubbles a neutral fill.** Throws away the clearest ownership signal in
  messaging for literal compliance with a rule that was written about buttons. The result
  is a chat that reads worse to satisfy a rule that never meant to govern it.
- **Drop the single-accent rule.** The rule is load-bearing for action hierarchy; the
  problem is scope, not the rule. Narrowing it to actions keeps its value.
- **Leave it as a per-app waiver.** A waiver that every chat surface needs is a missing
  rule, and it fails audits until someone re-argues it each time.

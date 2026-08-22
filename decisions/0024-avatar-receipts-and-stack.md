# 0024 — Avatar as read-receipt, and an avatar stack primitive

- **Status** Proposed
- **Date** 2026-08-22
- **Affects** `spec/` (a read-receipt pattern; an `SkAvatarStack` component); every binding

## Context

A group conversation needs to answer "who has seen this?" The idiom the whole industry
settled on is the reader's avatar under the last message their read cursor covers.
SeaKim has no read-receipt pattern, so a binding consumer (chat, again the trigger)
invents one — correctly reaching for `SkAvatar` at its smallest size and reusing
`SkAvatarStatus` for presence, but with no guidance on placement or on what happens when
five people have read the same message.

The second half is the real gap: **there is no avatar stack.** Several avatars in a row
is a bare `Wrap`, which lays them out edge-to-edge and, past a handful, wraps to a second
line or overflows. The universal answer — overlap them, cap the count, show "+k" — has to
be hand-built, and every consumer that shows a facepile (receipts, channel members,
"who's on this trip") rebuilds it slightly differently.

Reusing `SkAvatar` was the right instinct and should be blessed, not re-derived; the
missing piece is the cluster behaviour above one avatar.

## Decision

**Sanction avatar-as-read-receipt** as a spec pattern: the reader's avatar at the `xs`
size, placed under the last message their read cursor covers, on the message's side.
Presence reuses `SkAvatarStatus` — no new dot. This is a usage pattern, not a new
component; it composes `SkAvatar`.

**Add `SkAvatarStack`** (React and Flutter) as the primitive for more than one avatar in
one place:

- avatars overlap by a fixed fraction of their diameter (a token, so the overlap is
  consistent everywhere);
- a `max` visible count, after which the remainder collapses into a **"+k" count pill**
  (`SkRadius.pill`, mono figures, per the number-rendering rule);
- last-in-front or first-in-front is a prop, defaulting to the reading order.

Read receipts, channel-member clusters, and any "these people" facepile use
`SkAvatarStack`; none re-implements overlap-and-overflow.

## Consequences

- Receipts and facepiles share one behaviour and one overlap token; they stop drifting.
- A message read by twenty people shows three avatars and "+17", not twenty avatars
  wrapping down the screen.
- `SkAvatar` stays the single source of the circle, initials, and status dot; the stack
  only arranges instances of it.

## Rejected alternatives

- **Leave receipts to consumers.** The pattern is universal enough to standardise, and
  the bare-`Wrap` overflow is a real bug the first time a message is popular.
- **A receipts-specific component.** The hard part — overlap, cap, overflow count — is
  identical for any facepile. Solving it once as `SkAvatarStack` serves receipts and
  member clusters; a receipts-only widget would grow a member-cluster twin within a
  release.
- **Encode the overlap as a per-call constant.** That is how two facepiles end up with
  different overlaps. It is a token.

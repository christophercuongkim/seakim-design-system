# Contributing a binding

You need SeaKim on a platform that does not have it yet — SwiftUI, Kotlin Compose,
Vue, something else. **Build it. You own it.** Nobody here is queued to write it for you.

Per [decision 0010](decisions/0010-bindings-are-contributed-not-owned.md), the product of
this repo is the rules, not any one implementation. What follows is everything you need
and nothing you have to negotiate.

---

## Read these four, in order

| | What it gives you | Time |
| --- | --- | --- |
| [`conformance.md`](conformance.md) | Tier 0 rules you cannot bend, Tier 1 you can with a note, and the component inventory | 15 min |
| [`readme.md`](readme.md) | Foundations: colour, type, spacing, depth, motion, responsive, voice | 20 min |
| [`guidelines/accessibility.md`](guidelines/accessibility.md) | Every a11y rule in one place, plus what your binding owes | 10 min |
| [`guidelines/layout.md`](guidelines/layout.md) | The shell, content ceilings, and the four composition patterns | 10 min |
| [`decisions/`](decisions/README.md) | Why anything surprising is the way it is. Read 0002 and 0005 at minimum | 20 min |
| [`spec/`](spec/README.md) | Per-component contracts. Only three exist so far — see below | 10 min |

Then open [`signoff.html`](signoff.html) in a browser. It has live visual demos of each
contested decision next to the alternative that lost, which is faster than reading the
ADRs cold.

## Generate your tokens — do not retype them

`tokens/src/color.tokens.json` is the source of truth. Write an emitter, not a copy.

```bash
node tool/build-tokens.mjs        # see the existing CSS / Dart / TS emitters
```

Add yours alongside them in `tool/build-tokens.mjs`. Roughly 200 lines.

**Reuse the gamut mapping.** Colour is defined in oklch with the hue rotating per app.
If your platform cannot evaluate oklch, bake to sRGB using the `oklchToRgb` function
already in that script — it reduces chroma until the colour fits rather than clipping.
Clipping shifts hue, which breaks the promise that every app's ramp differs only in H,
and then contrast stops holding across products. This is the single easiest thing to get
subtly wrong.

## Build the mandatory 14 first

`Icon` · `Button` · `IconButton` · `Card` · `Badge` · `Field` · `Input` · `Checkbox` ·
`Switch` · `Select` · `Dialog` · `Toast` · `EmptyState` · a navigation shell

Every screen in both kits needs these. The other tiers can wait, and a narrow binding
that ships only these is legitimate.

## When a spec does not exist

Only `Table`, `Slider`, and `DatePicker` are specced. For everything else, read the React
source in `components/` — it is the most complete binding.

But: **React is a reference, not the contract.** Where React and a spec disagree, the spec
wins. Where React does something that is obviously a React accident — a prop name, a
state pattern, a DOM-shaped API — do the right thing for your platform and say so in your
readme.

**Ask, and we write the spec.** A question you have to ask is a spec that should exist.
That is the intended path: per [0001](decisions/0001-platform-neutral-spec-layer.md),
specs are written on demand, and a new binding is the demand.

## Document your Tier 1 adaptations

This is the part people skip and the part that matters. Tier 1 concerns — how you measure
breakpoints, where text input internals come from, how icons are delivered, how overlays
are presented — are yours to decide. **An undocumented adaptation is a Tier 0 violation in
practice.**

Put a table in your binding's readme. `flutter/README.md` has the pattern: it records
that `SkInput` keeps a Material ancestor for selection handles and the platform context
menu, and why rebuilding those was not worth it.

## Self-review before you open it up

From the bottom of [`conformance.md`](conformance.md), in order. Each catches a different
class of error and each is cheap:

1. **Grep for literals.** Any hex colour, any px that duplicates a token, any radius above
   zero. Catches most Tier 0 violations on its own.
2. **Screenshot one screen in all four combinations** — dark and light, two apps.
3. **Resize through the breakpoints.** Navigation swaps rather than shrinks; overlays
   change species; nothing is reachable only by hover.
4. **Tab through every screen.** Focus ring visible at every stop, in order, never trapped.
5. **Turn on reduced motion.** Everything works, nothing animates.
6. **Read your copy against [`guidelines/voice-and-tone.md`](guidelines/voice-and-tone.md).**
7. **Check your Tier 1 table is written down.**

## Declare what you conform to

One line in your readme, per [0011](decisions/0011-versioning.md):

```
seakim_swiftui 0.3.0 — conforms to SeaKim 1.0
```

Version your binding however your ecosystem expects. The rules version is separate and you
do not bump it — you state which one you were built against. Being a version behind is
normal and visible; it is not a failure state.

## Declare what you conform to

Your binding carries its own version, and names the rules version it was reviewed against:

```yaml
version: 0.1.0          # yours, on your schedule
seakim_rules: "1.0"     # what you checked against
```

Per [0011](decisions/0011-versioning.md). Lagging is fine and expected — claiming a rules
version you have not been reviewed against is not.

## Contribute it back

Put it in this repo as a sibling of `components/` and `flutter/`, with a readme in the
same shape. Add a column to the status table in `conformance.md`.

The next team to need your platform inherits it. That is the whole point of the
arrangement — you did not wait on us, and the team after you does not wait on you.

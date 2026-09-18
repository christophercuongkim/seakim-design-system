# SeaKim

A multi-product design system: platform-neutral rules in `spec/`, `conformance.md` and
`decisions/`, proven by a React binding and a Flutter binding. This glossary holds the
terms the rules use so that specs, ADRs, tickets and code say the same word for the same
thing. It grows only when a term is actually resolved.

## Language

### Direction

**Quiet**:
The direction set by [0033](decisions/0033-quiet.md): chrome recedes, features stay.
Everything remains visible; it weighs less.
_Avoid_: minimalist, minimal, clean, calm, airy

### Separation

**Separator**:
Whatever divides two regions: a gap, a fill, or a hairline. Under Quiet, gaps and fills
are the default and a hairline is the exception.
_Avoid_: divider (that is one kind of separator), border (that is a hairline)

**Fill**:
A tinted surface that defines a region without a border.
_Avoid_: background (too general), card colour, tint (the adjective, not the noun)

**Hairline**:
A 1px alpha border, used only where a gap cannot separate: table rows, inputs, dividers.
_Avoid_: border, stroke, outline (the focus ring is an outline; a hairline is not)

### Colour roles

**Ink primary**:
The primary action rendered in text colour (ink on light, inverse on dark), not in the
app accent.
_Avoid_: black button, neutral primary, monochrome CTA

**Accent**:
The one hue an app has live at a time. Under Quiet it lives in links, the focus ring,
selection, active navigation and identity fills, not on the primary action.
_Avoid_: brand colour, primary colour, highlight

### Interaction

**Tint press**:
Press feedback as a background tint. No scale, no ripple.
_Avoid_: press state, pressed style, highlight on tap

### Shape

**Rung**:
One step on the closed radius ladder of [0030](decisions/0030-corners-take-a-radius-ladder.md).
A corner names a rung; it never names a pixel value.
_Avoid_: radius size, corner size, border radius (the CSS property, not the concept)

# 0017 — A distribution/interval glyph

- **Status** Proposed
- **Date** 2026-08-08
- **Affects** React binding (`components/core/Range.*`); `guidelines/data-visualisation.md`; `spec/Range.md`

## Context

`guidelines/data-visualisation.md` decides colour for **identity** (which series) and
[0015](0015-sequential-chart-ramp.md) for **magnitude** (more vs less). Neither covers a
third recurring job: showing a single value *with its uncertainty* — a floor, an expected
value, and a ceiling — for many rows on one shared scale.

The first real consumer hit this already. fantasy-hub's projection model now emits a
distribution per player (a 20th-percentile floor, a mean, an 80th-percentile ceiling), and
the whole point of a distribution over a point estimate is start/sit: two players project
the same but one is safe and one is boom-or-bust. A column of numbers can't show that at a
glance; a per-row interval mark can.

With nothing specified, a binding hand-rolls an SVG range bar and picks its own colours,
and the obvious instinct breaks a rule: an accent-coloured band **per row** paints the
accent down the whole column, which is the exact scarcity violation
[0016](0016-many-series-trajectories.md) resolved for repeated trajectories. There is also
no home for "what does an interval mark look like" — it is neither a series (identity) nor
a heatmap cell (magnitude).

## Decision

Add a **`Range`** core glyph: a horizontal track spanning a shared domain, an achromatic
**band** from `low` to `high`, and a **marker** at `mid`.

### Achromatic, because it repeats

The band is `--text-tertiary`, the marker `--text-primary`, the track `--surface-inset`
with a 1px `--border-subtle` hairline. **No accent by default** — a `Range` is meant to
sit in a column, and the shared layer is achromatic exactly so a grid of them reads as
calm structure rather than a wall of accent. This is the same resolution as 0016: the
repeated layer is grey, and a *single* instance is promoted to `--fill-accent` (the
`accent` prop) when it is the selected or hovered row. Colour never encodes the value — a
`Range` carries floor/expected/ceiling by **position**, not hue; magnitude-by-colour is
`--chart-seq`'s job, not this one.

### One shared domain, or it lies

Every sibling `Range` in a comparison must be passed the **same `domain`**. A band's width
is read as spread, so two bands on different scales are a lie the same way a truncated bar
axis is. The component self-scales to `[0, high]` only as a single-glyph fallback; a column
that does not share a domain is off-spec.

### A band and a marker, not a bar

The band need not touch zero — it is an interval, not a bar chart, so the zero-baseline
honesty rule does not apply to the band itself (the *domain* still starts at a meaningful
base, normally 0). Ends and marker are square, per the radius rule. Every instance carries
a text equivalent (an `aria-label`, and the exact numbers live in adjacent cells), per the
colour-alone rule.

## Consequences

- Another mark type in the dataviz vocabulary to keep coherent with series and heatmap.
- The marker floors at ~2px; below that it stops resolving against the band, so `Range`
  has a minimum useful height (`sm` = 5px track) and is not a sparkline substitute.
- Because it is deliberately achromatic, a `Range` can never carry magnitude by colour;
  a screen that needs both an interval *and* a magnitude encoding uses `--chart-seq`
  alongside it, not inside it.
- The Flutter binding is owed — React leads per [0010](0010-bindings-are-contributed-not-owned.md);
  `spec/Range.md` is the contract it implements against.

## Rejected alternatives

- **Accent band per row.** Paints accent down the whole column — the scarcity violation
  0016 already ruled out for repeated marks.
- **Box-and-whisker.** Quartile whiskers and outlier dots imply a precision a modelled
  distribution rarely has, and are too busy for a table row.
- **Reuse the Slider visuals.** A Slider is an *input* — a thumb with a 44px hit area that
  reads as operable. An output glyph must not look draggable.
- **A `--chart-seq` magnitude fill.** That encodes more-vs-less, not an interval; wrong job,
  and it would collide with a real heatmap on the same screen.

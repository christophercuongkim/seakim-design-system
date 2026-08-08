# Range

A single value shown with its interval — floor, expected, ceiling — on a scale shared
with its siblings. Per [0017](../decisions/0017-distribution-interval-glyph.md).

**Not for:** an adjustable value — that is a `Slider`, which is an input with a hit area
and reads as operable. Not for magnitude-in-a-grid (more vs less) — that is the
`--chart-seq` heatmap per [0015](../decisions/0015-sequential-chart-ramp.md). Not for a
single exact number with no range — that is a `Stat`.

## A band and a marker on a shared track

```
  Chase    5.8 ██████████▉█████ 28.2      <- floor / ceiling numbers in adjacent cells
                    ^ mid marker
  domain 0 ─────────────────────── 30      shared across every row

  +--------##########|##########------+
  ^track            ^marker           ^end
  low───────────────mid──────────────high
```

| Part | Treatment |
| --- | --- |
| Track | Full domain width, `--surface-inset`, 1px `--border-subtle`. `--radius-none` — ends square. |
| Band | From `low` to `high`. `--text-tertiary`. No border, square ends. |
| Marker | At `mid`. ~2px wide, `--text-primary`, spans just past the track. Square. |
| Promoted band | `--fill-accent` — **one instance at a time**, never a whole column (see States). |

Colour never encodes the value: floor/expected/ceiling read by **position**, not hue. If
two `Range` rows are accent-coloured at once, one of them is wrong.

## The domain is shared, or the bars lie

Every `Range` in a comparison takes the **same `domain`** `[min, max]`. A band's width is
read as spread; two bands drawn on different scales misrepresent it the way a truncated bar
axis does. A lone `Range` may self-scale to `[0, high]`; a column that does not share a
domain is off-spec.

## States

| State | Treatment |
| --- | --- |
| Default | Achromatic — grey band, ink marker. The whole column reads as calm structure. |
| Promoted | The selected or hovered row's band goes `--fill-accent`. Exactly one at a time. |

There is no hover growth and no shadow — a `Range` is an output glyph, not a control.

## Responsive

The glyph fills its container width at every breakpoint, so it narrows with its column and
needs no restack. At `sm` it survives as long as the marker still resolves against the
band; below roughly a 40px-wide cell, drop the bar and keep the numbers — a bar too small
to read is worse than the floor/ceiling figures it summarises.

## Accessibility

- Carries a text equivalent: an `aria-label` (defaulting to "{low} to {high}, {mid}"), and
  the exact figures live in adjacent numeric cells — never the bar alone.
- Passes the colour-alone check: the interval is legible in greyscale because position, not
  colour, carries it.
- Not focusable — it encodes nothing interactive. A promoted row's selection is announced
  by the row, not the glyph.

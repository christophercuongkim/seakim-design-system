# 0016 — Many-series trajectories: the >6 change-over-time case

- **Status** Proposed
- **Date** 2026-08-05
- **Affects** every binding; `guidelines/data-visualisation.md`

## Context

`data-visualisation.md` caps categorical colour at six and rules that a seventh
series "is not a colour problem, it is a chart problem: group the tail into
'other', split into small multiples, or use a table."

That is right for identity-by-category (bars, a handful of trend lines). It is
wrong for **change-over-time with many entities** — a finish-rank bump chart, a
fare-rank spaghetti — where the *trajectories themselves are the subject*: who
rose, who collapsed, who crossed whom. "Other" erases the entities; small
multiples break the crossings that carry the meaning; a table loses the shape
entirely. So the three sanctioned options don't cover the case, and a binding
either invents a pattern or ships an empty state.

fantasy-hub hit this first: 8–12 managers over 12 seasons. It shows every
trajectory in achromatic grey with one promoted on hover — a fourth pattern the
spec neither blesses nor forbids, and one that quietly fails the touch rule ("no
hover; values live in a caption or table") unless a non-pointer fallback exists.

## Decision (proposed)

Name a **fourth** >6 treatment, scoped to change-over-time: the **achromatic
trajectory set**.

- **No per-series colour.** Every line is `--text-tertiary`. The six-colour
  ceiling is honoured *because nothing is coloured* — identity does not come from
  hue here.
- **One accent at a time, on demand.** Pointer hover/focus promotes one line to
  `--fill-accent` and dims the rest — the same "one accent hue live at a time"
  rule, applied temporally.
- **Direct end-labels**, always rendered, so identity is never colour-alone and
  survives with no interaction at all.
- **A non-pointer equivalent is mandatory**, satisfying both the touch rule and
  "every chart has a text equivalent": the summarising **grid/heatmap or table of
  the same data**, adjacent. (fantasy-hub pairs the bump chart with a finish
  heatmap — identical manager×season→rank data, readable by tap.)
- Straight segments, square caps, no smoothing — unchanged.

This reopens nothing about the palette: it moves identity off colour and onto
labels + interaction, which is exactly what the six-ceiling was protecting.

## Open question for sign-off

The N where this beats small multiples. Roughly 8–15 trajectories: below that,
distinct treatment is fine; far above it, even grey lines hairball and the honest
answer returns to small multiples or a table. Whether to state a number or leave
it to judgement is the call.

# Voyage — travel planning and booking

`data-app="voyage"` (sea, hue 245). **One responsive build** — no separate mobile
version. Pin the viewport to 390 / 768 / 1280 in the kit bar to watch it reflow.

## Screens

| File | Screen | What it demonstrates |
| --- | --- | --- |
| `AppShell.jsx` | chrome | `SideNav` from md up (icons-only at md), `TabBar` at sm; `PageSection`, `Placeholder`, `pagePad` |
| `TripsScreen.jsx` | Trips | Stat strip 4-up to 2x2 to 3-up; card grid to full-bleed stack; watch rows drop a column |
| `SearchScreen.jsx` | Flight results | Filter rail becomes inline expandable filters plus a chip row; result rows regrid; sticky selection bar |
| `TripDetailScreen.jsx` | Itinerary | `Tabs` becomes `SegmentedControl`; rail moves below content; header actions become a sticky footer |
| `CheckoutScreen.jsx` | Checkout | Summary rail moves above the form; pay button moves to a sticky bar; form grid collapses |
| `AccountScreen.jsx` | Account | Two columns to one; 44px settings rows throughout |

## Responsive decisions

- **Navigation swaps, it does not shrink.** Side nav from md up, bottom tab bar at sm.
  A screen never knows which one is showing.
- **The search field leaves the top bar at sm** rather than being squeezed — it lives
  in the screen there.
- **Sticky footers appear only below lg**, where there is no rail to hold the primary action.
- **Columns are dropped, not shrunk.** Tables lose their widest columns at md and sm
  rather than reducing type below 13px.

## Notes

- No destination photography was supplied. Every image area is a labelled
  `Placeholder` naming the city — replace with real assets, do not substitute stock
  or generated imagery.
- Content follows the copy rules: sentence case, verbs on buttons, exact money,
  en-dash ranges, scarcity claims attributed to their source.
- Every surface is a hairline-bordered rectangle. The only shadows are on sticky
  bars, the dialog, and the toast.

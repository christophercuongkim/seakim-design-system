# Bench — fantasy sport

`data-app="bench"` (turf, hue 145). **One responsive build** — no separate mobile
version. Pin the viewport to 390 / 768 / 1280 in the kit bar to watch it reflow.

## Screens

| File | Screen | What it demonstrates |
| --- | --- | --- |
| `BenchShell.jsx` | chrome | Same chassis as Voyage: `SideNav` from md up, `TabBar` at sm |
| `RosterList.jsx` | roster | The core responsive move: the same rows render as tappable list items at sm and as a table with hover actions from md up |
| `LineupScreen.jsx` | Lineup | Stat strip reflows; inline warning shortens its action label; starters and bench |
| `MatchupScreen.jsx` | Matchup | Head-to-head stacks avatars over names at sm; comparison grid tightens |
| `PlayersScreen.jsx` | Players | Search and position filters stack; live filtering to an empty state |
| `LeagueScreen.jsx` | League | Standings drops its two widest columns at sm; your own row in accent |
| `PlayerSheet.jsx` | Player sheet | Bottom sheet at sm, centred springing panel from md up |
| `roster.js` | data | Shared fixture data, so every screen reads the same roster |

## Responsive decisions

- **List at sm, table from md up.** Not a scrolling table — a genuinely different
  row layout, because a 6-column table cannot be read on a phone.
- **Row actions are hover-revealed on the table**, and become an inline trailing
  button in the list where there is no hover.
- **The sheet changes species**: bottom sheet on a phone, centred panel on a desktop.
- Action labels shorten rather than wrap ("Swap Vrba for Colton" becomes "Swap").

## Notes

- Register shift from Voyage is deliberate: Bench copy is fast and opinionated
  ("Vrba is out. Colton projects 12.0 in that slot."), Voyage is reassuring.
- No player photography or team crests were supplied. `Avatar` falls back to
  initials everywhere; crests would be image assets, not icons.
- Every tappable row clears 44px. Density 7/10 shows up as tight vertical padding
  with generous section gaps, not as small hit targets.

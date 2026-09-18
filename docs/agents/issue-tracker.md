# Issue tracker: Linear

Issues and specs for this repo live in Linear. Use the Linear MCP tools (`mcp__linear-server__*`) for every operation. There is no CLI.

- Workspace: `christopherkim`
- Team: Christopherkim (key `CHR`)
- Project: [SeaKim design system](https://linear.app/christopherkim/project/seakim-design-system-f16e46066c42)

Consumer repos (Juntio, Job Search Platform, studio) file their adoption work in their own projects. Upstream SeaKim tickets used to live under Juntio's completed "SeaKim design system rollout" project; search there when hunting history, file new work here.

## Every ticket must be self-contained

The person picking a ticket up may be the maintainer, an agent, or someone who has never opened this repo. Write for the last one. A ticket body carries:

1. **Why.** The problem or gap, and who hit it. Link the consumer ticket or the ADR that motivates it.
2. **Where.** The files and layers involved (`tokens/src/`, `spec/`, `components/`, `flutter/lib/src/`, `tool/`). Name the binding(s) affected; a rule must bind every binding.
3. **What done looks like.** Acceptance criteria as a checklist. Include which of the five gates in `CLAUDE.md` must pass, and whether the change is Major/Minor under decision 0011.
4. **Context that isn't in the code.** Prior attempts, rejected approaches, related ADRs by number, and any `docs/lessons.md` entry that applies.
5. **Out of scope.** What this ticket deliberately does not touch.

Before filing, check `list_issues` for an existing ticket on the same topic and link it instead of duplicating.

## Conventions

- **Create an issue**: `save_issue` with `team: "Christopherkim"`, `project: "SeaKim design system"`, a title, and a Markdown description following the template above. Apply a type label (`Bug`, `Feature`, `Improvement`) and the triage label from `docs/agents/triage-labels.md`.
- **Read an issue**: `get_issue` with the identifier (e.g. `CHR-123`), then `list_comments` on it. Read every comment; the latest one often changes the ask.
- **List issues**: `list_issues` with `project: "SeaKim design system"`, plus `state`, `label`, or `query` filters as needed.
- **Search history**: `list_issues` with `query` and no project filter; consumer projects hold earlier upstream tickets.
- **Comment**: `save_comment` with the issue id.
- **Apply / remove labels**: `save_issue` with the issue `id` and `addLabels` / `removeLabels`. Avoid `labels`, which replaces the whole set.
- **Close**: `save_issue` with `state: "Done"` (or `Canceled` for wontfix), after a closing comment saying what landed and where.
- **Create a label**: `create_issue_label` on the Christopherkim team. Only when an issue is about to receive it.

## Pull requests as a request surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

`main` is PR-only by convention. A PR links its Linear ticket in the body (`CHR-123`); Linear's GitHub integration is not set up, so add the link by hand both ways.

## When a skill says "publish to the issue tracker"

Create a Linear issue in the project above, following the self-contained template.

## When a skill says "fetch the relevant ticket"

`get_issue` on the identifier, then `list_comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: one issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body.
- **Child ticket**: a sub-issue of the map (`save_issue` with `parentId` set to the map). Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, assign the driving dev.
- **Blocking**: Linear issue relations. `save_issue` with `blockedBy` on the child. A ticket is unblocked when every blocker is Done.
- **Frontier query**: `list_issues` with `parentId` = map, open states only; drop any with an open blocker or an assignee; first in map order wins.
- **Claim**: `save_issue` with `assignee: "me"`, the session's first write.
- **Resolve**: `save_comment` with the answer, `save_issue` to `Done`, then append a context pointer to the map's Decisions-so-far.

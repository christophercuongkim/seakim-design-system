# Triage labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the label strings used in Linear.

| Label in mattpocock/skills | Label in Linear    | Meaning                                  |
| -------------------------- | ------------------ | ---------------------------------------- |
| `needs-triage`             | `needs-triage`     | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`       | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`  | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`  | Requires human implementation            |
| `wontfix`                  | `wontfix`          | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the label string from this table.

None of these labels exist in the workspace yet (as of 2026-09-18 the workspace has only `Bug`, `Feature`, `Improvement`). Create one with `create_issue_label` on the Christopherkim team the first time a skill needs it. Do not create a label until an issue is about to receive it.

Edit the right-hand column to match whatever vocabulary you actually use.

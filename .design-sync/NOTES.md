# Sync notes — SeaKim Design System

This repo mirrors the Claude Design project **"Design system foundations"**
(`d4854e4e-47cd-4ae1-a94c-b85f3db05760`,
https://claude.ai/design/p/d4854e4e-47cd-4ae1-a94c-b85f3db05760).

Files were pulled **design → repo**. The project is a regular Claude Design
project (not a registered "design system" type), so the design agent inside it
already builds apps with these components. This repo adds git history, review,
and the Flutter / Next ports.

## Sync model: HYBRID

- Design explores/changes in Claude Design.
- Changes are pulled into this repo.
- **The repo is canonical.** Push-backs go repo → design.
- Rule: don't edit both sides between syncs. Reconcile through the repo.

## etag manifest

`.design-sync/manifest.json` records each remote file's `etag` from the last
sync. It makes both directions cheap and safe:

- **Pull (design → repo):** re-list the project, compare each remote `etag`
  against the manifest, download only changed/new files, delete locally what was
  removed remotely, then rewrite the manifest.
- **Push (repo → design):** for each locally changed file, write it with the
  manifest `etag` as `if_match`. A mismatch means someone edited that file in
  the browser since the last sync — stop and reconcile instead of clobbering.

Regenerate after any successful sync so it always reflects the true remote state.

## How to run a sync

Ask Claude in this repo, e.g.:

- "Pull the latest from Claude Design" — incremental pull using the manifest.
- "Push my local changes to Claude Design" — diff working tree vs manifest,
  write changed files with `if_match`, report any conflicts first.
- "What changed remotely since last sync?" — list + etag diff, no writes.

Claude uses the `mcp__claude-design__*` tools (`list_files`, `read_file`,
`finalize_plan`, `write_files`, `delete_files`). `.thumbnail` is a generated
preview artifact and is not mirrored into the working tree.

## Skipped from the working tree

- `.thumbnail` — remote-generated preview image; tracked in the manifest, not
  written to disk.

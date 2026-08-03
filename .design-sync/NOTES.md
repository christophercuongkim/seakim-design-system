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

Either ask Claude directly in this repo, or use the wrapper script
`scripts/ds-sync.sh` (it just launches Claude with the right prompt — the sync
runs through Claude Design's MCP tools, which only Claude can drive):

```sh
scripts/ds-sync.sh pull     # Claude Design -> repo (download changes)
scripts/ds-sync.sh push     # repo -> Claude Design (upload local changes)
scripts/ds-sync.sh status   # remote changes since last sync (read-only)
```

Equivalent plain-language asks:

- "Pull the latest from Claude Design" — incremental pull using the manifest.
- "Push my local changes to Claude Design" — diff working tree vs manifest,
  write changed files with `if_match`, report any conflicts first.
- "What changed remotely since last sync?" — list + etag diff, no writes.

If a tool call reports it is unauthorized, run `/design-login` in Claude and
retry.

Claude uses the `mcp__claude-design__*` tools (`list_files`, `read_file`,
`finalize_plan`, `write_files`, `delete_files`). `.thumbnail` is a generated
preview artifact and is not mirrored into the working tree.

## Auto-sync on git push (pre-push hook)

`scripts/hooks/pre-push` mirrors a GitHub push to Claude Design. On `git push`
to `origin`, if the pushed commits touch any mirrored file (present in
`manifest.json`), it runs the repo -> design push. Pushes that only touch
tooling (`scripts/`, `.design-sync/`) are skipped.

It **never blocks the GitHub push** — if the design side fails or is skipped,
git still pushes.

Modes:
- default: interactive design push if a terminal is attached; otherwise a
  reminder to run `scripts/ds-sync.sh push`.
- `DS_DESIGN_PUSH=auto git push`: headless push, under your normal Claude
  permission settings (no permission bypass — allowlist the Claude Design tools
  in your Claude settings to make unattended pushes actually write).
- `DS_SKIP_DESIGN_PUSH=1 git push` (or `DS_DESIGN_PUSH=off`): skip.

**Enabling it (once per clone):** the hook lives in-repo but git doesn't wire it
up automatically. Run:

```sh
git config core.hooksPath scripts/hooks
```

(Already set in this working copy.)

## Flutter port — build status (verified 2026-08-03)

Toolchain used: Flutter 3.44.3 / Dart 3.12.2.

- `flutter pub get` + `flutter analyze` → **clean (No issues found)** after fixing
  the code-level issues below. So the port's own Dart is correct.
- Fixes applied (the README's "Before you trust this" predictions were accurate):
  - `SkGlyph` typedef used a nullable optional param `[PhosphorIconsStyle? style]`;
    phosphor 2.1.0 exposes glyphs with a non-nullable optional param. Made it
    non-nullable (`sk_icon.dart`).
  - `sk_button.dart` / `sk_icon_button.dart` typed their icon fields as bare
    `PhosphorIconData`; changed to `SkGlyph` (+ dropped now-unused phosphor imports).
  - `sk_input.dart` imported `TextSelectionTheme` but used `TextSelectionThemeData`
    — fixed the `show` list.
  - `sk_textarea.dart` missed `import 'package:flutter/services.dart'` for
    `TextInputAction`.
  - Removed unused imports in `sk_theme.dart` and `sk_type.dart`.
- A runtime smoke test lives at `flutter/test/smoke_test.dart`.

**Runtime build is blocked by an upstream/SDK version squeeze (not the DS code):**
- `phosphor_flutter` (latest 2.1.0, and even its git `main`) does
  `class PhosphorIconData extends IconData`. Flutter sealed `IconData`
  (`final class`) in 3.27+, so this fails the kernel compile on 3.44.3
  (analyzer allows it; `flutter test`/build does not). No published phosphor
  version fixes this.
- Meanwhile the DS itself uses `Color.withValues` (5 sites), which needs
  Flutter **>= 3.27**. So phosphor wants `< 3.27`, the DS code wants `>= 3.27`
  — no single stock Flutter satisfies both today.

Paths to a green runtime build (pick one; not yet done):
1. Swap the icon dependency off phosphor (or use a fork that stops subclassing
   `IconData`), staying on modern Flutter. Cleanest long-term.
2. Pin Flutter `< 3.27` AND replace the 5 `Color.withValues(alpha: x)` with
   `withOpacity(x)` (the README's own note #2). Makes it build on the port's
   intended older SDK.
3. Wait for a phosphor release compatible with sealed `IconData`.

Fonts: `pubspec.yaml` declares 10 `.ttf` assets under `assets/fonts/` that are
not committed (licensing). A real build/test needs them present; the smoke test
was exercised with temporary empty placeholders (removed after).

## Skipped from the working tree

- `.thumbnail` — remote-generated preview image; tracked in the manifest, not
  written to disk.

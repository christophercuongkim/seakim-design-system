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

## Flutter port — build status (RESOLVED 2026-08-03)

Toolchain: Flutter 3.44.x / Dart 3.12.2. `flutter analyze` clean, `flutter test`
green. The port compiles AND runs.

**The blocker and its fix.** `phosphor_flutter` subclasses `IconData`, which
Flutter sealed (`final class`) in 3.27+; the DS also uses `Color.withValues`,
which requires 3.27+. No stock SDK satisfied both. Resolved by dropping the
package and bundling the Phosphor fonts directly:
- `assets/icons/Phosphor-{Regular,Bold,Fill,Duotone}.ttf` (MIT, licence carried).
- `tool/phosphor_codepoints.json` (all 1512 glyphs) -> `tool/gen_icons.dart` ->
  `lib/src/tokens/sk_icons.g.dart`. Same generated-artifact pattern as
  `palette.g.dart`; never hand-edit the `.g.dart`.
- `SkGlyph` is now a value type holding four `const IconData` (const is required
  for `--tree-shake-icons`), not a phosphor function typedef.
- Duotone is a glyph pair rendered as a stack, backdrop at 20% opacity.
- Call sites swept: `PhosphorIcons.x` -> `SkIcons.x` across 6 widgets.

**Bugs found and fixed along the way** (all pre-existing, unreachable while the
package would not compile):
- `SkGlyph` optional param nullable vs phosphor's non-nullable.
- `sk_button` / `sk_icon_button` typed icon fields as bare `PhosphorIconData`.
- `sk_input` imported `TextSelectionTheme` but used `TextSelectionThemeData`.
- `sk_textarea` missed `services.dart` for `TextInputAction`.
- **`SkApp` never provided a `Directionality`** despite its doc claiming to. Any
  app using `SkApp` without a `WidgetsApp` above it crashed on the first `Icon`.
  Caught only by running the widget test — the analyzer cannot see it.

**Licensing.** `registerSkLicenses()` (called by `SkApp`, idempotent) registers
the Phosphor MIT notice with `LicenseRegistry`, so `showLicensePage()` satisfies
attribution for every consuming app. MIT does not require consuming apps to be
open source; it requires the notice to ship. The three text families are SIL OFL
and still need their notices added once the binaries are committed.

**Still open:**
- Text fonts (10 `.ttf`) are not committed (licensing); the asset bundle will not
  build without them. Tests were run against temporary empty placeholders.
- Tree shaking is designed for but UNVERIFIED — needs a release build of a real
  app target, which this library package does not have.
- Screens are still not ported.

## Skipped from the working tree

- `.thumbnail` — remote-generated preview image; tracked in the manifest, not
  written to disk.

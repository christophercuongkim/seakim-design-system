#!/usr/bin/env bash
#
# ds-sync.sh — sync this repo with its Claude Design project.
#
# The sync itself runs through Claude Design's MCP tools, which are authorized
# through your claude.ai login and can only be driven by Claude Code. So this
# script is a thin launcher: it starts `claude` with a self-contained prompt for
# the chosen direction. Run it from anywhere in the repo; it needs the
# `claude` CLI on PATH and a valid design login (run /design-login in Claude if
# a call reports it is unauthorized).
#
# Usage:
#   scripts/ds-sync.sh pull     # Claude Design -> repo (download changes)
#   scripts/ds-sync.sh push     # repo -> Claude Design (upload local changes)
#   scripts/ds-sync.sh status   # show remote changes since last sync (no writes)
#
set -euo pipefail

# Resolve repo root from this script's location so it works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.design-sync/config.json"

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH." >&2
  exit 1
fi
if [[ ! -f "$CONFIG" ]]; then
  echo "error: $CONFIG not found — is this the design-system repo?" >&2
  exit 1
fi

cmd="${1:-help}"

read -r -d '' PULL_PROMPT <<'EOF' || true
Sync this repo FROM Claude Design (design -> repo), non-interactively.
1. Read .design-sync/config.json (projectId) and .design-sync/manifest.json (last-synced remote etags).
2. Call mcp__claude-design__list_files on the project with depth -1.
3. Diff each remote entry's etag against the manifest:
   - new or changed etag -> mcp__claude-design__read_file (full), decode HTML entities (&lt; &gt; &amp;, &amp; last), write to the mirrored path.
   - in manifest but gone from remote -> delete the local file.
   - .thumbnail is never written to the working tree (manifest-only).
4. Rewrite .design-sync/manifest.json to the new remote state (every file entry, sorted by path).
5. Report a concise summary: changed, added, deleted, unchanged counts. Do not commit unless I ask.
EOF

read -r -d '' PUSH_PROMPT <<'EOF' || true
Push local changes TO Claude Design (repo -> design), conflict-safe.
1. Read .design-sync/config.json (projectId) and .design-sync/manifest.json.
2. Consider ONLY files that exist in the manifest (the mirrored tree) — ignore .design-sync/, scripts/, and anything not tracked remotely.
3. Find locally modified/new mirrored files (compare working tree to the manifest; use git status for hints).
4. mcp__claude-design__finalize_plan with the exact write/delete paths, then mcp__claude-design__write_files each changed file passing if_match = its manifest etag. Any if_match mismatch means the file was edited in the browser since last sync: STOP that file, do not overwrite, and report it as a conflict to reconcile.
5. After writes succeed, re-list remote etags and rewrite .design-sync/manifest.json.
6. Report a summary: pushed, skipped-conflict, deleted. List any conflicts explicitly.
EOF

read -r -d '' STATUS_PROMPT <<'EOF' || true
Report what changed in Claude Design since the last sync. READ ONLY — make no writes.
1. Read .design-sync/manifest.json.
2. mcp__claude-design__list_files depth -1 on the project in .design-sync/config.json.
3. Diff etags and report: files changed remotely, files added remotely, files deleted remotely. No downloads, no manifest rewrite.
EOF

case "$cmd" in
  pull)   prompt="$PULL_PROMPT" ;;
  push)   prompt="$PUSH_PROMPT" ;;
  status) prompt="$STATUS_PROMPT" ;;
  help|-h|--help)
    sed -n '3,15p' "$SCRIPT_DIR/ds-sync.sh"
    exit 0 ;;
  *)
    echo "unknown command: $cmd" >&2
    echo "usage: ds-sync.sh {pull|push|status}" >&2
    exit 2 ;;
esac

cd "$REPO_ROOT"
exec claude "$prompt"

#!/usr/bin/env bash
# Safe wrapper to (re)generate the locked snapshot Brewfile.
# Usage: ./scripts/brew-dump-snapshot.sh [--force]
# - Ensures brew present, warns if uncommitted changes, and preserves timestamp comment.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BREW_DIR="$ROOT_DIR/homebrew"
SNAPSHOT="$BREW_DIR/Brewfile"
FORCE=false
if [[ ${1:-} == --force ]]; then FORCE=true; fi
command -v brew >/dev/null 2>&1 || { echo "brew not found" >&2; exit 1; }
if ! $FORCE; then
  if ! git diff --quiet --exit-code; then
    echo "Working tree has uncommitted changes. Commit/stash or use --force." >&2
    exit 1
  fi
fi
# Add header notice
HEADER="# Snapshot Brewfile (generated via brew bundle dump)\n# Regenerate with: ./scripts/brew-dump-snapshot.sh\n# Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)\n"
TEMP=$(mktemp)
brew bundle dump --file="$TEMP" --force
{ printf "%s" "$HEADER"; cat "$TEMP" | sed '/^# /d'; } > "$SNAPSHOT"
rm -f "$TEMP"
echo "Updated snapshot at $SNAPSHOT"

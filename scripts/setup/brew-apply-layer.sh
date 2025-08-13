#!/usr/bin/env bash
# Interactive layered Brewfile installer (cross-platform macOS/Linux; fonts & casks auto-skip on Linux)
# Usage: ./scripts/brew-apply-layer.sh [--dry-run] [layers...]
# Layers (filenames without path): min dev extra fonts vscode snapshot
# If no layers provided interactively prompt.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BREW_DIR="$ROOT_DIR/homebrew"
DRY_RUN=false
if [[ ${1:-} == "--dry-run" ]]; then DRY_RUN=true; shift; fi
AVAILABLE=(min dev gui extra fonts vscode)
# snapshot refers to Brewfile (full snapshot)
log() { printf '%s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }
require() { command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }; }
require brew
is_linux() { [[ $(uname -s) == Linux* ]]; }
apply_layer() {
  local layer="$1" file
  case "$layer" in
    snapshot) file="$BREW_DIR/Brewfile" ;;
    *) file="$BREW_DIR/Brewfile.$layer" ;;
  esac
  if [[ ! -f $file ]]; then err "Layer file not found: $file"; return 1; fi
  log "==> Applying layer: $layer ($file)";
  if is_linux; then
    # Filter out casks on Linux (silently) by generating temp Brewfile
    local tmp; tmp=$(mktemp)
    awk '/^cask / {next} {print}' "$file" > "$tmp"
    if $DRY_RUN; then
      log "[dry-run] brew bundle --file=$file (casks filtered for Linux)";
      grep -E '^(brew|tap|vscode)' "$tmp" || true
    else
      BREWFILE_DIR=$(dirname "$tmp") brew bundle --file="$tmp"
    fi
    rm -f "$tmp"
  else
    if $DRY_RUN; then
      log "[dry-run] brew bundle --file=$file"
      grep -E '^(brew|cask|tap|vscode)' "$file" || true
    else
      brew bundle --file="$file"
    fi
  fi
}
if [[ $# -eq 0 ]]; then
  log "Select layers to apply (space separated):"
  log "Available: ${AVAILABLE[*]} snapshot"
  read -r -p "> " selection
  set -- $selection
fi
for layer in "$@"; do
  apply_layer "$layer"
  log
done
log "Done.";
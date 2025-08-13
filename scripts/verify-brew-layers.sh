#!/usr/bin/env bash
# Verification script for layered Brewfile installs.
# Usage: ./scripts/verify-brew-layers.sh [--layers "min dev gui extra fonts vscode"] [--show-overlaps]
# Exit codes: 0 success, 1 failure.
set -euo pipefail
LAYERS_INPUT=""
SHOW_OVERLAPS=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layers) LAYERS_INPUT="$2"; shift 2;;
    --show-overlaps) SHOW_OVERLAPS=true; shift;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
BREW_DIR="$ROOT_DIR/homebrew"
: "${LAYERS_INPUT:=min dev}"
IFS=' ' read -r -a LAYERS <<< "$LAYERS_INPUT"
missing=()
declare -A seen
check_formula() {
  local f="$1" layer="$2"
  if ! brew list --formula --versions "$f" >/dev/null 2>&1; then missing+=("formula:$f"); fi
  if $SHOW_OVERLAPS; then
    if [[ -n ${seen[formula:$f]:-} && ${seen[formula:$f]} != "$layer" ]]; then
      echo "Overlap formula: $f (also in ${seen[formula:$f]})" >&2
    else
      seen[formula:$f]="$layer"
    fi
  fi
}
check_cask() {
  local c="$1" layer="$2"; [[ $(uname -s) == Linux* ]] && return 0
  if ! brew list --cask --versions "$c" >/dev/null 2>&1; then missing+=("cask:$c"); fi
  if $SHOW_OVERLAPS; then
    if [[ -n ${seen[cask:$c]:-} && ${seen[cask:$c]} != "$layer" ]]; then
      echo "Overlap cask: $c (also in ${seen[cask:$c]})" >&2
    else
      seen[cask:$c]="$layer"
    fi
  fi
}
for layer in "${LAYERS[@]}"; do
  file="$BREW_DIR/Brewfile.$layer"
  [[ $layer == snapshot ]] && file="$BREW_DIR/Brewfile"
  if [[ ! -f $file ]]; then echo "Layer file missing: $file" >&2; exit 1; fi
  while IFS= read -r line; do
    [[ -z $line || $line == \#* ]] && continue
    if [[ $line =~ ^brew\ "([^"]+)" ]]; then check_formula "${BASH_REMATCH[1]}" "$layer"; fi
    if [[ $line =~ ^cask\ "([^"]+)" ]]; then check_cask "${BASH_REMATCH[1]}" "$layer"; fi
  done < "$file"
done
if ((${#missing[@]})); then
  printf 'Missing packages (%d):\n' "${#missing[@]}" >&2
  printf '%s\n' "${missing[@]}" >&2
  exit 1
fi
echo "All requested layer packages present."; $SHOW_OVERLAPS && echo "Overlap check complete." || true

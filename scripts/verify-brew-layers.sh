#!/usr/bin/env bash
# Verification script for layered Brewfile installs.
# Usage: ./scripts/verify-brew-layers.sh [--layers "min dev extra fonts vscode"]
# Exit codes: 0 success, 1 failure.
set -euo pipefail
LAYERS_INPUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layers) LAYERS_INPUT="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
BREW_DIR="$ROOT_DIR/homebrew"
: "${LAYERS_INPUT:=min dev}"
IFS=' ' read -r -a LAYERS <<< "$LAYERS_INPUT"
missing=()
check_formula() {
  local f="$1"
  if ! brew list --formula --versions "$f" >/dev/null 2>&1; then missing+=("formula:$f"); fi
}
check_cask() {
  local c="$1"; [[ $(uname -s) == Linux* ]] && return 0
  if ! brew list --cask --versions "$c" >/dev/null 2>&1; then missing+=("cask:$c"); fi
}
for layer in "${LAYERS[@]}"; do
  file="$BREW_DIR/Brewfile.$layer"
  [[ $layer == snapshot ]] && file="$BREW_DIR/Brewfile"
  if [[ ! -f $file ]]; then echo "Layer file missing: $file" >&2; exit 1; fi
  while IFS= read -r line; do
    [[ -z $line || $line == \#* ]] && continue
    if [[ $line =~ ^brew\ "([^"]+)" ]]; then check_formula "${BASH_REMATCH[1]}"; fi
    if [[ $line =~ ^cask\ "([^"]+)" ]]; then check_cask "${BASH_REMATCH[1]}"; fi
  done < "$file"
done
if ((${#missing[@]})); then
  printf 'Missing packages (%d):\n' "${#missing[@]}" >&2
  printf '%s\n' "${missing[@]}" >&2
  exit 1
fi
echo "All requested layer packages present."
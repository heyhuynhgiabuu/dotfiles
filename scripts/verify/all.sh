#!/usr/bin/env sh
# Aggregate verifier: runs all verify/* scripts (excluding itself) and summarizes results.
# Usage: ./scripts/verify/all.sh [--fast]
#   --fast : skip heavy or optional checks (currently none tagged; placeholder)

set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
FAST=0
[ "${1:-}" = "--fast" ] && FAST=1

# Collect verify scripts (exclude all.sh)
SCRIPTS=$(ls "$SCRIPT_DIR" | grep -E '^verify-.*\.sh$' | sort)

TOTAL=0
PASS=0
FAIL=0
WARN=0

run_script() {
  local script="$1"
  printf '\n==> %s\n' "$script"
  if sh "$SCRIPT_DIR/$script"; then
    PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1))
  fi
  TOTAL=$((TOTAL+1))
}

for s in $SCRIPTS; do
  # Placeholder for future fast-skip tagging logic
  run_script "$s"
done

printf '\nSummary: %d total | %d passed | %d failed\n' "$TOTAL" "$PASS" "$FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0

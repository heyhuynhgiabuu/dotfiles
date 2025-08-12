#!/usr/bin/env bash
# verify-doc-consistency.sh
# Guardrail: prevent reintroduction of deprecated legacy section headings.
# Fails (non-zero exit) if forbidden legacy headings/phrases are present
# outside the consolidated unified protocol context in opencode/AGENTS.md.
# Cross-platform: uses POSIX shell + grep; optionally uses rg if available for speed.
#
# Forbidden exact heading lines (case-sensitive):
#   ## ⚡ Autonomous Execution Rules
#   ## Autonomous Execution Rules
#   ## Execution Rules
#   ### Todo List Management
# Also disallow "## Execution Rules:" variant.
# We allow contextual references in explanatory sentences (lowercase) inside
# the current unified section; we only block them when they appear as headings.
#
# Exit codes:
#   0 - OK (no forbidden headings)
#   1 - Found forbidden headings
#   2 - Script error / misuse
#
# Usage:
#   bash scripts/verify-doc-consistency.sh
#
# Manual verification steps:
#   1. Run script: expect "No forbidden legacy headings found." (exit 0)
#   2. Append "## Execution Rules" to opencode/AGENTS.md (or a temp copy) and re-run: expect non-zero exit.
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_FILE="${ROOT_DIR}/opencode/AGENTS.md"

if [ ! -f "$TARGET_FILE" ]; then
  echo "[ERROR] Cannot find AGENTS.md at expected path: $TARGET_FILE" >&2
  exit 2
fi

FORBIDDEN_PATTERNS=(
  '^## ⚡ Autonomous Execution Rules$'
  '^## Autonomous Execution Rules$'
  '^## Execution Rules:?$'
  '^### Todo List Management$'
)

found_any=0

search_file() {
  local pattern="$1"
  # Prefer rg if installed for consistent regex handling
  if command -v rg >/dev/null 2>&1; then
    rg --color=never -N -e "$pattern" "$TARGET_FILE" || return 1
  else
    grep -E "$pattern" "$TARGET_FILE" || return 1
  fi
  return 0
}

for pat in "${FORBIDDEN_PATTERNS[@]}"; do
  if search_file "$pat"; then
    echo "[BLOCKED] Forbidden heading detected: pattern: $pat"
    found_any=1
  fi
done

if [ "$found_any" -eq 1 ]; then
  echo "\nValidation failed: remove or rename forbidden legacy headings above."
  exit 1
fi

echo "No forbidden legacy headings found." 
exit 0

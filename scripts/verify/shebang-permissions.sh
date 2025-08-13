#!/usr/bin/env sh
# Shebang and permission audit for scripts/*.sh
# - Ensures .sh files under scripts/ are executable
# - Flags bashisms in files declaring /usr/bin/env sh
# Usage: ./scripts/verify/shebang-permissions.sh

set -u
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
cd "$REPO_ROOT" || exit 1

# Collect scripts
FILES=$(find scripts -type f -name '*.sh' 2>/dev/null | sort)

PASS=0
WARN=0
FAIL=0

warnf() { printf "[WARN] %s\n" "$1"; WARN=$((WARN+1)); }
failf() { printf "[FAIL] %s\n" "$1"; FAIL=$((FAIL+1)); }
passf() { printf "[PASS] %s\n" "$1"; PASS=$((PASS+1)); }

if [ -z "$FILES" ]; then
  echo "No .sh files under scripts/"
  exit 0
fi

# Simple bashism patterns to flag in POSIX sh scripts
BASHISM_REGEX='(\[\[|\]\]|\<\(|function\s+|==\s|\$RANDOM|select\s)'

for f in $FILES; do
  # Check shebang
  first="$(head -n1 "$f" 2>/dev/null || true)"
  case "$first" in
    "#!/usr/bin/env sh"|"#!/bin/sh")
      # POSIX sh declared; check for common bashisms
      if grep -Eq "$BASHISM_REGEX" "$f"; then
        warnf "$f: bashisms detected but shebang is sh"
      else
        passf "$f: sh-compatible"
      fi
      ;;
    "#!/usr/bin/env bash"|"#!/bin/bash")
      passf "$f: bash script"
      ;;
    *)
      warnf "$f: missing or non-standard shebang"
      ;;
  esac

  # Check executable bit
  if [ -x "$f" ]; then
    :
  else
    warnf "$f: not executable (+x)"
  fi

done

printf "\nSummary: %d PASS, %d WARN, %d FAIL\n" "$PASS" "$WARN" "$FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0

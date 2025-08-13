#!/usr/bin/env sh
# List categorized scripts with first comment line as description.
# Usage: ./scripts/list.sh [--grep <pattern>]

set -u
PATTERN=""
if [ "${1:-}" = "--grep" ] && [ -n "${2:-}" ]; then
  PATTERN="$2"
fi

REPO_ROOT=$(cd "$(dirname "$0")" && pwd)

# Categories are subdirectories of scripts plus root scripts (if any)
for dir in "$REPO_ROOT"/*; do
  [ -d "$dir" ] || continue
  category=$(basename "$dir")
  case "$category" in
    node_modules|plugin) continue ;;
  esac
  scripts=$(find "$dir" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | sort)
  [ -z "$scripts" ] && continue
  echo "# $category"
  for s in $scripts; do
    name=$(basename "$s")
    # Extract first non-empty comment line
    desc=$(awk 'NR<=5 && /^#/ {gsub(/^# ?/, ""); if(length($0)>0){print; exit}}' "$s")
    line="$name - ${desc:-no description}"
    if [ -n "$PATTERN" ]; then
      echo "$line" | grep -i -- "$PATTERN" || true
    else
      echo "$line"
    fi
  done
  echo
done

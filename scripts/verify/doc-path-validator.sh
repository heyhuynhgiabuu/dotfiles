#!/usr/bin/env sh
# Validate that script references in docs (*.md) point to existing files under scripts/.
# Scans for patterns ./scripts/... ending with .sh and checks existence.
# Usage: ./scripts/verify/doc-path-validator.sh

set -u
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
cd "$REPO_ROOT" || exit 1

# Find markdown files (exclude node_modules or vendored directories if any)
MD_FILES=$(find . -type f -name '*.md' \( -not -path '*/node_modules/*' -a -not -path '*/.serena/*' \))

MISSING=0
TMP_OUT=$(mktemp)

# Regex: ./scripts/<path>.sh (avoid backticks optional)
# Use grep -o to pull candidate paths
for f in $MD_FILES; do
  # Extract matches
  MATCHES=$(grep -Eo '\./scripts/[A-Za-z0-9_./-]+\.sh' "$f" || true)
  [ -z "$MATCHES" ] && continue
  for p in $MATCHES; do
    # Normalize path without leading ./
    REL="${p#./}"
    if [ ! -f "$REL" ]; then
      printf '%s -> MISSING (%s)\n' "$f" "$p" >> "$TMP_OUT"
      MISSING=$((MISSING+1))
    fi
  done
done

if [ "$MISSING" -gt 0 ]; then
  echo "Found $MISSING broken script reference(s):"
  sort -u "$TMP_OUT"
  rm -f "$TMP_OUT"
  exit 1
fi

rm -f "$TMP_OUT"
echo "All referenced script paths in docs exist."
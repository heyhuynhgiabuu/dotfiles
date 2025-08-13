#!/usr/bin/env bash
# pre-review-manifest.sh
# Generate a pre-review manifest for a PR: changed files table + simple risk tags.
# Cross-platform (macOS/Linux) POSIX-friendly (bash used for arrays & string ops only).
# No external deps beyond: git, awk, sed, grep (prefer rg if present).
# Usage:
#   ./scripts/pre-review-manifest.sh [BASE_BRANCH]
# If BASE_BRANCH omitted, tries to detect via gh (if installed) else defaults to main.

set -euo pipefail

color_enabled() { [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; }

log() { printf '%s\n' "$*" >&2; }

BASE_BRANCH="${1:-}"
if [ -z "$BASE_BRANCH" ]; then
  if command -v gh >/dev/null 2>&1; then
    set +e
    detected=$(gh pr view --json baseRefName 2>/dev/null | sed -n 's/.*"baseRefName": *"\(.*\)".*/\1/p')
    set -e
    if [ -n "$detected" ]; then
      BASE_BRANCH="$detected"
    fi
  fi
fi
[ -z "$BASE_BRANCH" ] && BASE_BRANCH="main" && log "[info] Falling back to base branch: main"

# Ensure we have the latest base branch refs (best effort)
if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  git fetch --quiet origin "$BASE_BRANCH" || true
fi

# Collect diff stats
# name-status for type, numstat for line counts
numstat=$(git diff --numstat "$BASE_BRANCH"...HEAD || true)
namestat=$(git diff --name-status "$BASE_BRANCH"...HEAD || true)

if [ -z "$numstat" ]; then
  echo "No changes detected against $BASE_BRANCH" && exit 0
fi

# Build associative maps (requires bash)
declare -A add_map del_map status_map
while IFS=$'\t' read -r add del path; do
  [ -z "$path" ] && continue
  add_map["$path"]="$add"
  del_map["$path"]="$del"
done <<<"$numstat"

while IFS=$'\t' read -r st path; do
  [ -z "$path" ] && continue
  status_map["$path"]="$st"
done <<<"$namestat"

type_for() {
  case "$1" in
    *test*|tests/*|*_test.*) echo "test" ;;
    *.md|docs/*) echo "docs" ;;
    *.yml|*.yaml|*.json|config/*|*.toml) echo "config" ;;
    Dockerfile*|ops/*|infra/*) echo "infra" ;;
    *) echo "code" ;;
  esac
}

risk_tags() {
  local p="$1" tags=()
  if grep -qiE '(auth|token|secret|crypto)' <<<"$p"; then tags+=(security); fi
  if grep -qiE '(legacy|deprecated|old)' <<<"$p"; then tags+=(legacy); fi
  if grep -qiE '(perf|optimiz)' <<<"$p"; then tags+=(perf); fi
  if [[ $(type_for "$p") == test ]]; then tags+=(coverage); fi
  if [ ${#tags[@]} -eq 0 ]; then echo "-"; else printf '%s' "${tags[*]}"; fi
}

# Assemble table
printf '## Changed Files (Base: %s)\n' "$BASE_BRANCH"
printf '| File | + | - | Status | Type | Risk Tags |\n'
printf '|------|---|---|--------|------|-----------|\n'

total_add=0
TOTAL_DEL=0
for path in "${!add_map[@]}"; do
  add=${add_map[$path]}
  del=${del_map[$path]}
  st=${status_map[$path]:-M}
  t=$(type_for "$path")
  r=$(risk_tags "$path")
  printf '| %s | %s | %s | %s | %s | %s |\n' "$path" "$add" "$del" "$st" "$t" "$r"
  total_add=$(( total_add + (add == '-' ? 0 : add) ))
  TOTAL_DEL=$(( TOTAL_DEL + (del == '-' ? 0 : del) ))
done | sort

# Summary block
files_changed=${#add_map[@]}
printf '\n**Scope:** %s files changed (+%s / -%s lines) against %s\n' "$files_changed" "$total_add" "$TOTAL_DEL" "$BASE_BRANCH"
printf '**High-Risk Guess:** Files tagged with security or legacy above (manual confirmation needed).\n'

cat <<'NOTE'
> Use this manifest as the basis for the Review Summary & Changed Files table.
> Replace or augment risk tags after inspecting actual diff content.
NOTE

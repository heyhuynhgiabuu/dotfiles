#!/usr/bin/env bash
# diff-risk-classifier.sh
# Heuristically classify changed files in the current branch vs a base branch
# and emit a machine-consumable JSON manifest (and optional markdown table).
# Cross-platform (macOS/Linux) – requires: git, bash. Falls back gracefully.
# Usage:
#   ./scripts/diff-risk-classifier.sh [--base <branch>] [--md]
# Defaults: base=main, output JSON to stdout. If --md supplied, prints a
# markdown table after JSON (separated by a blank line).
# Rationale: Provides a slightly richer (but still lightweight) risk signal
# for the Reviewer agent before deep inspection. Complements pre-review-manifest.sh.

set -euo pipefail

BASE="main"
OUTPUT_MD=false

while [ $# -gt 0 ]; do
  case "$1" in
    --base)
      shift; BASE="${1:-main}" ;;
    --md)
      OUTPUT_MD=true ;;
    *)
      echo "[warn] Unknown argument: $1" >&2 ;;
  esac
  shift || true
done

# Attempt auto-detect via gh if base not explicitly set and gh available.
if [ "$BASE" = "main" ] && command -v gh >/dev/null 2>&1; then
  set +e
  detected=$(gh pr view --json baseRefName 2>/dev/null | sed -n 's/.*"baseRefName": *"\(.*\)".*/\1/p')
  set -e
  [ -n "$detected" ] && BASE="$detected"
fi

if git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  git fetch --quiet origin "$BASE" || true
else
  echo "[info] Base branch $BASE not found locally; proceeding with local refs only" >&2
fi

diff_numstat=$(git diff --numstat "$BASE"...HEAD || true)
[ -z "$diff_numstat" ] && { echo '[]'; exit 0; }

echo '['
first=true
md_rows=""
while IFS=$'\t' read -r adds dels path; do
  [ -z "$path" ] && continue
  status=$(git diff --name-status "$BASE"...HEAD -- "$path" | awk '{print $1}' | head -1)
  [ -z "$status" ] && status="M"
  # Determine coarse type
  case "$path" in
    *test*|tests/*|*_test.*) ftype="test" ;;
    *.md|docs/*) ftype="docs" ;;
    *.yml|*.yaml|*.json|config/*|*.toml) ftype="config" ;;
    Dockerfile*|ops/*|infra/*) ftype="infra" ;;
    *) ftype="code" ;;
  esac
  # Risk heuristics (path + simple keyword based; can be expanded later)
  risks=()
  if echo "$path" | grep -qiE '(auth|token|secret|crypto|encrypt|jwt)'; then risks+=("security"); fi
  if echo "$path" | grep -qiE '(legacy|deprecated|old)'; then risks+=("legacy"); fi
  if echo "$path" | grep -qiE '(perf|bench|optim)'; then risks+=("performance"); fi
  if [ "$ftype" = test ]; then risks+=("coverage"); fi
  if echo "$path" | grep -qiE '(config|setting|env)'; then risks+=("config"); fi
  # Size-based heuristic
  if [ "$adds" != "-" ] && [ "$adds" -gt 200 ]; then risks+=("large-change"); fi
  # Deduplicate risks
  uniq_risks=()
  for r in "${risks[@]}"; do
    skip=false
    for ur in "${uniq_risks[@]}"; do [ "$ur" = "$r" ] && skip=true && break; done
    ! $skip && uniq_risks+=("$r") || true
  done
  risks_json="[]"
  if [ ${#uniq_risks[@]} -gt 0 ]; then
    risks_json="[\"$(printf '%s" ,"' "${uniq_risks[@]}" | sed 's/",$//')"]"
  fi
  # Emit JSON object
  if ! $first; then echo ','; fi
  first=false
  printf '{"file":"%s","adds":%s,"dels":%s,"status":"%s","type":"%s","risks":%s}' \
    "$path" "${adds//-/0}" "${dels//-/0}" "$status" "$ftype" "$risks_json"
  # Collect MD row
  md_risks=$(printf '%s ' "${uniq_risks[@]}" | sed 's/ *$//')
  [ -z "$md_risks" ] && md_risks='-'
  md_rows+="| $path | ${adds//-/0} | ${dels//-/0} | $status | $ftype | $md_risks |\n"

done <<<"$diff_numstat"
echo
printf ']'  # close JSON array

if $OUTPUT_MD; then
  echo -e "\n\n## Diff Risk Classification (Base: $BASE)" \
  "\n| File | + | - | Status | Type | Risks |" \
  "\n|------|---|---|--------|------|-------|" \
  "\n$md_rows"
fi

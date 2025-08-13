#!/usr/bin/env bash
# diff-risk-classifier.sh
# Heuristically classify changed files in the current branch vs a base branch
# and emit a machine-consumable JSON manifest (and optional markdown table).
# Cross-platform (macOS/Linux) – bash 3.2 compatible (no arrays requiring bash 4 features).
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
    --base) shift; BASE="${1:-main}" ;;
    --md) OUTPUT_MD=true ;;
    *) echo "[warn] Unknown argument: $1" >&2 ;;
  esac; shift || true
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

# We'll avoid bash arrays for risks accumulation by constructing JSON directly.
# Temp storage for MD rows
md_rows=""

printf '['
first_obj=true
while IFS=$'\t' read -r adds dels path; do
  [ -z "$path" ] && continue
  status=$(git diff --name-status "$BASE"...HEAD -- "$path" | awk '{print $1}' | head -1)
  [ -z "$status" ] && status="M"
  case "$path" in
    *test*|tests/*|*_test.*) ftype="test" ;;
    *.md|docs/*) ftype="docs" ;;
    *.yml|*.yaml|*.json|config/*|*.toml) ftype="config" ;;
    Dockerfile*|ops/*|infra/*) ftype="infra" ;;
    *) ftype="code" ;;
  esac
  # Risks accumulation using space-delimited string (dedupe manually)
  risks_str=""
  echo "$path" | grep -qiE '(auth|token|secret|crypto|encrypt|jwt)' && risks_str+="security "
  echo "$path" | grep -qiE '(legacy|deprecated|old)' && risks_str+="legacy "
  echo "$path" | grep -qiE '(perf|bench|optim)' && risks_str+="performance "
  [ "$ftype" = test ] && risks_str+="coverage "
  echo "$path" | grep -qiE '(config|setting|env)' && risks_str+="config "
  if [ "$adds" != "-" ] && [ "$adds" -gt 200 ]; then risks_str+="large_change "; fi
  # Deduplicate
  dedup_risks=""
  for r in $risks_str; do
    found=false
    for ur in $dedup_risks; do [ "$ur" = "$r" ] && found=true && break; done
    $found || dedup_risks+="$r "
  done
  dedup_risks=${dedup_risks% }
  # Build JSON array
  if [ -z "$dedup_risks" ]; then risks_json='[]'; else
    risks_json='['
    first_tag=true
    for tag in $dedup_risks; do
      $first_tag || risks_json+=','
      first_tag=false
      risks_json+="\"$tag\""
    done
    risks_json+=']'
  fi
  $first_obj || printf ',\n'
  first_obj=false
  printf '{"file":"%s","adds":%s,"dels":%s,"status":"%s","type":"%s","risks":%s}' \
    "$path" "${adds//-/0}" "${dels//-/0}" "$status" "$ftype" "$risks_json"
  md_risks=${dedup_risks:-'-'}
  md_rows+="| $path | ${adds//-/0} | ${dels//-/0} | $status | $ftype | $md_risks |\n"
done <<<"$diff_numstat"
printf ']'

if $OUTPUT_MD; then
  printf '\n\n## Diff Risk Classification (Base: %s)\n' "$BASE"
  printf '| File | + | - | Status | Type | Risks |\n'
  printf '|------|---|---|--------|------|-------|\n'
  printf '%b' "$md_rows"
fi

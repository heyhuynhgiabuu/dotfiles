#!/usr/bin/env bash
# legacy-hotspot-detector.sh
# Identify potential legacy/refactor hotspots within the current diff vs a base branch.
# Emits JSON array (one object per candidate) plus optional markdown table with --md.
# Heuristics (additive):
#  - Large change: > 150 added lines or > 250 total churn (adds + dels)
#  - Markers: file contains TODO|FIXME|deprecated|legacy (scanned only if file changed)
#  - Low test adjacency: no changed test file whose basename maps (similar to test-coverage-delta heuristic)
#  - High concentration: > 60% of file lines changed (approx via git diff --numstat vs git ls-files size)
# Score = number of triggered heuristics; candidates with score >=2 emitted (or all if --all supplied)
# Usage:
#   ./scripts/legacy-hotspot-detector.sh [--base <branch>] [--md] [--all]
# Dependencies: git, bash, grep, wc.

set -euo pipefail
BASE="main"; OUTPUT_MD=false; SHOW_ALL=false
while [ $# -gt 0 ]; do
  case "$1" in
    --base) shift; BASE="${1:-main}" ;;
    --md) OUTPUT_MD=true ;;
    --all) SHOW_ALL=true ;;
    *) echo "[warn] Unknown arg: $1" >&2 ;;
  esac; shift || true
done

if [ "$BASE" = "main" ] && command -v gh >/dev/null 2>&1; then
  set +e
  detected=$(gh pr view --json baseRefName 2>/dev/null | sed -n 's/.*"baseRefName": *"\(.*\)".*/\1/p')
  set -e
  [ -n "$detected" ] && BASE="$detected"
fi

git rev-parse --verify "$BASE" >/dev/null 2>&1 && git fetch --quiet origin "$BASE" || true

diff_numstat=$(git diff --numstat "$BASE"...HEAD || true)
[ -z "$diff_numstat" ] && { echo '[]'; exit 0; }
changed_files=$(git diff --name-status "$BASE"...HEAD || true)
changed_test_files=$(echo "$changed_files" | awk '$1 ~ /[ACMDTRU]/ {print $2}' | grep -iE 'test|_test\.|/tests?/|test_' || true)

is_test_file() { local p="$1"; [[ "$p" =~ [Tt]est ]] || [[ "$p" == tests/* ]] || [[ "$p" == test/* ]] || [[ "$p" =~ _test\. ]] || [[ $(basename "$p") == test_* ]]; }

first=true; json="["; md_rows=""
while IFS=$'\t' read -r adds dels path; do
  [ -z "$path" ] && continue
  # skip non-code categories
  case "$path" in
    *.md|docs/*|*.yml|*.yaml|*.json|config/*|*.toml|Dockerfile*|ops/*|infra/*) continue ;;
  esac
  is_test_file "$path" && continue
  adds=${adds//-/0}; dels=${dels//-/0}; churn=$(( adds + dels ))
  status=$(echo "$changed_files" | awk -v p="$path" '$2==p {print $1}' | head -1); [ -z "$status" ] && status="M"
  heuristics=()
  # Large change heuristics
  [ "$adds" -gt 150 ] && heuristics+=("large-addition")
  [ "$churn" -gt 250 ] && heuristics+=("high-churn")
  # Test adjacency
  base_name=$(basename "$path"); core=${base_name%%.*}; core=${core#test_}
  guess1="test_${base_name}"; guess2="${core}_test"; guess3="${core}_test.${base_name#*.}"
  related_changed=false
  while IFS= read -r tf; do tbase=$(basename "$tf"); if [[ "$tbase" == *"$guess2"* ]] || [[ "$tbase" == "$guess1" ]] || [[ "$tbase" == "$guess3" ]]; then related_changed=true; break; fi; done <<<"$changed_test_files"
  ! $related_changed && heuristics+=("no-test-delta")
  # Marker scan (only for files < 400KB to avoid heavy ops)
  if [ -f "$path" ] && [ $(wc -c <"$path") -lt 400000 ]; then
    if grep -qiE 'TODO|FIXME|deprecated|legacy' "$path"; then heuristics+=("markers"); fi
  fi
  # Line count approximation for concentration
  total_lines=0
  if [ -f "$path" ]; then total_lines=$(wc -l <"$path" 2>/dev/null || echo 0); fi
  if [ "$total_lines" -gt 0 ]; then
    changed_ratio=$(awk -v c="$churn" -v t="$total_lines" 'BEGIN { if (t==0) print 0; else print c/t }')
    awk_res=$(echo "$changed_ratio > 0.6" | bc 2>/dev/null || echo 0)
    [ "$awk_res" = 1 ] && heuristics+=("high-concentration")
  fi
  score=${#heuristics[@]}
  $SHOW_ALL || { [ $score -lt 2 ] && continue; }
  # Build JSON
  heur_json="[]"; [ $score -gt 0 ] && heur_json='["'$(printf '%s" ,"' "${heuristics[@]}" | sed 's/",$//')'"]'
  entry=$(printf '{"file":"%s","adds":%s,"dels":%s,"status":"%s","heuristics":%s,"score":%s}' "$path" "$adds" "$dels" "$status" "$heur_json" "$score")
  if ! $first; then json+=" ,"; fi; first=false; json+="$entry"
  md_h="-"; [ $score -gt 0 ] && md_h=$(printf '%s ' "${heuristics[@]}" | sed 's/ *$//')
  md_rows+="| $path | $adds | $dels | $status | $score | $md_h |\n"
done <<<"$diff_numstat"
json+=']'

echo "$json"
if $OUTPUT_MD; then
  echo -e "\n\n## Legacy Hotspot Candidates (Base: $BASE)" \
    "\n| File | + | - | Status | Score | Heuristics |" \
    "\n|------|---|---|--------|-------|------------|" \
    "\n$md_rows"
fi

#!/usr/bin/env bash
# test-coverage-delta.sh
# Minimal heuristic coverage delta analyzer for current branch vs a base branch.
# Goal: For each changed non-test code file, report whether a related test file ALSO changed.
# Outputs JSON array to stdout. Optional --md for a markdown table.
# Cross-platform (macOS/Linux). Dependencies: git, bash. (Optional jq ONLY if you later post-process; not required here.)
# Usage:
#   ./scripts/test-coverage-delta.sh [--base <branch>] [--md]
# Detection Heuristics:
#   - Test file: path contains 'test' segment OR filename matches *_test.* OR starts with test_.
#   - Related test changed: any changed test file whose basename (stripped test_ prefix / _test suffix) matches code file basename.
#   - Missing test delta risk if code adds > 30 lines and no related test changed.
# Limitations: Does NOT parse coverage reports; purely diff + naming heuristics.

set -euo pipefail
BASE="main"
OUTPUT_MD=false

while [ $# -gt 0 ]; do
  case "$1" in
    --base) shift; BASE="${1:-main}" ;;
    --md) OUTPUT_MD=true ;;
    *) echo "[warn] Unknown arg: $1" >&2 ;;
  esac
  shift || true
done

# Auto-detect base via gh if available and base still default
if [ "$BASE" = "main" ] && command -v gh >/dev/null 2>&1; then
  set +e
  detected=$(gh pr view --json baseRefName 2>/dev/null | sed -n 's/.*"baseRefName": *"\(.*\)".*/\1/p')
  set -e
  [ -n "$detected" ] && BASE="$detected"
fi

if git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  git fetch --quiet origin "$BASE" || true
fi

diff_numstat=$(git diff --numstat "$BASE"...HEAD || true)
[ -z "$diff_numstat" ] && { echo '[]'; exit 0; }

# Collect list of changed files (status + names)
changed_files=$(git diff --name-status "$BASE"...HEAD || true)

is_test_file() {
  local p="$1"
  [[ "$p" =~ [Tt]est ]] || [[ "$p" == tests/* ]] || [[ "$p" == test/* ]] || [[ "$p" =~ _test\. ]] || [[ $(basename "$p") == test_* ]]
}

# Build arrays
code_files=""
while IFS=$'\t' read -r adds dels path; do
  [ -z "$path" ] && continue
  status=$(echo "$changed_files" | awk -v p="$path" '$2==p {print $1}' | head -1)
  [ -z "$status" ] && status="M"
  adds=${adds//-/0}; dels=${dels//-/0}
  if ! is_test_file "$path"; then
    case "$path" in
      *.md|docs/*|*.yml|*.yaml|*.json|config/*|*.toml|Dockerfile*|ops/*|infra/*) ;; # skip non-code
      *) code_files+="$path"$'\n' ;;
    esac
  fi
done <<<"$diff_numstat"

# List changed test files for quick matching
changed_test_files=$(echo "$changed_files" | awk '$1 ~ /[ACMDTRU]/ {print $2}' | grep -iE 'test|_test\.|/tests?/|test_' || true)

first=true
json_output="["
md_rows=""
echo "$code_files" | while IFS= read -r f; do
  [ -z "$f" ] && continue
  # Recompute adds/dels/status from diff_numstat (avoid associative arrays)
  adds=$(echo "$diff_numstat" | awk -v p="$f" -F '\t' '$3==p {print $1}' | head -1); adds=${adds//-/0}
  dels=$(echo "$diff_numstat" | awk -v p="$f" -F '\t' '$3==p {print $2}' | head -1); dels=${dels//-/0}
  st=$(echo "$changed_files" | awk -v p="$f" '$2==p {print $1}' | head -1); [ -z "$st" ] && st="M"
  base_name=$(basename "$f")
  core=${base_name%%.*}
  core=${core#test_}
  guess1="test_${base_name}"
  guess2="${core}_test"
  guess3="${core}_test.${base_name#*.}"
  related_changed=false
  while IFS= read -r tf; do
    tbase=$(basename "$tf")
    if [[ "$tbase" == *"$guess2"* ]] || [[ "$tbase" == "$guess1" ]] || [[ "$tbase" == "$guess3" ]]; then
      related_changed=true; break
    fi
  done <<<"$changed_test_files"
  risk_tag=""
  if [ "$related_changed" = false ] && [ "$adds" -gt 30 ]; then risk_tag="missing_test_delta"; fi
  guesses_json="[\"$guess1\",\"$guess2\",\"$guess3\"]"
  risks_json="[]"; [ -n "$risk_tag" ] && risks_json="[\"$risk_tag\"]"
  entry=$(printf '{"file":"%s","adds":%s,"dels":%s,"status":"%s","test_changed":%s,"guessed_tests":%s,"risks":%s}' \
    "$f" "$adds" "$dels" "$st" "$related_changed" "$guesses_json" "$risks_json")
  if ! $first; then json_output+=" ,"; fi
  first=false
  json_output+="$entry"
  md_risks="-"; [ -n "$risk_tag" ] && md_risks="$risk_tag"
  md_rows+="| $f | $adds | $dels | $st | $related_changed | $md_risks |\n"

done
json_output+=']'

echo "$json_output"

if $OUTPUT_MD; then
  echo -e "\n\n## Test Coverage Delta (Base: $BASE)" \
  "\n| File | + | - | Status | Test Changed | Risks |" \
  "\n|------|---|---|--------|--------------|-------|" \
  "\n$md_rows"
fi

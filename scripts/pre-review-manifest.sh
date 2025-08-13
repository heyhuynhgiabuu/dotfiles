#!/usr/bin/env bash
# pre-review-manifest.sh
# Generate a pre-review manifest for a PR: changed files table + simple risk tags.
# Cross-platform (macOS/Linux) and compatible with macOS system bash 3.2 (no associative arrays).
# No external deps beyond: git, awk, sed, grep (prefer rg if present).
# Usage:
#   ./scripts/pre-review-manifest.sh [--json] [BASE_BRANCH]
# If BASE_BRANCH omitted, tries to detect via gh (if installed) else defaults to main.
# --json emits machine readable JSON array (one object per file) to stdout instead of markdown table.

set -euo pipefail

want_json=false
BASE_BRANCH=""
for arg in "$@"; do
  case "$arg" in
    --json) want_json=true ;;
    --help|-h)
      cat <<'H'
pre-review-manifest.sh [--json] [BASE_BRANCH]
Generates Changed Files table (markdown) or JSON array of changed files with +/- line counts, status, type, risk tags.
H
      exit 0 ;;
    *) BASE_BRANCH="$arg" ;;
  esac
done

color_enabled() { [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; }

log() { printf '%s\n' "$*" >&2; }

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
numstat=$(git diff --numstat "$BASE_BRANCH"...HEAD || true)
namestat=$(git diff --name-status "$BASE_BRANCH"...HEAD || true)

if [ -z "$numstat" ]; then
  if $want_json; then echo '[]'; else echo "No changes detected against $BASE_BRANCH"; fi
  exit 0
fi

# Portable structure without associative arrays (macOS bash 3.2 compatible)
# Parallel arrays: paths[], adds[], dels[], status[]
paths=()
adds=()
dels=()
status=()

# Populate from numstat
echo "$numstat" | while IFS=$'\t' read -r add del path; do
  [ -z "$path" ] && continue
  paths+=("$path")
  adds+=("$add")
  dels+=("$del")
  status+=("M") # default status (modified) until overridden
# shellcheck disable=SC2116
done

# Because subshell will isolate arrays if we pipe, re-populate using a here-string instead (above we piped incorrectly)
# Re-do population correctly (keeping original logic succinct)
paths=(); adds=(); dels=(); status=()
while IFS=$'\t' read -r add del path; do
  [ -z "$path" ] && continue
  paths+=("$path")
  adds+=("$add")
  dels+=("$del")
  status+=("M")
done <<<"$numstat"

# Apply name-status mapping (simple: status<TAB>path). Rename lines (Rxxx old new) -> treat as Modified for new path.
while IFS=$'\t' read -r st p1 p2; do
  [ -z "$st" ] && continue
  case "$st" in R* ) # rename: use new path (p2) if present
      if [ -n "${p2:-}" ]; then target="$p2"; else target="$p1"; fi ;;
    *) target="$p1" ;;
  esac
  [ -z "$target" ] && continue
  for i in "${!paths[@]}"; do
    if [ "${paths[$i]}" = "$target" ]; then
      status[$i]="$st"
      break
    fi
  done
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
  if echo "$p" | grep -qiE '(auth|token|secret|crypto)'; then tags+=(security); fi
  if echo "$p" | grep -qiE '(legacy|deprecated|old)'; then tags+=(legacy); fi
  if echo "$p" | grep -qiE '(perf|optimiz)'; then tags+=(performance); fi
  if [ "$(type_for "$p")" = test ]; then tags+=(coverage); fi
  if [ ${#tags[@]} -eq 0 ]; then echo "-"; else printf '%s' "${tags[*]}"; fi
}

# JSON output path
if $want_json; then
  json_lines=()
  for i in "${!paths[@]}"; do
    path="${paths[$i]}"; add="${adds[$i]}"; del="${dels[$i]}"; st="${status[$i]}"; t=$(type_for "$path"); r=$(risk_tags "$path")
    add_json=${add//-/0}; del_json=${del//-/0}
    if [ "$r" = "-" ]; then r_json='[]'; else IFS=' ' read -r -a arr <<<"$r"; tmp=""; for tag in "${arr[@]}"; do tmp+="\"$tag\","; done; r_json="[${tmp%,}]"; fi
    json_lines+=("{\"file\":\"$path\",\"adds\":$add_json,\"dels\":$del_json,\"status\":\"$st\",\"type\":\"$t\",\"risks\":$r_json}")
  done
  # Sort lines lexicographically by file path
  if command -v sort >/dev/null 2>&1; then
    mapfile -t json_lines < <(printf '%s\n' "${json_lines[@]}" | sort)
  fi
  echo '['
  for i in "${!json_lines[@]}"; do
    if [ "$i" -ne 0 ]; then printf ',\n'; fi
    printf '%s' "${json_lines[$i]}"
  done
  echo ']'
  exit 0
fi

# Markdown output
printf '## Changed Files (Base: %s)\n' "$BASE_BRANCH"
printf '| File | + | - | Status | Type | Risk Tags |\n'
printf '|------|---|---|--------|------|-----------|\n'

lines=()
for i in "${!paths[@]}"; do
  path="${paths[$i]}"; add="${adds[$i]}"; del="${dels[$i]}"; st="${status[$i]}"; t=$(type_for "$path"); r=$(risk_tags "$path")
  lines+=("| $path | $add | $del | $st | $t | $r |")
done
if command -v sort >/dev/null 2>&1; then
  mapfile -t lines < <(printf '%s\n' "${lines[@]}" | sort)
fi

# Totals
total_add=0; total_del=0
for i in "${!paths[@]}"; do
  add="${adds[$i]}"; del="${dels[$i]}"
  [ "$add" != "-" ] && total_add=$(( total_add + add )) || true
  [ "$del" != "-" ] && total_del=$(( total_del + del )) || true
  :
done

printf '%s\n' "${lines[@]}"
files_changed=${#paths[@]}
printf '\n**Scope:** %s files changed (+%s / -%s lines) against %s\n' "$files_changed" "$total_add" "$total_del" "$BASE_BRANCH"
printf '**High-Risk Guess:** Files tagged with security or legacy above (manual confirmation needed).\n'
cat <<'NOTE'
> Use this manifest as the basis for the Review Summary & Changed Files table.
> Replace or augment risk tags after inspecting actual diff content.
NOTE

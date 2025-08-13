#!/usr/bin/env bash
# pre-review-manifest.sh
# Generate a pre-review manifest for a PR: changed files table + simple risk tags.
# Cross-platform (macOS/Linux) and compatible with macOS system bash 3.2 (no associative arrays, no mapfile).
# No external deps beyond: git, awk, sed, grep (prefer rg if present). jq optional (only used downstream by other scripts, not here).
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

log() { printf '%s\n' "$*" >&2; }

if [ -z "$BASE_BRANCH" ]; then
  if command -v gh >/dev/null 2>&1; then
    set +e
    detected=$(gh pr view --json baseRefName 2>/dev/null | sed -n 's/.*"baseRefName": *"\(.*\)".*/\1/p')
    set -e
    [ -n "$detected" ] && BASE_BRANCH="$detected"
  fi
fi
[ -z "$BASE_BRANCH" ] && BASE_BRANCH="main" && log "[info] Falling back to base branch: main"

# Ensure we have the latest base branch refs (best effort)
if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  git fetch --quiet origin "$BASE_BRANCH" || true
fi

# Collect diff stats (range three-dot to include merge base)
numstat=$(git diff --numstat "$BASE_BRANCH"...HEAD || true)
namestat=$(git diff --name-status "$BASE_BRANCH"...HEAD || true)

if [ -z "$numstat" ]; then
  if $want_json; then echo '[]'; else echo "No changes detected against $BASE_BRANCH"; fi
  exit 0
fi

# Parallel arrays (bash 3 compatible)
paths=(); adds=(); dels=(); status=()
while IFS=$'\t' read -r add del path; do
  [ -z "$path" ] && continue
  paths+=("$path")
  adds+=("$add")
  dels+=("$del")
  status+=("M")
done <<<"$numstat"

# Apply name-status mapping (handle rename lines: Rxx<tab>old<tab>new)
while IFS=$'\t' read -r st p1 p2; do
  [ -z "$st" ] && continue
  case "$st" in R*) target=${p2:-$p1} ;; *) target="$p1" ;; esac
  [ -z "$target" ] && continue
  # Update status for matching path
  i=0
  while [ $i -lt ${#paths[@]} ]; do
    if [ "${paths[$i]}" = "$target" ]; then
      status[$i]="$st"
      break
    fi
    i=$(( i + 1 ))
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
  local p="$1" out=""
  echo "$p" | grep -qiE '(auth|token|secret|crypto)' && out="${out}security "
  echo "$p" | grep -qiE '(legacy|deprecated|old)' && out="${out}legacy "
  echo "$p" | grep -qiE '(perf|optimiz)' && out="${out}performance "
  [ "$(type_for "$p")" = test ] && out="${out}coverage "
  out=${out% } # trim
  [ -z "$out" ] && echo '-' || echo "$out"
}

if $want_json; then
  # Build unsorted lines
  json_tmp=""
  i=0
  while [ $i -lt ${#paths[@]} ]; do
    path="${paths[$i]}"; add="${adds[$i]}"; del="${dels[$i]}"; st="${status[$i]}"; t=$(type_for "$path"); r=$(risk_tags "$path")
    add_json=${add//-/0}; del_json=${del//-/0}
    if [ "$r" = '-' ]; then r_json='[]'; else
      # space separated tags -> JSON array
      r_json='['
      first_tag=true
      for tag in $r; do
        $first_tag || r_json+="$IFS"
        r_json+="\"$tag\","; first_tag=false
      done
      r_json=${r_json%,}
      r_json+=']'
    fi
    json_tmp+="{\"file\":\"$path\",\"adds\":$add_json,\"dels\":$del_json,\"status\":\"$st\",\"type\":\"$t\",\"risks\":$r_json}"$'\n'
    i=$(( i + 1 ))
  done
  # Sort and emit with commas
  if command -v sort >/dev/null 2>&1; then
    json_sorted=$(printf '%s' "$json_tmp" | sed '/^$/d' | sort)
  else
    json_sorted=$(printf '%s' "$json_tmp" | sed '/^$/d')
  fi
  echo '['
  first_line=true
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    if ! $first_line; then printf ',\n'; fi
    first_line=false
    printf '%s' "$line"
  done <<<"$json_sorted"
  echo ']'
  exit 0
fi

# Markdown table header
printf '## Changed Files (Base: %s)\n' "$BASE_BRANCH"
printf '| File | + | - | Status | Type | Risk Tags |\n'
printf '|------|---|---|--------|------|-----------|\n'

# Build lines
md_tmp=""
i=0
while [ $i -lt ${#paths[@]} ]; do
  path="${paths[$i]}"; add="${adds[$i]}"; del="${dels[$i]}"; st="${status[$i]}"; t=$(type_for "$path"); r=$(risk_tags "$path")
  md_tmp+="| $path | $add | $del | $st | $t | $r |"$'\n'
  i=$(( i + 1 ))
done
if command -v sort >/dev/null 2>&1; then
  md_sorted=$(printf '%s' "$md_tmp" | sed '/^$/d' | sort)
else
  md_sorted=$(printf '%s' "$md_tmp" | sed '/^$/d')
fi
printf '%s\n' "$md_sorted"

# Totals
files_changed=${#paths[@]}
# Sum additions/deletions (treat '-' as 0)
total_add=0; total_del=0
for val in "${adds[@]}"; do [ "$val" != '-' ] && total_add=$(( total_add + val )) || true; done
for val in "${dels[@]}"; do [ "$val" != '-' ] && total_del=$(( total_del + val )) || true; done

printf '\n**Scope:** %s files changed (+%s / -%s lines) against %s\n' "$files_changed" "$total_add" "$total_del" "$BASE_BRANCH"
printf '**High-Risk Guess:** Files tagged with security or legacy above (manual confirmation needed).\n'
cat <<'NOTE'
> Use this manifest as the basis for the Review Summary & Changed Files table.
> Replace or augment risk tags after inspecting actual diff content.
NOTE

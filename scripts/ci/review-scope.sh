#!/usr/bin/env bash
# review-scope.sh
# Consolidate multiple review automation outputs into a single directory (default: ./review_artifacts)
# Generates:
#  - manifest.json / manifest.md
#  - risk.json / risk.md
#  - coverage.json / coverage.md
#  - hotspots.json / hotspots.md
# And an index.md summarizing key counts & high-risk candidates. Builds combined all.json unified schema (versioned) with normalized tags.
# Usage:
#   ./scripts/ci/review-scope.sh [--base <branch>] [--out <dir>] [--no-md] [--strict]
# Flags:
#   --no-md   Suppress markdown (.md) generation
#   --strict  Exit non-zero if gating risks detected (security, large_change, missing_test_delta, hotspot)
# Requirements: the sibling scripts (pre-review-manifest.sh, diff-risk-classifier.sh,
#               test-coverage-delta.sh, legacy-hotspot-detector.sh) present & executable.
# Cross-platform (macOS/Linux).

set -euo pipefail
BASE="main"; OUT_DIR="review_artifacts"; GEN_MD=true; STRICT=false
while [ $# -gt 0 ]; do
  case "$1" in
    --base) shift; BASE="${1:-main}" ;;
    --out) shift; OUT_DIR="${1:-review_artifacts}" ;;
    --strict) STRICT=true ;;
    --no-md) GEN_MD=false ;;
    *) echo "[warn] Unknown arg: $1" >&2 ;;
  esac; shift || true
done

scripts=(pre-review-manifest.sh diff-risk-classifier.sh test-coverage-delta.sh legacy-hotspot-detector.sh) # all must be executable
for s in "${scripts[@]}"; do
  [ -x "scripts/ci/$s" ] || { echo "[error] scripts/ci/$s not found or not executable" >&2; exit 1; }
done

mkdir -p "$OUT_DIR"

# Manifest
./scripts/ci/pre-review-manifest.sh --json "$BASE" > "$OUT_DIR/manifest.json"
$GEN_MD && ./scripts/ci/pre-review-manifest.sh "$BASE" > "$OUT_DIR/manifest.md"

# Risk
./scripts/ci/diff-risk-classifier.sh --base "$BASE" > "$OUT_DIR/risk.json"
$GEN_MD && ./scripts/ci/diff-risk-classifier.sh --base "$BASE" --md > "$OUT_DIR/risk.md"

# Coverage delta
./scripts/ci/test-coverage-delta.sh --base "$BASE" > "$OUT_DIR/coverage.json"
$GEN_MD && ./scripts/ci/test-coverage-delta.sh --base "$BASE" --md > "$OUT_DIR/coverage.md"

# Hotspots
./scripts/ci/legacy-hotspot-detector.sh --base "$BASE" > "$OUT_DIR/hotspots.json"
$GEN_MD && ./scripts/ci/legacy-hotspot-detector.sh --base "$BASE" --md > "$OUT_DIR/hotspots.md"

# Normalize & build index.md summary (markdown) + combined all.json (version 1)
# Normalization helper
normalize_tag() {
  case "$1" in
    large-change|large-addition|large_diff) echo large_change ;;
    high-churn) echo high_churn ;;
    missing-test-delta|no-test-delta) echo missing_test_delta ;;
    perf|perf*|performance) echo performance ;;
    high-concentration) echo high_concentration ;;
    *) echo "$1" ;;
  esac
}

if $GEN_MD; then
  manifest_count=$(jq 'length' "$OUT_DIR/manifest.json" 2>/dev/null || echo 0)
  risk_security=$(jq '[.[] | select(.risks!=null) | .risks[]] | map(select(.=="security")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  risk_large=$(jq '[.[] | .risks[]?] | map(select(.=="large_change")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  coverage_missing=$(jq '[.[] | select(.risks[]? == "missing_test_delta")] | length' "$OUT_DIR/coverage.json" 2>/dev/null || echo 0)
  hotspots_count=$(jq 'length' "$OUT_DIR/hotspots.json" 2>/dev/null || echo 0)
  cat > "$OUT_DIR/index.md" <<EOF
# Review Scope Index (Base: $BASE)

**Files Changed:** $manifest_count  
**Security Risk Tags:** $risk_security  
**Large Change Tags:** $risk_large  
**Missing Test Deltas:** $coverage_missing  
**Legacy Hotspots (score>=2):** $hotspots_count  

## Recommended Review Order
1. Legacy Hotspots (hotspots.md)
2. Security / Large Changes (risk.md)
3. Missing Test Deltas (coverage.md)
4. Remaining Files (manifest.md)

## Quick Guidance
- Confirm large additions have proportional test updates.
- Examine hotspots with markers or high churn for refactor backlog.
- Address security-tagged paths before merge.
- Convert persistent gaps into actionable follow-up tasks (writer + legacy agents).
EOF
fi

# Build combined all.json (requires jq)
if command -v jq >/dev/null 2>&1; then
  # Manifest is array of objects: file, adds, dels, status, type, risks
  # Risk JSON: similar structure
  # Coverage JSON: file,test_changed,risks
  # Hotspots JSON: heuristics list
  version=1
  generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  # Load arrays
  manifest=$(cat "$OUT_DIR/manifest.json" 2>/dev/null || echo '[]')
  risk=$(cat "$OUT_DIR/risk.json" 2>/dev/null || echo '[]')
  coverage=$(cat "$OUT_DIR/coverage.json" 2>/dev/null || echo '[]')
  hotspots=$(cat "$OUT_DIR/hotspots.json" 2>/dev/null || echo '[]')
  # Assemble per-file map using jq
  all_json=$(jq -n \
    --argjson manifest "$manifest" \
    --argjson risk "$risk" \
    --argjson coverage "$coverage" \
    --argjson hotspots "$hotspots" \
    --arg version "$version" \
    --arg generated_at "$generated_at" '
    def normtags(ts): [ (ts // [])[] | . as $t | $t ];
    # Build empty object
    {version:$version, generated_at:$generated_at, files:{}} as $root
    | reduce $manifest[] as $m ($root; .files[$m.file].manifest = $m)
    | reduce $risk[] as $r (. ; .files[$r.file].risk = {tags: ($r.risks // [])})
    | reduce $coverage[] as $c (. ; .files[$c.file].coverage = {adds:$c.adds,dels:$c.dels,status:$c.status,test_changed:$c.test_changed,risks:($c.risks // [])})
    | reduce $hotspots[] as $h (. ; .files[$h.file].hotspot = {heuristics:($h.heuristics // []), score:$h.score})
    | .summary = (
        { file_count: (.files|keys|length),
          risk_tag_counts: ([.files[].risk.tags[]?] | group_by(.) | map({(.[0]):length}) | add // {}),
          hotspots: [ keys[] as $k | select(.files[$k].hotspot.score? >= 2) | $k ],
          missing_test_delta_files: [ keys[] as $k | select((.files[$k].coverage.risks[]? | contains("missing_test_delta"))) | $k ]
        })
  ')
  # Normalize tags (shell side) by rewriting tag arrays
  tmp=$(mktemp)
  echo "$all_json" > "$tmp"
  # (Optional normalization pass left simple since upstream scripts already normalized.)
  mv "$tmp" "$OUT_DIR/all.json"
else
  echo "[warn] jq not found; skipping combined all.json" >&2
fi

echo "[info] Review artifacts written to $OUT_DIR" >&2

if $STRICT; then
  # Gating modes:
  # - Default (security-only): fail only if security_count > 0
  # - Full strict (REVIEW_SCOPE_STRICT=true): fail if ANY risk category present (original behavior)
  security_count=$(jq '[.[] | .risks[]?] | map(select(.=="security")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  large_count=$(jq '[.[] | .risks[]?] | map(select(.=="large_change")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  missing_count=$(jq '[.[] | select(.risks[]? == "missing_test_delta")] | length' "$OUT_DIR/coverage.json" 2>/dev/null || echo 0)
  hotspot_count=$(jq 'length' "$OUT_DIR/hotspots.json" 2>/dev/null || echo 0)
  full_strict=${REVIEW_SCOPE_STRICT:-false}
  if [ "$full_strict" = "true" ]; then
    total=$(( security_count + large_count + missing_count + hotspot_count ))
    if [ $total -gt 0 ]; then
      echo "[strict][full] Failing (full strict) due to risks: security=$security_count large_change=$large_count missing_test_delta=$missing_count hotspots=$hotspot_count" >&2
      exit 2
    else
      echo "[strict][full] No gating risks detected; passing." >&2
    fi
  else
    if [ $security_count -gt 0 ]; then
      echo "[strict][security-only] Failing due to security risks: security=$security_count" >&2
      exit 2
    else
      echo "[strict][security-only] No security risks detected; passing." >&2
    fi
  fi
fi

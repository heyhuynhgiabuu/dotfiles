#!/usr/bin/env bash
# review-scope.sh
# Consolidate multiple review automation outputs into a single directory (default: ./review_artifacts)
# Generates:
#  - manifest.json / manifest.md
#  - risk.json / risk.md
#  - coverage.json / coverage.md
#  - hotspots.json / hotspots.md
# And an index.md summarizing key counts & high-risk candidates.
# Usage:
#   ./scripts/review-scope.sh [--base <branch>] [--out <dir>] [--no-md]
# Requirements: the sibling scripts (pre-review-manifest.sh, diff-risk-classifier.sh,
#               test-coverage-delta.sh, legacy-hotspot-detector.sh) present & executable.
# Cross-platform (macOS/Linux).

set -euo pipefail
BASE="main"; OUT_DIR="review_artifacts"; GEN_MD=true
while [ $# -gt 0 ]; do
  case "$1" in
    --base) shift; BASE="${1:-main}" ;;
    --out) shift; OUT_DIR="${1:-review_artifacts}" ;;
    --no-md) GEN_MD=false ;;
    *) echo "[warn] Unknown arg: $1" >&2 ;;
  esac; shift || true
done

scripts=(pre-review-manifest.sh diff-risk-classifier.sh test-coverage-delta.sh legacy-hotspot-detector.sh)
for s in "${scripts[@]}"; do
  [ -x "scripts/$s" ] || { echo "[error] scripts/$s not found or not executable" >&2; exit 1; }
done

mkdir -p "$OUT_DIR"

# Manifest
./scripts/pre-review-manifest.sh --json "$BASE" > "$OUT_DIR/manifest.json"
$GEN_MD && ./scripts/pre-review-manifest.sh "$BASE" > "$OUT_DIR/manifest.md"

# Risk
./scripts/diff-risk-classifier.sh --base "$BASE" > "$OUT_DIR/risk.json"
$GEN_MD && ./scripts/diff-risk-classifier.sh --base "$BASE" --md > "$OUT_DIR/risk.md"

# Coverage delta
./scripts/test-coverage-delta.sh --base "$BASE" > "$OUT_DIR/coverage.json"
$GEN_MD && ./scripts/test-coverage-delta.sh --base "$BASE" --md > "$OUT_DIR/coverage.md"

# Hotspots
./scripts/legacy-hotspot-detector.sh --base "$BASE" > "$OUT_DIR/hotspots.json"
$GEN_MD && ./scripts/legacy-hotspot-detector.sh --base "$BASE" --md > "$OUT_DIR/hotspots.md"

# Build index.md summary (markdown)
if $GEN_MD; then
  manifest_count=$(jq 'length' "$OUT_DIR/manifest.json" 2>/dev/null || echo 0)
  risk_security=$(jq '[.[] | select(.risks!=null) | .risks[]] | map(select(.=="security")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  risk_large=$(jq '[.[] | .risks[]?] | map(select(.=="large-change")) | length' "$OUT_DIR/risk.json" 2>/dev/null || echo 0)
  coverage_missing=$(jq '[.[] | select(.risks[]? == "missing-test-delta")] | length' "$OUT_DIR/coverage.json" 2>/dev/null || echo 0)
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

echo "[info] Review artifacts written to $OUT_DIR" >&2

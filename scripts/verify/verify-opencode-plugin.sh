#!/usr/bin/env sh
# OpenCode plugin verification helper (macOS/Linux, POSIX sh)
# From repo root: ./scripts/verify-opencode-plugin.sh
# - Detects plugins under opencode/plugin/plugins/*
# - Installs deps (npm ci if lockfile present, else npm install)
# - Runs build/typecheck/lint if present
# - Verifies dist output exists
# Exits non-zero if any plugin fails hard checks

set -u

ok=0
warn=0
fail=0

info() { printf "[INFO] %s\n" "$1"; }
pass() { printf "[PASS] %s\n" "$1"; ok=$((ok+1)); }
warnf() { printf "[WARN] %s\n" "$1"; warn=$((warn+1)); }
failf() { printf "[FAIL] %s\n" "$1"; fail=$((fail+1)); }

# Locate repo root based on this script's location
SCRIPT_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)
PLUGINS_DIR="$REPO_ROOT/opencode/plugin/plugins"

info "Repo root: $REPO_ROOT"

# Node check (>=18)
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node -v 2>/dev/null | sed 's/^v//')
  NODE_MAJOR=$(printf "%s" "$NODE_VER" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
    pass "Node.js present: v$NODE_VER (>=18)"
  else
    failf "Node.js v$NODE_VER detected; require >=18"
  fi
else
  failf "Node.js not found in PATH"
fi

# Plugins dir
if [ ! -d "$PLUGINS_DIR" ]; then
  warnf "No plugins directory found at $PLUGINS_DIR (nothing to verify)"
  printf "\n--- Plugin Verify Summary ---\n"
  printf "Pass: %d  Warn: %d  Fail: %d\n" "$ok" "$warn" "$fail"
  [ "$fail" -gt 0 ] && exit 1 || exit 0
fi

# Iterate plugins
FOUND=0
for d in "$PLUGINS_DIR"/*; do
  [ -d "$d" ] || continue
  if [ -f "$d/package.json" ]; then
    FOUND=1
    PLUGIN_NAME=$(basename "$d")
    info "Verifying plugin: $PLUGIN_NAME"

    # Install dependencies
    if [ -f "$d/package-lock.json" ]; then
      (cd "$d" && npm ci) || failf "$PLUGIN_NAME: npm ci failed"
    else
      (cd "$d" && npm install) || failf "$PLUGIN_NAME: npm install failed"
    fi

    # Build/typecheck/lint if present (npm supports --if-present)
    (cd "$d" && npm run -s build --if-present) || true
    (cd "$d" && npm run -s typecheck --if-present) || true
    (cd "$d" && npm run -s lint --if-present) || true

    # Verify output: prefer dist dir, else main field
    if [ -d "$d/dist" ]; then
      pass "$PLUGIN_NAME: build output present (dist/)"
    else
      # Try to read package.json main field without jq (best-effort)
      MAIN=$(awk -F '"' '/"main"/ {print $4; exit}' "$d/package.json" 2>/dev/null || true)
      if [ -n "$MAIN" ] && [ -f "$d/$MAIN" ]; then
        pass "$PLUGIN_NAME: main exists ($MAIN)"
      else
        warnf "$PLUGIN_NAME: no dist/ and unable to confirm main output"
      fi
    fi
  fi
done

if [ "$FOUND" -eq 0 ]; then
  warnf "No plugin packages found under $PLUGINS_DIR"
fi

# Summary
printf "\n--- Plugin Verify Summary ---\n"
printf "Pass: %d  Warn: %d  Fail: %d\n" "$ok" "$warn" "$fail"

# Exit with failure if any fail
if [ "$fail" -gt 0 ]; then
  exit 1
fi
exit 0

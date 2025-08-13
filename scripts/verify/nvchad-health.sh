#!/usr/bin/env sh
# Cross-platform NvChad health check (macOS/Linux, POSIX sh)
# Verifies: nvim present, NvChad base exists, custom symlink wiring, and Lazy present.
# Usage: ./scripts/nvchad-health.sh

set -u

ok=0
warn=0
fail=0

info() { printf "[INFO] %s\n" "$1"; }
pass() { printf "[PASS] %s\n" "$1"; ok=$((ok+1)); }
warnf() { printf "[WARN] %s\n" "$1"; warn=$((warn+1)); }
failf() { printf "[FAIL] %s\n" "$1"; fail=$((fail+1)); }

# Discover repo root from script location
SCRIPT_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)
CUSTOM_DIR_REPO="$REPO_ROOT/nvim/.config/nvim/lua/custom"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
CUSTOM_LINK="$NVIM_CONFIG_DIR/lua/custom"
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"

info "Repo root detected: $REPO_ROOT"

# 1) Neovim availability
if command -v nvim >/dev/null 2>&1; then
  NVIM_VER=$(nvim --version | awk 'NR==1{print $0}')
  pass "Neovim present: $NVIM_VER"
else
  failf "Neovim not found in PATH. Install Neovim and retry."
fi

# 2) NvChad base presence (~/.config/nvim)
if [ -d "$NVIM_CONFIG_DIR" ]; then
  pass "Found Neovim config directory: $NVIM_CONFIG_DIR"
else
  warnf "Neovim config directory not found: $NVIM_CONFIG_DIR (run install script)"
fi

# 3) Custom directory in repo exists
if [ -d "$CUSTOM_DIR_REPO" ]; then
  pass "Custom config exists in repo: $CUSTOM_DIR_REPO"
else
  failf "Missing repo custom config directory: $CUSTOM_DIR_REPO"
fi

# 4) Symlink wiring: ~/.config/nvim/lua/custom -> repo custom dir
if [ -L "$CUSTOM_LINK" ] || [ -d "$CUSTOM_LINK" ]; then
  # Resolve physical path of the link/dir by cd'ing into it
  RESOLVED=""
  if RESOLVED=$(cd "$CUSTOM_LINK" 2>/dev/null && pwd -P); then
    case "$RESOLVED" in
      "$CUSTOM_DIR_REPO"|"$CUSTOM_DIR_REPO"/*)
        pass "Custom link resolves to repo custom dir: $RESOLVED"
        ;;
      *)
        warnf "Custom resolves to different path: $RESOLVED (expected under $CUSTOM_DIR_REPO)"
        ;;
    esac
  else
    failf "Unable to access $CUSTOM_LINK; check permissions or existence."
  fi
else
  warnf "Custom link/directory not found at: $CUSTOM_LINK (install script creates symlink)"
fi

# 5) Lazy plugin manager presence (best-effort)
if [ -d "$LAZY_DIR" ]; then
  pass "Lazy.nvim detected at: $LAZY_DIR"
else
  warnf "Lazy.nvim not found at: $LAZY_DIR (first Neovim run will install plugins)"
fi

# Summary
printf "\n--- NvChad Health Summary ---\n"
printf "Pass: %d  Warn: %d  Fail: %d\n" "$ok" "$warn" "$fail"

# Exit non-zero if any hard failures
if [ "$fail" -gt 0 ]; then
  exit 1
fi
exit 0

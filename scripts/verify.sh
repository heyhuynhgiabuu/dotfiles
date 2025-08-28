#!/usr/bin/env sh
# Dotfiles verification script - cross-platform (macOS & Linux)
# Verifies essential dotfiles configurations and tools
# Usage: ./scripts/verify.sh [--nvim-only|--opencode-check]

set -u

# Security check - do not run as root
if [ "$(id -u)" -eq 0 ]; then
    printf "[FAIL] Security Error: This script should not be run as root\n"
    printf "[FAIL] Running dotfiles verification as root can create security vulnerabilities\n"
    printf "[FAIL] Please run as a regular user instead\n"
    exit 1
fi

# Counters
ok=0
warn=0
fail=0

# Logging functions
info() { printf "[INFO] %s\n" "$1"; }
pass() { printf "[PASS] %s\n" "$1"; ok=$((ok+1)); }
warnf() { printf "[WARN] %s\n" "$1"; warn=$((warn+1)); }
failf() { printf "[FAIL] %s\n" "$1"; fail=$((fail+1)); }

# Discover repo root from script location
SCRIPT_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
REPO_ROOT=$(dirname "$SCRIPT_DIR")

# Configuration paths
CUSTOM_DIR_REPO="$REPO_ROOT/nvim/.config/nvim/lua/custom"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
CUSTOM_LINK="$NVIM_CONFIG_DIR/lua/custom"
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"

info "Dotfiles verification starting..."
info "Repo root: $REPO_ROOT"

# Parse arguments
NVIM_ONLY=0
OPENCODE_CHECK=0
case "${1:-}" in
    "--nvim-only") NVIM_ONLY=1 ;;
    "--opencode-check") OPENCODE_CHECK=1 ;;
    "") ;; # No args is fine
    *) 
        printf "Usage: %s [--nvim-only|--opencode-check]\n" "$0"
        exit 1
        ;;
esac

# Core dotfiles verification
if [ "$NVIM_ONLY" -eq 0 ]; then
    info "==> Checking core dotfiles..."
    
    # GNU Stow
    if command -v stow >/dev/null 2>&1; then
        pass "GNU Stow is available"
    else
        failf "GNU Stow not found - required for symlink management"
    fi
    
    # Essential configs exist
    for config in zsh tmux nvim; do
        if [ -d "$REPO_ROOT/$config" ]; then
            pass "Configuration directory exists: $config"
        else
            failf "Missing configuration directory: $config"
        fi
    done
    
    # Symlinks are working
    if [ -L "$HOME/.zshrc" ] && [ -f "$HOME/.zshrc" ]; then
        pass "Zsh configuration symlinked"
    else
        warnf "Zsh configuration not symlinked (run setup script)"
    fi
    
    if [ -L "$HOME/.tmux.conf" ] && [ -f "$HOME/.tmux.conf" ]; then
        pass "Tmux configuration symlinked"
    else
        warnf "Tmux configuration not symlinked (run setup script)"
    fi
fi

# NvChad specific verification
info "==> Checking NvChad configuration..."

# Neovim availability
if command -v nvim >/dev/null 2>&1; then
    NVIM_VER=$(nvim --version | awk 'NR==1{print $0}')
    pass "Neovim present: $NVIM_VER"
else
    failf "Neovim not found in PATH"
fi

# NvChad base presence
if [ -d "$NVIM_CONFIG_DIR" ]; then
    pass "Neovim config directory exists: $NVIM_CONFIG_DIR"
else
    warnf "Neovim config directory not found (run setup script)"
fi

# Custom directory in repo
if [ -d "$CUSTOM_DIR_REPO" ]; then
    pass "Custom config exists in repo: $CUSTOM_DIR_REPO"
else
    failf "Missing repo custom config directory: $CUSTOM_DIR_REPO"
fi

# Symlink verification
if [ -L "$CUSTOM_LINK" ] || [ -d "$CUSTOM_LINK" ]; then
    RESOLVED=""
    if RESOLVED=$(cd "$CUSTOM_LINK" 2>/dev/null && pwd -P); then
        case "$RESOLVED" in
            "$CUSTOM_DIR_REPO"|"$CUSTOM_DIR_REPO"/*)
                pass "Custom config properly symlinked: $RESOLVED"
                ;;
            *)
                warnf "Custom config points to wrong path: $RESOLVED"
                ;;
        esac
    else
        failf "Cannot access custom config link: $CUSTOM_LINK"
    fi
else
    warnf "Custom config not symlinked (run setup script)"
fi

# Lazy plugin manager
if [ -d "$LAZY_DIR" ]; then
    pass "Lazy.nvim plugin manager detected"
else
    warnf "Lazy.nvim not found (first nvim run will install)"
fi

# OpenCode workflow verification
check_opencode_workflow() {
    info "==> Checking OpenCode workflow..."
    
    # Check prompt length optimization
    if [ -f "$REPO_ROOT/opencode/prompts/beta.md" ]; then
        lines=$(wc -l < "$REPO_ROOT/opencode/prompts/beta.md")
        if [ "$lines" -le 180 ]; then
            pass "Beta prompt length optimized: $lines lines"
        else
            warnf "Beta prompt length: $lines lines (recommend <180)"
        fi
    else
        warnf "Beta prompt not found: $REPO_ROOT/opencode/prompts/beta.md"
    fi
    
    # Check for planning artifacts
    if [ -f "$REPO_ROOT/opencode/workflow/planning-template.md" ]; then
        pass "Planning template available"
    else
        warnf "Planning template missing - create opencode/workflow/planning-template.md"
    fi
    
    # Check for verification requirements
    if [ -f "$REPO_ROOT/opencode/AGENTS.md" ] && grep -q "Manual verification" "$REPO_ROOT/opencode/AGENTS.md" 2>/dev/null; then
        pass "Manual verification enforced"
    else
        warnf "Manual verification policy missing from AGENTS.md"
    fi
    
    # Scan for integration test discipline
    if find "$REPO_ROOT" -name "*.md" -exec grep -l "MOCK-ONLY" {} \; 2>/dev/null | head -1 >/dev/null; then
        pass "Mock-only test labeling implemented"
    else
        warnf "Consider implementing MOCK-ONLY test risk labeling"
    fi
    
    # Check for secrets in planning artifacts (security scan)
    secrets_found=0
    if [ -d "$REPO_ROOT/opencode" ]; then
        # Look for actual secret patterns like key="value" or password='value'
        secret_files=$(find "$REPO_ROOT/opencode" -name "*.md" -exec grep -l -E "(password|api[_-]?key|token)\s*[:=]\s*['\"][^'\"]{8,}" {} \; 2>/dev/null | head -5)
        if [ -n "$secret_files" ]; then
            failf "Potential hardcoded secrets found in OpenCode artifacts:"
            printf "%s\n" "$secret_files"
            secrets_found=1
        fi
    fi
    
    if [ "$secrets_found" -eq 0 ]; then
        pass "No hardcoded secrets detected in OpenCode files"
    fi
    
    # Check OpenCode configuration
    if [ -f "$REPO_ROOT/opencode/opencode.json" ]; then
        pass "OpenCode configuration found"
        
        # Check for beta agent configuration
        if grep -q '"beta"' "$REPO_ROOT/opencode/opencode.json" 2>/dev/null; then
            pass "Beta agent configured"
        else
            warnf "Beta agent not found in opencode.json"
        fi
    else
        warnf "OpenCode configuration not found: opencode/opencode.json"
    fi
    
    # Check workflow directory structure
    if [ -d "$REPO_ROOT/opencode/workflow" ]; then
        pass "OpenCode workflow directory exists"
    else
        warnf "OpenCode workflow directory missing"
    fi
    
    # Check command directory structure  
    if [ -d "$REPO_ROOT/opencode/command" ]; then
        pass "OpenCode command directory exists"
    else
        warnf "OpenCode command directory missing"
    fi
}

# Run OpenCode checks if requested or if not nvim-only
if [ "$OPENCODE_CHECK" -eq 1 ] || [ "$NVIM_ONLY" -eq 0 ]; then
    check_opencode_workflow
fi

# Summary
printf "\n=== Verification Summary ===\n"
printf "Pass: %d  Warn: %d  Fail: %d\n" "$ok" "$warn" "$fail"

if [ "$fail" -gt 0 ]; then
    printf "\nRun setup script to fix failures: ./scripts/setup.sh\n"
    exit 1
elif [ "$warn" -gt 0 ]; then
    printf "\nWarnings detected - some features may not work optimally\n"
    exit 0
else
    printf "\nAll checks passed! ✅\n"
    exit 0
fi
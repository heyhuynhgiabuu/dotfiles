# Cached Integration Initializations
# Regenerate cache: rm ~/.zsh/cache/* && source ~/.zshrc

CACHE_DIR="$HOME/.zsh/cache"
mkdir -p "$CACHE_DIR"

# Cache Starship init (instead of eval on every startup)
STARSHIP_CACHE="$CACHE_DIR/starship.zsh"
if [[ ! -f "$STARSHIP_CACHE" ]] || [[ "$(command -v starship)" -nt "$STARSHIP_CACHE" ]]; then
    starship init zsh > "$STARSHIP_CACHE" 2>/dev/null
fi
[[ -f "$STARSHIP_CACHE" ]] && source "$STARSHIP_CACHE"

# Cache Zoxide init
ZOXIDE_CACHE="$CACHE_DIR/zoxide.zsh"
if command -v zoxide >/dev/null; then
    if [[ ! -f "$ZOXIDE_CACHE" ]] || [[ "$(command -v zoxide)" -nt "$ZOXIDE_CACHE" ]]; then
        zoxide init zsh > "$ZOXIDE_CACHE" 2>/dev/null
    fi
    [[ -f "$ZOXIDE_CACHE" ]] && source "$ZOXIDE_CACHE"
fi

# Cache GitHub Copilot CLI (if installed)
COPILOT_CACHE="$CACHE_DIR/copilot.zsh"
if command -v github-copilot-cli >/dev/null; then
    if [[ ! -f "$COPILOT_CACHE" ]] || [[ "$(command -v github-copilot-cli)" -nt "$COPILOT_CACHE" ]]; then
        github-copilot-cli alias -- "$0" > "$COPILOT_CACHE" 2>/dev/null
    fi
    [[ -f "$COPILOT_CACHE" ]] && source "$COPILOT_CACHE"
fi

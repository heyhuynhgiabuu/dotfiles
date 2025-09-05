# ZSH Configuration - Modular & Performance Optimized
# Stripped from 325 lines of bloat to essential functionality

# Core configuration
export ZSH_CONFIG_DIR="$HOME/.zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
export PAGER=less
export LESS=-R

# Load performance optimizations first
[[ -f "$ZSH_CONFIG_DIR/performance.zsh" ]] && source "$ZSH_CONFIG_DIR/performance.zsh"

# Essential zsh options
setopt prompt_subst
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
setopt extended_history

# Load modular configurations
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/envs.zsh" ]] && source "$ZSH_CONFIG_DIR/envs.zsh"

# Prompt setup
[[ -f "$ZSH_CONFIG_DIR/starship.zsh" ]] && source "$ZSH_CONFIG_DIR/starship.zsh"
export STARSHIP_CONFIG="$ZSH_CONFIG_DIR/starship.toml"
eval "$(starship init zsh)"

# Oh-my-zsh (minimal setup)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using Starship instead
plugins=(brew dotenv)
source $ZSH/oh-my-zsh.sh

# Zinit (if available)
if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
    
    # Essential zinit plugins
    zinit light-mode for \
        zdharma-continuum/zinit-annex-as-monitor \
        zdharma-continuum/zinit-annex-bin-gem-node
    
    # Lazy-loaded completions and tools
    zinit wait'1' lucid for \
        OMZP::golang \
        OMZP::docker \
        OMZP::kubectl \
        OMZP::git \
        atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
            zdharma-continuum/fast-syntax-highlighting \
        blockf \
            zsh-users/zsh-completions \
        atload"!_zsh_autosuggest_start" \
            zsh-users/zsh-autosuggestions
else
    printf "\033[33mWarning: zinit not found. Run 'scripts/setup/install-zinit.sh'\033[0m\n" >&2
fi

# Load remaining modules
[[ -f "$ZSH_CONFIG_DIR/completions.zsh" ]] && source "$ZSH_CONFIG_DIR/completions.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"
[[ -f "$ZSH_CONFIG_DIR/integrations.zsh" ]] && source "$ZSH_CONFIG_DIR/integrations.zsh"

# Local environment file (if exists)
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/84/"

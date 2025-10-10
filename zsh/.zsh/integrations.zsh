# Tool Integrations & Lazy Loading
# All external tool integrations in one place

# Platform detection (import from paths.zsh)
PLATFORM="${PLATFORM:-$(detect_platform)}"

## NVM - Load immediately for consistent Node access
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Auto-load default Node version (creates .nvmrc support)
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Load default version or use latest LTS
    nvm use default --silent 2>/dev/null || nvm use --lts --silent 2>/dev/null
fi

## SDKMAN - LAZY loading (only when 'sdk' command is used)
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
    unset -f sdk
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
}

## Zoxide - Loaded via cache-integrations.zsh (no eval here)

## TheFuck - Lazy loading
fuck() {
    unset -f fuck
    command -v thefuck >/dev/null && {
        eval "$(thefuck --alias)"
        eval "$(thefuck --alias fk)"
    }
    fuck "$@"
}

fk() {
    unset -f fk
    command -v thefuck >/dev/null && {
        eval "$(thefuck --alias)"
        eval "$(thefuck --alias fk)"
    }
    fk "$@"
}

## Herd PHP (macOS only)
if [[ "$PLATFORM" == "macos" ]]; then
    export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
    export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
    export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
    export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"
fi

## Conda - LAZY loading (only when 'conda' command is used)
if [[ -d "$HOME/miniconda3" ]]; then
    # Add to PATH immediately, but defer conda initialization
    export PATH="$HOME/miniconda3/bin:$PATH"
    
    # Lazy conda initialization
    conda() {
        unset -f conda
        
        __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            source "$HOME/miniconda3/etc/profile.d/conda.sh"
        fi
        unset __conda_setup
        
        conda "$@"
    }
fi

## WezTerm Shell Integration
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    function __wezterm_osc7() {
        printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
    }
    
    function __wezterm_semantic_precmd() {
        printf "\033]133;D\033\\"
        __wezterm_osc7
        printf "\033]133;A\033\\"
    }
    
    function __wezterm_semantic_preexec() {
        printf "\033]133;C\033\\"
    }
    
    function __wezterm_set_user_vars() {
        printf "\033]1337;SetUserVar=%s=%s\033\\" \
            "WEZTERM_USER" "$(echo -n $(id -un) | base64)" \
            "WEZTERM_HOST" "$(echo -n $(hostname) | base64)" \
            "WEZTERM_IN_TMUX" "$(echo -n ${TMUX:+1} | base64)"
    }
    
    if [[ -n "${ZSH_VERSION}" ]]; then
        precmd_functions+=(__wezterm_semantic_precmd __wezterm_set_user_vars)
        preexec_functions+=(__wezterm_semantic_preexec)
    fi
    
    function wezterm_set_user_var() {
        if [[ $# -ne 2 ]]; then
            echo "Usage: wezterm_set_user_var <name> <value>"
            return 1
        fi
        printf "\033]1337;SetUserVar=%s=%s\033\\" "$1" "$(echo -n "$2" | base64)"
    }
fi

## GPG Agent - LAZY initialization (only when needed)
# Export GPG_TTY immediately (fast), but defer agent startup
if command -v gpg-agent >/dev/null; then
    export GPG_TTY=$(tty)
    
    # Lazy function that starts GPG agent on first use
    _ensure_gpg_agent() {
        if ! pgrep -x gpg-agent >/dev/null 2>&1; then
            gpg-agent --daemon --enable-ssh-support >/dev/null 2>&1
        fi
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)
        
        if [ -f "${HOME}/.gpg-agent-info" ]; then
            . "${HOME}/.gpg-agent-info"
            export GPG_AGENT_INFO
            export SSH_AUTH_SOCK
        fi
    }
    
    # Wrap GPG commands to ensure agent is running
    gpg() {
        _ensure_gpg_agent
        command gpg "$@"
    }
    
    pass() {
        _ensure_gpg_agent
        command pass "$@"
    }
fi

## GitHub Copilot CLI - Loaded via cache-integrations.zsh (no eval here)

## FZF - Load last to avoid conflicts
[[ -f "$ZSH_CONFIG_DIR/fzf.zsh" ]] && source "$ZSH_CONFIG_DIR/fzf.zsh"
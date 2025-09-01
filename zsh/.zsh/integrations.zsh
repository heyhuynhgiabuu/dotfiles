# Tool Integrations & Lazy Loading
# All external tool integrations in one place

# Platform detection (import from paths.zsh)
PLATFORM="${PLATFORM:-$(detect_platform)}"

## NVM - Lazy loading for performance
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    nvm "$@"
}

## SDKMAN - Immediate loading for Java management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

## Zoxide - Modern cd replacement
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

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

## Conda (conditional loading)
if [[ -d "$HOME/miniconda3" ]]; then
    __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
    unset __conda_setup
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

## GPG Agent
if command -v gpg-agent >/dev/null; then
    if ! pgrep -x gpg-agent >/dev/null; then
        gpg-agent --daemon --enable-ssh-support >/dev/null 2>&1
    fi
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    
    if [ -f "${HOME}/.gpg-agent-info" ]; then
        . "${HOME}/.gpg-agent-info"
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
    fi
fi

## GitHub Copilot CLI
command -v github-copilot-cli >/dev/null && eval "$(github-copilot-cli alias -- "$0")"

## FZF - Load last to avoid conflicts
[[ -f "$ZSH_CONFIG_DIR/fzf.zsh" ]] && source "$ZSH_CONFIG_DIR/fzf.zsh"
# Set up ZSH configuration directory
export ZSH_CONFIG_DIR="$HOME/.zsh"

# Load performance optimizations early
[ -f "$ZSH_CONFIG_DIR/performance-opts.zsh" ] && source "$ZSH_CONFIG_DIR/performance-opts.zsh"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
export KUBE_EDITOR=vim
export PAGER=less
export LESS=-R 

setopt prompt_subst
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
setopt extended_history

# Path setup (optimized with lazy loading)
path_add() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

# Core paths (immediate loading)
path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"
path_add "/usr/local/bin"
path_add "$HOME/bin"

# Development tools (immediate loading - safer than background jobs)
path_add "$HOME/.krew/bin"
path_add "$HOME/apache-maven-3.8.8/bin"

if [[ "$PLATFORM" == "macos" ]]; then
    # Java managed by SDKMAN - removed hardcoded path
    path_add "/opt/homebrew/opt/postgresql@16/bin"
    path_add "/opt/homebrew/opt/mysql-client/bin"
    
    # App integrations
    path_add "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    path_add "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    
    # Herd PHP
    path_add "$HOME/Library/Application Support/Herd/bin"
    
    # OpenCode
    path_add "$HOME/.opencode/bin"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Java managed by SDKMAN - removed hardcoded path
    # [[ -d "/usr/lib/jvm/java-21-openjdk/bin" ]] && path_add "/usr/lib/jvm/java-21-openjdk/bin"
    [[ -d "/usr/share/code/bin" ]] && path_add "/usr/share/code/bin"
    [[ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]] && path_add "$HOME/.local/share/JetBrains/Toolbox/scripts"
    
    # OpenCode
    [[ -d "$HOME/.opencode/bin" ]] && path_add "$HOME/.opencode/bin"
fi

# Cache & app integrations
path_add "$HOME/.cache/lm-studio/bin"

export PATH

# Prompt
# Load Starship OS detection and icon setup
[[ -f "$ZSH_CONFIG_DIR/starship.zsh" ]] && source "$ZSH_CONFIG_DIR/starship.zsh"

# Starship prompt (modern, theme Kanagawa compatible) - MUST be before oh-my-zsh
export STARSHIP_CONFIG="$ZSH_CONFIG_DIR/starship.toml"
eval "$(starship init zsh)"

export ZSH="$HOME/.oh-my-zsh"
# Disable oh-my-zsh themes when using Starship
ZSH_THEME=""

# Plugins & oh-my-zsh (streamlined for performance)
# Minimal oh-my-zsh plugins - let zinit handle advanced completions 
plugins=(brew dotenv)

source $ZSH/oh-my-zsh.sh

# Zinit - Advanced Plugin Management
# SECURITY: Manual installation required - run scripts/setup/install-zinit.sh
# This prevents automatic network fetches at shell startup

if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
else
    printf "\033[33mWarning: zinit not found. Run 'scripts/setup/install-zinit.sh' to install safely.\033[0m\n" >&2
fi

# Core zinit annexes (lightweight)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node

# Consolidated completions via zinit (replaces oh-my-zsh duplicates)
zinit wait'1' lucid for \
    OMZP::golang \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::kubectl \
    OMZP::npm \
    OMZP::git \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    blockf \
        zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# Completion styling - see advanced-completions.zsh for enhanced styles

# Go completion is handled by advanced-completions.zsh

# Autocompletions (streamlined)

autoload -Uz compinit bashcompinit

# Cache completion initialization for faster startup
if [[ $HOME/.zcompdump(#qNmh+24) ]]; then
    compinit -C
else
    compinit
fi
bashcompinit

# Conditional tool completions (only if tools exist)
command -v terraform >/dev/null && complete -o nospace -C terraform terraform
command -v aws_completer >/dev/null && complete -C '/usr/local/bin/aws_completer' aws

# Kubectl completion (cached)
if command -v kubectl >/dev/null; then
  [[ ! -f ~/.kubectl-completion ]] && kubectl completion zsh > ~/.kubectl-completion
  source ~/.kubectl-completion
fi

# Platform-specific completion paths
fpath_add() { [[ -d "$1" && ":$fpath:" != *":$1:"* ]] && fpath=("$1" $fpath); }

if [[ "$PLATFORM" == "macos" ]]; then
    [[ -d "$HOME/.docker/completions" ]] && fpath_add "$HOME/.docker/completions"
elif [[ "$PLATFORM" == "linux" ]]; then
    [[ -d "/usr/share/bash-completion/completions" ]] && fpath_add "/usr/share/bash-completion/completions"
    [[ -d "/etc/bash_completion.d" ]] && fpath_add "/etc/bash_completion.d"
fi

# Angular CLI completion (if available)
command -v ng >/dev/null && source <(ng completion script)

# Lazy loading

## nvm - lazy loading for better performance
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Set default Node version without loading nvm initially
export PATH="$NVM_DIR/versions/node/v22.14.0/bin:$PATH"

## sdkman (immediate initialization for proper Java management)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

## Zoxide
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

## TheFuck - lazy loading
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

# Conditional integrations (platform-specific)

# Herd PHP configuration (macOS only)
if [[ "$PLATFORM" == "macos" ]]; then
    export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
    export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
    export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
    export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"
fi

# Conda (conditional loading)
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

# Custom fields & Integrations

# Wezterm Shell Integration
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    # OSC 7 for working directory tracking
    function __wezterm_osc7() {
        printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
    }
    
    # OSC 133 for semantic prompt zones (Input/Output/Prompt detection)
    function __wezterm_semantic_precmd() {
        printf "\033]133;D\033\\"  # Mark end of command output
        __wezterm_osc7
        printf "\033]133;A\033\\"  # Mark start of prompt
    }
    
    function __wezterm_semantic_preexec() {
        printf "\033]133;C\033\\"  # Mark end of prompt, start of command input
    }
    
    # Set user variables for enhanced status bar
    function __wezterm_set_user_vars() {
        printf "\033]1337;SetUserVar=%s=%s\033\\" \
            "WEZTERM_USER" "$(echo -n $(id -un) | base64)" \
            "WEZTERM_HOST" "$(echo -n $(hostname) | base64)" \
            "WEZTERM_IN_TMUX" "$(echo -n ${TMUX:+1} | base64)"
    }
    
    # Hook into zsh prompt system
    if [[ -n "${ZSH_VERSION}" ]]; then
        precmd_functions+=(__wezterm_semantic_precmd __wezterm_set_user_vars)
        preexec_functions+=(__wezterm_semantic_preexec)
    fi
    
    # Convenience function to set custom user vars
    function wezterm_set_user_var() {
        if [[ $# -ne 2 ]]; then
            echo "Usage: wezterm_set_user_var <name> <value>"
            return 1
        fi
        printf "\033]1337;SetUserVar=%s=%s\033\\" "$1" "$(echo -n "$2" | base64)"
    }
fi


# Load modular configuration files
[[ -f "$ZSH_CONFIG_DIR/envs.zsh" ]] && source "$ZSH_CONFIG_DIR/envs.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"
[[ -f "$ZSH_CONFIG_DIR/advanced-completions.zsh" ]] && source "$ZSH_CONFIG_DIR/advanced-completions.zsh"

# GitHub Copilot CLI integration (conditional)
command -v github-copilot-cli >/dev/null && eval "$(github-copilot-cli alias -- "$0")"

# OpenCode integration (removed from path section above)

. "$HOME/.local/bin/env"

# GPG Agent Configuration
# Start GPG agent and set environment variables
if command -v gpg-agent >/dev/null; then
    # Start GPG agent if not running
    if ! pgrep -x gpg-agent >/dev/null; then
        gpg-agent --daemon --enable-ssh-support >/dev/null 2>&1
    fi

    # Set GPG environment variables
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

    # Source GPG agent info if available
    if [ -f "${HOME}/.gpg-agent-info" ]; then
        . "${HOME}/.gpg-agent-info"
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
    fi
fi

# FZF - Fuzzy finder integration (load LAST to avoid key binding conflicts)
[[ -f "$ZSH_CONFIG_DIR/fzf.zsh" ]] && source "$ZSH_CONFIG_DIR/fzf.zsh"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/82/"


# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/74/"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/85/"

# Performance & Shell options

# Set up configuration directory for modular loading
ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/.zsh"

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

# Path setup

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

# Core paths
path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"
path_add "/usr/local/bin"
path_add "$HOME/bin"
path_add "$HOME/.krew/bin"

# Dev tools
path_add "$HOME/apache-maven-3.8.8/bin"
if [[ "$PLATFORM" == "macos" ]]; then
    path_add "$HOME/Library/Java/JavaVirtualMachines/openjdk-21.0.2/Contents/Home/bin"
    path_add "/opt/homebrew/opt/postgresql@16/bin"
    path_add "/opt/homebrew/opt/mysql-client/bin"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Linux equivalent paths
    [[ -d "/usr/lib/jvm/java-21-openjdk/bin" ]] && path_add "/usr/lib/jvm/java-21-openjdk/bin"
    [[ -d "/usr/bin" ]] && path_add "/usr/bin" # PostgreSQL and MySQL typically in /usr/bin on Linux
fi

# App integrations
path_add "$HOME/.cache/lm-studio/bin"
if [[ "$PLATFORM" == "macos" ]]; then
    path_add "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    path_add "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Linux equivalent paths
    [[ -d "/usr/share/code/bin" ]] && path_add "/usr/share/code/bin"
    [[ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]] && path_add "$HOME/.local/share/JetBrains/Toolbox/scripts"
fi

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

# Plugins & oh-my-zsh

# plugins=(docker docker-compose kubectl terraform aws) 
plugins=(brew zsh-autosuggestions zsh-syntax-highlighting zsh-z dotenv)

source $ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zinit

if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Advanced completions

# Lazy load Zinit completions for better startup performance
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

zstyle ':completion:*' menu select=2
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format '%F{blue}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

zstyle ':completion:*:descriptions' format '%F{cyan}%B-- %d --%b%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' group-name ''
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

zstyle ':completion:*:*:go:*' format '%F{green}%B[Go Commands]%b%f'
zstyle ':completion:*:*:docker:*' format '%F{blue}%B[Docker Commands]%b%f'
zstyle ':completion:*:*:git:*' format '%F{magenta}%B[Git Commands]%b%f'

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

if command -v go >/dev/null; then
    compdef _go go
    # Custom go commands completion
    _go_custom() {
        local -a subcmds
        subcmds=(
            'run:run Go program'
            'build:build Go program'
            'test:test packages'
            'mod:module maintenance'
            'get:download and install packages'
            'install:compile and install packages'
            'clean:remove object files'
            'fmt:format Go source files'
            'vet:examine Go source code'
            'version:print Go version'
        )
        _describe 'go commands' subcmds
    }
    compdef _go_custom go
fi

# Autocompletions

autoload -Uz compinit bashcompinit
compinit
bashcompinit

command -v terraform >/dev/null && complete -o nospace -C terraform terraform
command -v aws_completer >/dev/null && complete -C '/usr/local/bin/aws_completer' aws

if command -v kubectl >/dev/null; then
  [[ ! -f ~/.kubectl-completion ]] && kubectl completion zsh > ~/.kubectl-completion
  source ~/.kubectl-completion
fi

fpath_add() { [[ -d "$1" && ":$fpath:" != *":$1:"* ]] && fpath=("$1" $fpath); }

if [[ "$PLATFORM" == "macos" ]]; then
    fpath_add "$HOME/.docker/completions"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Linux Docker completion paths
    [[ -d "/usr/share/bash-completion/completions" ]] && fpath_add "/usr/share/bash-completion/completions"
    [[ -d "/etc/bash_completion.d" ]] && fpath_add "/etc/bash_completion.d"
fi

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

## sdkman
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

## Zoxide
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

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

# Herd injected PHP configuration (macOS only)
if [[ "$PLATFORM" == "macos" ]]; then
    # Herd injected PHP 8.4 configuration.
    export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"

    # Herd injected PHP 8.3 configuration.
    export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
    
    # Herd injected PHP 8.2 configuration.
    export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
    
    # Herd injected PHP 7.4 configuration.
    export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"
fi

# Conda

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

# GitHub Copilot CLI integration (if available)
if command -v github-copilot-cli >/dev/null; then
    eval "$(github-copilot-cli alias -- "$0")"
fi

# opencode
if [[ "$PLATFORM" == "macos" ]]; then
    export PATH="$HOME/.opencode/bin:$PATH"
elif [[ "$PLATFORM" == "linux" ]]; then
    # Adjust for Linux opencode installation path if different
    [[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
fi

. "$HOME/.local/bin/env"



# 💡 Instant Prompt — phải ở đầu tiên
# --- Conditional block for terminal-only commands ---
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
    # Initialize Powerlevel10k prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi
fi

# Performance & Shell options

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
export KUBE_EDITOR=vim
export PAGER=less
export LESS=-R 

# Suppress Powerlevel10k instant prompt warnings\
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

setopt prompt_subst
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
setopt extended_history

# Path setup

path_add() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }

# Core paths
path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"
path_add "/usr/local/bin"
path_add "$HOME/bin"
path_add "$HOME/.krew/bin"

# Dev tools
path_add "$HOME/apache-maven-3.8.8/bin"
path_add "$HOME/Library/Java/JavaVirtualMachines/openjdk-21.0.2/Contents/Home/bin"
path_add "/opt/homebrew/opt/postgresql@16/bin"
path_add "/opt/homebrew/opt/mysql-client/bin"

# App integrations
path_add "$HOME/.cache/lm-studio/bin"
path_add "/Applications/iTerm.app/Contents/Resources/utilities"
path_add "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
path_add "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export PATH

# Prompt

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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

zinit wait lucid for \
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

fpath=(/Users/killerkidbo/.docker/completions $fpath)

command -v ng >/dev/null && source <(ng completion script)

# Lazy loading

## nvm
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

## sdkman
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

## Zoxide
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

## TheFuck
command -v thefuck >/dev/null && {
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias fk)"
}

## Herd PHP

if [[ -d "$HOME/Library/Application Support/Herd" ]]; then
  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
  export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
  export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
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


[[ -f ~/.zsh/envs.zsh ]] && source ~/.zsh/envs.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh
[[ -f ~/.zsh/advanced-completions.zsh ]] && source ~/dotfiles/zsh/advanced-completions.zsh

# iTerm2 Shell Integration (for enhanced completions)
[[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

# GitHub Copilot CLI integration (if available)
if command -v github-copilot-cli >/dev/null; then
    eval "$(github-copilot-cli alias -- "$0")"
fi

# opencode
export PATH=/Users/killerkidbo/.opencode/bin:$PATH

# 💡 Instant Prompt — phải ở đầu tiên
# --- Conditional block for terminal-only commands ---
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
    # Initialize Powerlevel10k prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi
fi

# =============================================================================
# ⚡ PERFORMANCE & SHELL OPTIONS
# =============================================================================

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

# =============================================================================
# ⚙️ PATH SETUP
# =============================================================================

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

# =============================================================================
# 🌈 PROMPT
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# =============================================================================
# 🔌 PLUGINS & OH-MY-ZSH
# =============================================================================

# plugins=(docker docker-compose kubectl terraform aws) 
plugins=(brew zsh-autosuggestions zsh-syntax-highlighting zsh-z dotenv)

source $ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# ⚙️ ZINIT
# =============================================================================

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

# =============================================================================
# 🧠 AUTOCOMPLETIONS
# =============================================================================

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

# =============================================================================
# 🛠 LAZY LOADING
# =============================================================================

# NVM
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

# Zoxide
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# TheFuck
command -v thefuck >/dev/null && {
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias fk)"
}

# =============================================================================
# 🐘 HERD PHP
# =============================================================================

if [[ -d "$HOME/Library/Application Support/Herd" ]]; then
  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
  export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
  export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
  export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"
fi

# =============================================================================
# 🧬 CONDA
# =============================================================================

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

# =============================================================================
# 🔁 CUSTOM FILES
# =============================================================================

[[ -f ~/.zsh/envs.zsh ]] && source ~/.zsh/envs.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh


# Add ~/.bin to PATH
export PATH="$HOME/.bin:$PATH"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/killerkidbo/Library/Application Support/Herd/config/php/82/"

# Go development environment
export GOPATH=$HOME/go
export GOROOT=$(go env GOROOT 2>/dev/null || echo "/usr/local/go")
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# Go-specific aliases
alias gor='go run .'
alias gob='go build .'
alias got='go test ./...'
alias gotv='go test -v ./...'
alias gom='go mod tidy'
alias goi='go install'
alias gof='gofumpt -w .'
alias gol='golangci-lint run'


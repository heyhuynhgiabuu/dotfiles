# Simplified Completions
# Removed redundant zinit loading and over-engineering

# Essential completion behavior
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Basic completion styling
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors 'di=1;34:ln=1;36:ex=1;32'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches found'

# Enhanced history search
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Key bindings
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Basic tool completions (only if tools exist)
autoload -Uz bashcompinit
bashcompinit

command -v terraform >/dev/null && complete -o nospace -C terraform terraform
command -v aws_completer >/dev/null && complete -C '/usr/local/bin/aws_completer' aws

# Kubectl completion (cached)
if command -v kubectl >/dev/null; then
    [[ ! -f ~/.kubectl-completion ]] && kubectl completion zsh > ~/.kubectl-completion
    source ~/.kubectl-completion
fi

# Angular CLI completion
command -v ng >/dev/null && source <(ng completion script)

# Platform-specific completion paths
fpath_add() { [[ -d "$1" && ":$fpath:" != *":$1:"* ]] && fpath=("$1" $fpath); }

PLATFORM="${PLATFORM:-$(detect_platform)}"
if [[ "$PLATFORM" == "macos" ]]; then
    [[ -d "$HOME/.docker/completions" ]] && fpath_add "$HOME/.docker/completions"
elif [[ "$PLATFORM" == "linux" ]]; then
    [[ -d "/usr/share/bash-completion/completions" ]] && fpath_add "/usr/share/bash-completion/completions"
    [[ -d "/etc/bash_completion.d" ]] && fpath_add "/etc/bash_completion.d"
fi
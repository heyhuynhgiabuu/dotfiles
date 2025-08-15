# Ultra-Fast Core Aliases - Most Used Commands Only
# Split from full aliases.zsh for faster loading

# Essential navigation (90% usage)
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='eza --color=always --icons --long'
alias ls='eza --color=always --icons'
alias cl='clear'

# Essential editors (80% usage)  
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Essential git (70% usage)
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Essential docker (60% usage)
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'

# Essential search tools
alias rg='rg --smart-case --color=always'
alias fd='fd --color=always'
alias bat='bat --style=plain --paging=never'

# Load full aliases on demand
full_aliases() {
  [[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
  unset -f full_aliases
}
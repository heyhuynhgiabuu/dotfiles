# ZSH Completion Performance Optimization
# This file optimizes the completion system for faster startup

# Skip security checks for faster compinit (only on trusted systems)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -d ~/.zcompdump
else
  compinit -C -d ~/.zcompdump
fi

# Completion caching for better performance
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# Optimize completion matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

# Reduce completion verbosity for speed
zstyle ':completion:*' verbose false
zstyle ':completion:*' menu select=2

# Group completions efficiently  
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''

# Speed up file completion
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' list-suffixes true

# Optimize process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
# Essential Performance Optimizations
# Stripped of enterprise bloat, focused on what actually matters

# Fix recursive function issues
export FUNCNEST=500

# Essential shell options for performance
setopt NO_CASE_GLOB        # Case insensitive globbing
setopt AUTO_CD             # Auto cd without typing cd
setopt COMPLETE_IN_WORD    # Complete from both ends of word
setopt ALWAYS_TO_END       # Move cursor to end of word on completion

# History optimization (essential settings only)
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Command execution optimization
setopt HASH_CMDS           # Hash command locations
setopt HASH_DIRS           # Hash directory locations

# Git status for prompts (simple version)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats " %b"
zstyle ':vcs_info:git*' actionformats " %b (%a)"

# Optimized completion initialization
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit -d ~/.zcompdump
else
    compinit -C -d ~/.zcompdump
fi

# Basic completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
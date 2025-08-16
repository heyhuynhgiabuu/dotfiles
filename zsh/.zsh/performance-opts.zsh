# Shell Performance Optimization Configuration
# Caching and lazy loading strategies to improve startup time

# Fix for recursive function issues (starship/prompt)
export FUNCNEST=500

# Enable additional performance optimizations
setopt NO_CASE_GLOB        # Case insensitive globbing
setopt AUTO_CD             # Auto cd without typing cd
setopt CORRECT_ALL         # Auto correct commands and arguments  
setopt COMPLETE_IN_WORD    # Complete from both ends of word
setopt ALWAYS_TO_END       # Move cursor to end of word on completion

# History optimization (reduces I/O)
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

# Performance: Command execution optimization  
setopt HASH_CMDS           # Hash command locations
setopt HASH_DIRS           # Hash directory locations

# Git status caching for better performance
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats " %b"
zstyle ':vcs_info:git*' actionformats " %b (%a)"

# Performance: Cache expensive operations
typeset -A __perf_cache
__cache_command() {
  local cache_key="$1"
  local cache_duration="${2:-300}" # 5 minutes default
  local cache_file="/tmp/zsh_cache_${cache_key//\//_}"
  
  if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_duration ]]; then
    cat "$cache_file"
    return 0
  fi
  
  return 1
}

__set_cache() {
  local cache_key="$1"
  local cache_file="/tmp/zsh_cache_${cache_key//\//_}"
  cat > "$cache_file"
}

# Cached git status for prompt (if using git-based prompt)
__cached_git_status() {
  if __cache_command "git_status_$(pwd)" 30; then
    return 0
  fi
  
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git status --porcelain 2>/dev/null | wc -l | __set_cache "git_status_$(pwd)"
  else
    echo "0" | __set_cache "git_status_$(pwd)" 
  fi
}

# Performance: Lazy load expensive functions
autoload -Uz compinit

# Optimize compinit for faster startup
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -d ~/.zcompdump
else
  compinit -C -d ~/.zcompdump
fi

# Performance: Reduce filesystem checks
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Cleanup old cache files periodically (silent, no background jobs)
# Only run cleanup occasionally to avoid startup overhead
if [[ -n ~/.zsh/cache(#qN.mh+24) ]]; then
  # Clean up cache files older than 1 day, but do it silently and quickly
  find /tmp -name "zsh_cache_*" -mtime +1 -delete 2>/dev/null || true
fi
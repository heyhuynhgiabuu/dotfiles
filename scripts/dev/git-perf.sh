#!/bin/bash
# Git Performance Optimization and Caching
# Reduces redundant git operations and improves workflow speed

set -euo pipefail

# Configuration
CACHE_DIR="$HOME/.cache/git-perf"
CACHE_DURATION_SECONDS=300  # 5 minutes
MAX_REPOS=50  # Limit cached repositories

mkdir -p "$CACHE_DIR"

# Logging
log() { printf "[git-perf] %s\n" "$*" >&2; }

# Cache management
get_cache_file() {
    local repo_hash
    repo_hash=$(echo "$PWD" | shasum -a 256 | cut -d' ' -f1)
    echo "$CACHE_DIR/repo_${repo_hash}.cache"
}

is_cache_valid() {
    local cache_file="$1"
    if [[ -f "$cache_file" ]]; then
        local age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)))
        [[ $age -lt $CACHE_DURATION_SECONDS ]]
    else
        return 1
    fi
}

cleanup_old_cache() {
    find "$CACHE_DIR" -name "*.cache" -mtime +1 -delete 2>/dev/null || true
    
    # Limit number of cached repos
    local cache_count
    cache_count=$(find "$CACHE_DIR" -name "*.cache" | wc -l)
    if [[ $cache_count -gt $MAX_REPOS ]]; then
        find "$CACHE_DIR" -name "*.cache" -exec ls -t {} + | tail -n +$((MAX_REPOS + 1)) | xargs rm -f
    fi
}

# Git status with caching
git_status_cached() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "=== Git Status ==="
        echo "Not a git repository"
        echo "=== End Status ==="
        return 0  # Don't treat this as an error for the script
    fi
    
    local cache_file
    cache_file=$(get_cache_file)
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    # Generate fresh status
    {
        echo "=== Git Status ($(date '+%H:%M:%S')) ==="
        echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
        echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'none')"
        
        local status_info
        status_info=$(git status --porcelain 2>/dev/null || echo "")
        local modified_count
        modified_count=$(echo "$status_info" | grep -c "^.M" || echo "0")
        local added_count  
        added_count=$(echo "$status_info" | grep -c "^A" || echo "0")
        local untracked_count
        untracked_count=$(echo "$status_info" | grep -c "^??" || echo "0")
        
        echo "Changes: $modified_count modified, $added_count staged, $untracked_count untracked"
        
        # Check if ahead/behind remote
        local ahead_behind
        ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0	0")
        local ahead
        ahead=$(echo "$ahead_behind" | cut -f1)
        local behind
        behind=$(echo "$ahead_behind" | cut -f2)
        
        if [[ $ahead -gt 0 || $behind -gt 0 ]]; then
            echo "Sync: $ahead ahead, $behind behind"
        else
            echo "Sync: up to date"
        fi
        
        echo "=== End Status ==="
    } | tee "$cache_file"
}

# Optimized git log with caching
git_log_cached() {
    local lines="${1:-10}"
    local cache_file
    cache_file="${CACHE_DIR}/log_$(get_cache_file | cut -d'/' -f5)_${lines}.cache"
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    git log --oneline -n "$lines" | tee "$cache_file"
}

# Smart git fetch (only when needed)
git_fetch_smart() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log "Not a git repository"
        return 1
    fi
    
    local last_fetch_file="$CACHE_DIR/last_fetch_$(get_cache_file | cut -d'/' -f5)"
    
    # Only fetch if not done recently
    if is_cache_valid "$last_fetch_file"; then
        log "Fetched recently, skipping..."
        return 0
    fi
    
    log "Performing smart fetch..."
    if timeout 30 git fetch --quiet 2>/dev/null; then
        touch "$last_fetch_file"
        log "Fetch completed"
        
        # Invalidate status cache since remote state may have changed
        local status_cache
        status_cache=$(get_cache_file)
        rm -f "$status_cache"
    else
        log "Fetch timed out or failed"
        return 1
    fi
}

# Repository health check with caching
git_health_check() {
    local cache_file="$CACHE_DIR/health_$(get_cache_file | cut -d'/' -f5).cache"
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    {
        echo "=== Repository Health Check ==="
        echo "Repository size: $(du -sh .git 2>/dev/null | cut -f1 || echo 'unknown')"
        echo "Object count: $(git count-objects 2>/dev/null | head -1 || echo 'unknown')"
        echo "Packed objects: $(git count-objects -v 2>/dev/null | grep 'count ' | cut -d' ' -f2 || echo 'unknown')"
        
        # Check for large files
        local large_files
        large_files=$(git ls-tree -r -l HEAD 2>/dev/null | sort -k4 -nr | head -3 | awk '{print $4, $5}' || echo "none")
        echo "Largest files: $large_files"
        
        # Check branch status
        local branch_count
        branch_count=$(git branch -a 2>/dev/null | wc -l || echo "0")
        echo "Total branches: $branch_count"
        
        echo "=== End Health Check ==="
    } | tee "$cache_file"
}

# Performance optimization for git operations
optimize_git_performance() {
    log "Optimizing git performance settings..."
    
    # Set performance-oriented git configs
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256
    git config --global pack.threads 0
    
    # Enable partial clone for large repos (if supported)
    if git config --get remote.origin.url >/dev/null 2>&1; then
        git config --global fetch.fsckObjects false
    fi
    
    log "Git performance optimization completed"
}

# Cleanup and maintenance
cleanup_cache() {
    log "Cleaning up git cache..."
    cleanup_old_cache
    
    # Clean up git itself
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git gc --auto --quiet 2>/dev/null || true
    fi
    
    log "Cache cleanup completed"
}

# Main execution
case "${1:-status}" in
    "status") git_status_cached ;;
    "log") git_log_cached "${2:-10}" ;;
    "fetch") git_fetch_smart ;;
    "health") git_health_check ;;
    "optimize") optimize_git_performance ;;
    "cleanup") cleanup_cache ;;
    "refresh")
        # Force refresh all caches
        local cache_file
        cache_file=$(get_cache_file)
        rm -f "${cache_file}"* 2>/dev/null || true
        git_status_cached
        ;;
    *)
        echo "Usage: $0 {status|log|fetch|health|optimize|cleanup|refresh}"
        echo "  status   - Cached git status"
        echo "  log      - Cached git log [lines]"
        echo "  fetch    - Smart fetch (only when needed)"
        echo "  health   - Repository health check"
        echo "  optimize - Apply git performance settings"
        echo "  cleanup  - Clean caches and run git gc"
        echo "  refresh  - Force refresh all caches"
        exit 1
        ;;
esac
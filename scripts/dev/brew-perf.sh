#!/bin/bash
# Homebrew Performance and Automation Scripts
# Optimized workflows for package management

set -euo pipefail

# Performance: Homebrew optimization settings
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Colors and logging
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$*"; }
log_warning() { printf "${YELLOW}[WARNING]${NC} %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }

# Performance: Cached Homebrew operations
CACHE_DIR="$HOME/.cache/homebrew-perf"
mkdir -p "$CACHE_DIR" && chmod 700 "$CACHE_DIR"

cache_file() {
    local operation="$1"
    echo "$CACHE_DIR/${operation}_$(date +%Y%m%d).cache"
}

is_cache_valid() {
    local cache_file="$1"
    local max_age_hours="${2:-6}"
    
    if [[ -f "$cache_file" ]]; then
        local file_age_hours=$(( ($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)) / 3600 ))
        [[ $file_age_hours -lt $max_age_hours ]]
    else
        return 1
    fi
}

# Fast Homebrew status check with caching
brew_status_cached() {
    local cache_file
    cache_file=$(cache_file "status")
    
    if is_cache_valid "$cache_file" 12; then
        cat "$cache_file"
        return 0
    fi
    
    log_info "Refreshing Homebrew status cache..."
    {
        echo "=== Homebrew Status (Cached $(date)) ==="
        echo "Installed packages: $(brew list --formula | wc -l | tr -d ' ')"
        echo "Installed casks: $(brew list --cask | wc -l | tr -d ' ')"
        echo "Outdated packages: $(brew outdated --quiet | wc -l | tr -d ' ')"
        echo "=== End Status ==="
    } | tee "$cache_file"
}

# Performance optimized update workflow
brew_smart_update() {
    local cache_file
    cache_file=$(cache_file "update")
    
    # Only update if not done recently
    if is_cache_valid "$cache_file" 24; then
        log_info "Homebrew updated recently, skipping..."
        return 0
    fi
    
    log_info "Performing smart Homebrew update..."
    
    # Update with timeout protection
    timeout 300 brew update || {
        log_warning "Homebrew update timed out, continuing anyway..."
    }
    
    # Check for critical outdated packages only
    local outdated_critical
    outdated_critical=$(brew outdated --quiet | grep -E "(git|node|python|go|rust)" || true)
    
    if [[ -n "$outdated_critical" ]]; then
        log_warning "Critical packages outdated:"
        echo "$outdated_critical"
        
        # Only prompt in interactive shells
        if [[ -t 0 ]] && [[ "$-" == *i* ]]; then
            read -p "Update critical packages? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Use safe iteration instead of xargs
                while IFS= read -r package; do
                    [[ -n "$package" ]] && brew upgrade -- "$package"
                done <<< "$outdated_critical"
            fi
        else
            log_info "Non-interactive shell detected - skipping critical package updates"
        fi
    fi
    
    # Mark update as completed
    date > "$cache_file"
    log_success "Homebrew smart update completed"
}

# Optimized cleanup routine
brew_smart_cleanup() {
    log_info "Running optimized Homebrew cleanup..."
    
    # Cleanup with size reporting
    local size_before
    size_before=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "0B")
    
    brew cleanup --prune=7 2>/dev/null || true
    brew autoremove 2>/dev/null || true
    
    local size_after
    size_after=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "0B")
    
    log_success "Cleanup completed. Cache size: $size_before → $size_after"
}

# Brewfile sync with validation
brew_sync_brewfile() {
    local brewfile="${1:-$HOME/dotfiles/homebrew/Brewfile}"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    log_info "Syncing with Brewfile: $brewfile"
    
    # Backup current state
    brew bundle dump --file="$HOME/.Brewfile.backup.$(date +%Y%m%d_%H%M%S)" --force
    
    # Install missing packages
    if brew bundle check --file="$brewfile" >/dev/null 2>&1; then
        log_success "All Brewfile packages already installed"
    else
        log_warning "Installing missing packages from Brewfile..."
        brew bundle install --file="$brewfile" --no-lock
    fi
}

# Performance monitoring
brew_performance_report() {
    log_info "Homebrew Performance Report"
    echo "=========================="
    echo "Total packages: $(brew list --formula | wc -l | tr -d ' ')"
    echo "Total casks: $(brew list --cask | wc -l | tr -d ' ')"
    echo "Cache size: $(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "Unknown")"
    echo "Last cleanup: $(ls -la "$(brew --cache)" 2>/dev/null | head -2 | tail -1 | awk '{print $6, $7, $8}' || echo "Unknown")"
    
    # Check for performance issues
    local large_packages
    large_packages=$(brew list --formula | xargs -I {} sh -c 'echo "$(brew info {} 2>/dev/null | grep -E "^[^:]*:" | wc -l | tr -d " ") {}"' | sort -nr | head -5)
    
    echo "Top packages by dependencies:"
    echo "$large_packages"
}

# Main execution
case "${1:-status}" in
    "status") brew_status_cached ;;
    "update") brew_smart_update ;;
    "cleanup") brew_smart_cleanup ;;
    "sync") brew_sync_brewfile "${2:-}" ;;
    "report") brew_performance_report ;;
    "all") 
        brew_smart_update
        brew_smart_cleanup
        brew_status_cached
        ;;
    *)
        echo "Usage: $0 {status|update|cleanup|sync|report|all}"
        echo "  status  - Show cached status info"
        echo "  update  - Smart update with critical package priority"
        echo "  cleanup - Optimized cleanup routine"
        echo "  sync    - Sync with Brewfile"
        echo "  report  - Performance analysis"
        echo "  all     - Run update, cleanup, and status"
        exit 1
        ;;
esac
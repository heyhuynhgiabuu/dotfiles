# Useful Shell Functions
# Practical functions that improve daily workflow

# OpenCode log viewer with filtering options
logocode() {
    local log_dir="$HOME/.local/share/opencode/log"
    local filter_type="$1"  # 'plugins', 'errors', 'performance', or empty for all
    
    if [[ -d "$log_dir" ]]; then
        local latest_file
        latest_file=$(find "$log_dir" -type f -name "*.log" -exec ls -t {} + 2>/dev/null | head -n1)
        if [[ -n "$latest_file" ]]; then
            case "$filter_type" in
                "plugins")
                    echo "🔌 Plugin messages from: $latest_file"
                    echo "💡 Press Ctrl+C to stop following"
                    echo "🔍 Showing: Plugin initialization, tech stack detection, notifications, and context engineering"
                    echo ""
                    # Enhanced plugin patterns for our improved logging
                    local plugin_patterns="(service=notification-plugin|service=universal-context-engineering|🧭|📍|✨|🔍|🔒|🔔|🌍|Context Engineering|Landscape:|Enhanced.*tool|Tech stack detected|Framework guidance|Cache hit|Performance optimized|Plugin loaded|notification sent)"
                    grep -E "$plugin_patterns" "$latest_file" 2>/dev/null || echo "No plugin messages found in history"
                    echo ""
                    echo "--- LIVE PLUGIN FEED ---"
                    tail -f "$latest_file" | grep --line-buffered -E "$plugin_patterns"
                    ;;
                "errors")
                    echo "🚨 Error messages from: $latest_file"
                    echo "💡 Press Ctrl+C to stop following"
                    echo ""
                    grep -E "(ERROR|WARN|Failed|Exception|Error:|⚠️|❌)" "$latest_file" 2>/dev/null || echo "No errors found in history"
                    echo ""
                    echo "--- LIVE ERROR FEED ---"
                    tail -f "$latest_file" | grep --line-buffered -E "(ERROR|WARN|Failed|Exception|Error:|⚠️|❌)"
                    ;;
                "performance")
                    echo "⚡ Performance messages from: $latest_file"
                    echo "💡 Press Ctrl+C to stop following"
                    echo ""
                    grep -E "(Performance|Cache|Optimized|slow|fast|duration|ms|seconds|memory|CPU)" "$latest_file" 2>/dev/null || echo "No performance messages found in history"
                    echo ""
                    echo "--- LIVE PERFORMANCE FEED ---"
                    tail -f "$latest_file" | grep --line-buffered -E "(Performance|Cache|Optimized|slow|fast|duration|ms|seconds|memory|CPU)"
                    ;;
                *)
                    echo "📋 Following OpenCode log: $latest_file"
                    echo "💡 Press Ctrl+C to stop following"
                    echo "💡 Available filters:"
                    echo "   logocode plugins     - Show plugin activity"
                    echo "   logocode errors      - Show errors and warnings"
                    echo "   logocode performance - Show performance metrics"
                    if command -v bat >/dev/null 2>&1; then
                        tail -f "$latest_file" | bat --style=plain --color=always --language=log
                    else
                        tail -f "$latest_file"
                    fi
                    ;;
            esac
        else
            echo "❌ No log files found in $log_dir"
        fi
    else
        echo "❌ Log directory not found: $log_dir"
        echo "💡 Try running OpenCode first to create logs"
    fi
}

# Git clean merged branches
git_clean_merged() {
    echo "🧹 Cleaning merged branches..."
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
    echo "✅ Cleaned merged branches"
}

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find and kill process by name
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    local pid
    pid=$(lsof -ti:$1)
    if [[ -n "$pid" ]]; then
        kill -9 "$pid"
        echo "✅ Killed process on port $1"
    else
        echo "❌ No process found on port $1"
    fi
}

# Weather check (cross-platform)
weather() {
    local location="${1:-}"
    if command -v curl >/dev/null; then
        curl -s "wttr.in/${location}?format=3"
    else
        echo "❌ curl not available"
    fi
}

# Quick Git commit with message
qcommit() {
    if [[ -z "$1" ]]; then
        echo "Usage: qcommit <message>"
        return 1
    fi
    git add . && git commit -m "$1"
}

# Docker container shell access
dsh() {
    if [[ -z "$1" ]]; then
        echo "Usage: dsh <container_name>"
        return 1
    fi
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

# Backup important files
backup() {
    local backup_dir="$HOME/Backups/$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    cp -r ~/.zshrc ~/.gitconfig ~/.ssh/config "$backup_dir/" 2>/dev/null
    echo "✅ Backup created in $backup_dir"
}
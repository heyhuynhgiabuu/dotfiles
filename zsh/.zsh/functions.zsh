# Useful Shell Functions
# Practical functions that improve daily workflow

# Enhanced OpenCode log viewer with advanced filtering and analysis
logocode() {
    # Color codes for log highlighting
    local RED='\x1b[31m'
    local GREEN='\x1b[32m'
    local YELLOW='\x1b[33m'
    local BLUE='\x1b[34m'
    local MAGENTA='\x1b[35m'
    local CYAN='\x1b[36m'
    local WHITE='\x1b[37m'
    local BOLD='\x1b[1m'
    local RESET='\x1b[0m'

    # Colorize function for log output
    colorize_logs() {
        sed \
            -e "s/\(ERROR\)/${RED}${BOLD}\1${RESET}/g" \
            -e "s/\(WARN\)/${YELLOW}${BOLD}\1${RESET}/g" \
            -e "s/\(INFO\)/${GREEN}\1${RESET}/g" \
            -e "s/\(DEBUG\)/${BLUE}\1${RESET}/g" \
            -e "s/\(service=[^ ]*\)/${MAGENTA}\1${RESET}/g" \
            -e "s/\(Plugin loaded\)/${CYAN}${BOLD}\1${RESET}/g" \
            -e "s/\(❌\)/${RED}\1${RESET}/g" \
            -e "s/\(✅\)/${GREEN}\1${RESET}/g" \
            -e "s/\(⚠️\)/${YELLOW}\1${RESET}/g" \
            -e "s/\(🔧\)/${CYAN}\1${RESET}/g" \
            -e "s/\(🔌\)/${MAGENTA}\1${RESET}/g" \
            -e "s/\(🌍\)/${BLUE}\1${RESET}/g" \
            -e "s/\(✨\)/${YELLOW}\1${RESET}/g" \
            -e "s/\(📍\)/${CYAN}\1${RESET}/g" \
            -e "s/\(🔍\)/${GREEN}\1${RESET}/g" \
            -e "s/\(🔔\)/${MAGENTA}\1${RESET}/g"
    }
    local log_dir="$HOME/.local/share/opencode/log"
    local filter_type=""
    local lines=50
    local follow=true  # Default to live checking
    local search_pattern=""
    local save_file=""
    local clear_logs=false
    local show_stats=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lines|-n)
                lines="$2"
                shift 2
                ;;
            --static|-s)
                follow=false
                shift
                ;;
            --search|-S)
                search_pattern="$2"
                shift 2
                ;;
            --save)
                save_file="$2"
                shift 2
                ;;
            --clear)
                clear_logs=true
                shift
                ;;
            --stats)
                show_stats=true
                shift
                ;;
            plugins|errors|performance|hooks|sessions|api|all)
                filter_type="$1"
                shift
                ;;
            *)
                echo "❌ Unknown option: $1"
                echo "Usage: logocode [filter] [options]"
                echo "Filters: plugins, errors, performance, hooks, sessions, api, all"
                echo "Options:"
                echo "  --lines N, -n N    Show last N lines before live feed (default: 50)"
                echo "  --static, -s       Show static output instead of live following"
                echo "  --search PAT, -S PAT  Filter by regex pattern"
                echo "  --save FILE        Save output to file (static only)"
                echo "  --clear            Clear all log files"
                echo "  --stats            Show log statistics"
                return 1
                ;;
        esac
    done

    # Handle clear command
    if [[ "$clear_logs" == true ]]; then
        if [[ -d "$log_dir" ]]; then
            echo "🧹 Clearing all OpenCode log files..."
            rm -f "$log_dir"/*.log 2>/dev/null
            echo "✅ Logs cleared"
        else
            echo "❌ Log directory not found"
        fi
        return 0
    fi

    if [[ ! -d "$log_dir" ]]; then
        echo "❌ Log directory not found: $log_dir"
        echo "💡 Try running OpenCode first to create logs"
        return 1
    fi

    local latest_file
    latest_file=$(find "$log_dir" -type f -name "*.log" -exec ls -t {} + 2>/dev/null | head -n1)

    if [[ -z "$latest_file" ]]; then
        echo "❌ No log files found in $log_dir"
        return 1
    fi

    # Show stats if requested
    if [[ "$show_stats" == true ]]; then
        echo "📊 OpenCode Log Statistics"
        echo "📁 Log file: $latest_file"
        echo "📏 File size: $(du -h "$latest_file" | cut -f1)"
        echo "📅 Modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$latest_file")"
        echo "📈 Total lines: $(wc -l < "$latest_file")"
        echo "🚨 Errors: $(grep -c "ERROR\|❌" "$latest_file" 2>/dev/null || echo 0)"
        echo "⚠️ Warnings: $(grep -c "WARN\|⚠️" "$latest_file" 2>/dev/null || echo 0)"
        echo "🔌 Plugins: $(grep -c "service=.*plugin\|Plugin loaded" "$latest_file" 2>/dev/null || echo 0)"
        echo "🔧 Tools: $(grep -c "tool.execute" "$latest_file" 2>/dev/null || echo 0)"
        return 0
    fi

    # Build filter pattern based on type
    local filter_pattern=""
    case "$filter_type" in
        "plugins")
            filter_pattern="(service=notification-plugin|service=test-forge|🧭|📍|✨|🔍|🔒|🔔|🌍|Context Engineering|Landscape:|Enhanced.*tool|Tech stack detected|Framework guidance|Cache hit|Performance optimized|Plugin loaded|notification sent)"
            ;;
        "errors")
            filter_pattern="(ERROR|WARN|Failed|Exception|Error:|⚠️|❌|failed|Failed)"
            ;;
        "performance")
            filter_pattern="(Performance|Cache|Optimized|slow|fast|duration|ms|seconds|memory|CPU|time|latency)"
            ;;
        "hooks")
            filter_pattern="(tool\.execute\.|hook|Hook|triggered|AFTER|BEFORE)"
            ;;
        "sessions")
            filter_pattern="(session|Session|ses_|msg_|message|prompt)"
            ;;
        "api")
            filter_pattern="(method=|path=|status|request|response|API|api)"
            ;;
        "all"|*)
            filter_pattern=".*"
            ;;
    esac

    # Combine with search pattern if provided
    if [[ -n "$search_pattern" ]]; then
        if [[ -n "$filter_pattern" && "$filter_pattern" != ".*" ]]; then
            filter_pattern="($filter_pattern|$search_pattern)"
        else
            filter_pattern="$search_pattern"
        fi
    fi

    echo "📋 OpenCode Log Viewer"
    echo "📁 File: $latest_file"
    echo "🔍 Filter: ${filter_type:-all}"
    if [[ -n "$search_pattern" ]]; then
        echo "🔎 Search: $search_pattern"
    fi
    echo "📏 Lines: $lines"
    if [[ "$follow" == true ]]; then
        echo "🔄 Mode: Follow"
        echo "💡 Press Ctrl+C to stop"
    else
        echo "🔄 Mode: Static"
    fi
    echo ""

    # Execute based on mode
    if [[ -n "$save_file" ]]; then
        echo "💾 Saving output to: $save_file"
        if [[ "$follow" == true ]]; then
            echo "⚠️ Cannot save in follow mode"
            return 1
        fi
        if [[ "$filter_pattern" != ".*" ]]; then
            grep -E "$filter_pattern" "$latest_file" | tail -n $lines > "$save_file"
        else
            tail -n $lines "$latest_file" > "$save_file"
        fi
        echo "✅ Saved $(wc -l < "$save_file") lines to $save_file"
        return 0
    fi

    # Display mode
    if [[ "$follow" == true ]]; then
        # Show recent history first
        if [[ "$filter_pattern" != ".*" ]]; then
            grep -E "$filter_pattern" "$latest_file" | tail -n $lines | colorize_logs
        else
            tail -n $lines "$latest_file" | colorize_logs
        fi
        echo ""
        echo "--- LIVE FEED ---"
        # Live feed
        if [[ "$filter_pattern" != ".*" ]]; then
            tail -f "$latest_file" | grep --line-buffered -E "$filter_pattern" | colorize_logs
        else
            tail -f "$latest_file" | colorize_logs
        fi
    else
        # Static display
        if [[ "$filter_pattern" != ".*" ]]; then
            local output
            output=$(grep -E "$filter_pattern" "$latest_file" | tail -n $lines)
        else
            local output
            output=$(tail -n $lines "$latest_file")
        fi
        echo "$output" | colorize_logs
    fi
}

# List all active OpenCode sessions with their log files
logocodes() {
    local log_dir="$HOME/.local/share/opencode/log"
    
    if [[ ! -d "$log_dir" ]]; then
        echo "❌ Log directory not found: $log_dir"
        return 1
    fi
    
    echo "📊 Active OpenCode Sessions"
    echo ""
    
    local found_active=false
    local count=1
    local pids=$(pgrep -f "opencode" 2>/dev/null)
    
    for pid in $pids; do
        local cmd=$(ps -p "$pid" -o command= 2>/dev/null)
        
        if [[ -z "$cmd" ]]; then
            continue
        fi
        
        local tmux_info=""
        if command -v tmux >/dev/null 2>&1; then
            local pane_info=$(tmux list-panes -a -F "#{pane_pid} #{session_name}:#{window_index}.#{pane_index} #{window_name}" 2>/dev/null | grep "^$pid " || echo "")
            if [[ -n "$pane_info" ]]; then
                local pane_id=$(echo "$pane_info" | awk '{print $2}')
                local window_name=$(echo "$pane_info" | awk '{$1=$2=""; print $0}' | xargs)
                tmux_info=" [tmux: $pane_id ${window_name:+($window_name)}]"
            fi
        fi
        
        local log_files=$(lsof -p "$pid" 2>/dev/null | grep "\.log$" | awk '{print $NF}' | grep "$log_dir")
        
        if [[ -n "$log_files" ]]; then
            found_active=true
            echo "[$count] PID: $pid$tmux_info"
            echo "    📁 Log: $log_files"
            echo "    📏 Size: $(du -h "$log_files" 2>/dev/null | cut -f1)"
            echo "    📅 Modified: $(stat -f "%Sm" -t "%H:%M:%S" "$log_files" 2>/dev/null)"
            echo ""
            count=$((count + 1))
        fi
    done
    
    if [[ "$found_active" == false ]]; then
        echo "❌ No active OpenCode sessions found"
        echo "💡 Available log files:"
        ls -lht "$log_dir"/*.log 2>/dev/null | head -5 | while read -r line; do
            echo "    $line"
        done
        return 1
    fi
    
    echo "💡 Usage: logotmux [number] to view specific session"
    echo "💡 Usage: logotmux to auto-detect current tmux pane"
}

# View OpenCode logs for tmux sessions (auto-detect or select)
logotmux() {
    local log_dir="$HOME/.local/share/opencode/log"
    local follow=true
    local filter_type="all"
    local lines=50
    local session_num=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --static|-s)
                follow=false
                shift
                ;;
            --lines|-n)
                lines="$2"
                shift 2
                ;;
            [0-9]*)
                session_num="$1"
                shift
                ;;
            plugins|errors|performance|hooks|sessions|api|all)
                filter_type="$1"
                shift
                ;;
            *)
                echo "Usage: logotmux [session_number] [filter] [options]"
                echo "Filters: plugins, errors, performance, hooks, sessions, api, all"
                echo "Options:"
                echo "  --lines N, -n N    Lines to show (default: 50)"
                echo "  --static, -s       Static output instead of follow"
                echo ""
                echo "Run 'logocodes' to see all active sessions"
                return 1
                ;;
        esac
    done
    
    local target_log=""
    
    if [[ -n "$session_num" ]]; then
        local count=1
        local pids=$(pgrep -f "opencode" 2>/dev/null)
        for pid in $pids; do
            local log_file=$(lsof -p "$pid" 2>/dev/null | grep "\.log$" | awk '{print $NF}' | grep "$log_dir" | head -1)
            if [[ -n "$log_file" ]]; then
                if [[ "$count" == "$session_num" ]]; then
                    target_log="$log_file"
                    break
                fi
                count=$((count + 1))
            fi
        done
        
        if [[ -z "$target_log" ]]; then
            echo "❌ Session #$session_num not found"
            echo "💡 Run 'logocodes' to see available sessions"
            return 1
        fi
    else
        if [[ -n "$TMUX" ]]; then
            local current_pane_pid=$(tmux display-message -p "#{pane_pid}")
            local opencode_pid=$(pgrep -P "$current_pane_pid" -f "opencode" | head -1)
            
            if [[ -z "$opencode_pid" ]]; then
                opencode_pid=$(ps -o pid,ppid,command | grep opencode | grep -v grep | awk -v ppid="$current_pane_pid" '$2 == ppid {print $1}' | head -1)
            fi
            
            if [[ -n "$opencode_pid" ]]; then
                target_log=$(lsof -p "$opencode_pid" 2>/dev/null | grep "\.log$" | awk '{print $NF}' | grep "$log_dir" | head -1)
            fi
        fi
        
        if [[ -z "$target_log" ]]; then
            target_log=$(find "$log_dir" -type f -name "*.log" -exec ls -t {} + 2>/dev/null | head -n1)
            echo "⚠️ Auto-detection failed, using latest log file"
        else
            echo "✅ Detected current tmux pane's OpenCode session"
        fi
    fi
    
    if [[ -z "$target_log" || ! -f "$target_log" ]]; then
        echo "❌ No log file found"
        return 1
    fi
    
    local filter_pattern=""
    case "$filter_type" in
        "plugins")
            filter_pattern="(service=notification-plugin|service=test-forge|🧭|📍|✨|🔍|🔒|🔔|🌍|Context Engineering|Plugin loaded)"
            ;;
        "errors")
            filter_pattern="(ERROR|WARN|Failed|Exception|⚠️|❌)"
            ;;
        "performance")
            filter_pattern="(Performance|Cache|Optimized|duration|ms|memory)"
            ;;
        "hooks")
            filter_pattern="(tool\.execute\.|hook|Hook|triggered)"
            ;;
        "sessions")
            filter_pattern="(session|Session|ses_|msg_)"
            ;;
        "api")
            filter_pattern="(method=|path=|status|request|response)"
            ;;
        *)
            filter_pattern=".*"
            ;;
    esac
    
    echo "📋 OpenCode Tmux Log Viewer"
    echo "📁 File: $target_log"
    echo "🔍 Filter: $filter_type"
    echo "📏 Lines: $lines"
    if [[ "$follow" == true ]]; then
        echo "🔄 Mode: Follow (Ctrl+C to stop)"
    else
        echo "🔄 Mode: Static"
    fi
    echo ""
    
    if [[ "$follow" == true ]]; then
        if [[ "$filter_pattern" != ".*" ]]; then
            grep -E "$filter_pattern" "$target_log" | tail -n $lines | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
            echo ""
            echo "--- LIVE FEED ---"
            tail -f "$target_log" | grep --line-buffered -E "$filter_pattern" | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
        else
            tail -n $lines "$target_log" | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
            echo ""
            echo "--- LIVE FEED ---"
            tail -f "$target_log" | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
        fi
    else
        if [[ "$filter_pattern" != ".*" ]]; then
            grep -E "$filter_pattern" "$target_log" | tail -n $lines | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
        else
            tail -n $lines "$target_log" | sed \
                -e "s/\(ERROR\)/\x1b[31m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(WARN\)/\x1b[33m\x1b[1m\1\x1b[0m/g" \
                -e "s/\(INFO\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(❌\)/\x1b[31m\1\x1b[0m/g" \
                -e "s/\(✅\)/\x1b[32m\1\x1b[0m/g" \
                -e "s/\(⚠️\)/\x1b[33m\1\x1b[0m/g"
        fi
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

# Secure fzf + nvim integration
fv() {
    local selected_files
    selected_files=$(fzf -m --preview='bat --color=always {}')
    if [[ -n "$selected_files" ]]; then
        echo "$selected_files" | while IFS= read -r file; do
            [[ -f "$file" ]] && nvim "$file"
        done
    fi
}

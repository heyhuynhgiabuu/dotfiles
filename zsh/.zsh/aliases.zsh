# --- Modern Search/Edit Tool Aliases ---
# These aliases optimize your workflow for both AI and human use.
# All tools are cross-platform (macOS/Linux) and installed via Homebrew or apt.
# - rg: Fastest code/text search (ripgrep)
# - fd: Fast file search (find alternative)
# - bat: Syntax-highlighted file preview (cat alternative)
# - delta: Beautiful git diff viewer
# - sd: Fast, safe find & replace (sed alternative)
# - jq: JSON processor
# - fzf: Fuzzy finder (already aliased below)

alias rg='rg --smart-case --color=always'
alias rgrep='rg --smart-case --color=always'  # For compatibility with grep workflows
alias fd='fd --color=always'
alias bat='bat --style=plain --paging=never'
alias delta='delta'
alias sd='sd'
alias jq='jq'

#Basics
alias ll='eza --color=always --icons --long'
alias ls='eza --color=always --icons --long --no-user --git --no-time --no-filesize --no-permissions'
alias cl='clear'
alias rm='rm -i'
alias grep='grep -i --color'
alias gr='./gradlew'
alias stm='tmux source-file ~/.tmux.conf \;'
alias vcf='cd ~/.config/nvim && nvim'


#fzf - Security hardened with proper quoting
alias f='fzf'
alias fp="fzf --preview='bat --color=always {}'"  # preview with bat

# Remove any existing fv alias to avoid conflicts
unalias fv 2>/dev/null || true

# Secure fzf + nvim integration with proper file handling
fv() {
    local selected_files
    selected_files=$(fzf -m --preview='bat --color=always {}')
    if [[ -n "$selected_files" ]]; then
        # Handle selected files safely
        echo "$selected_files" | while IFS= read -r file; do
            [[ -f "$file" ]] && nvim "$file"
        done
    fi
}

#z
alias cd='z'       # Thay thế cd bằng z
alias zz='z -'     # Chuyển đến thư mục trước đó
alias zi='z -i'    # Kích hoạt tìm kiếm nhanh hơn

#editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias mv='vi ~/.config/nvim/init.vim'
alias modvim='vi ~/.config/nvim/init.vim'
alias sshconfig='cat ~/.ssh/config'
alias mssh='vi ~/.ssh/config'
alias modssh='vi ~/.ssh/config'
alias sos='source ~/.zshrc'
alias mos='vi ~/.zshrc'
alias modzsh='vi ~/.zshrc'
alias modbash='vi ~/.zshrc'
alias ma='vi ~/.zsh/aliases.zsh'
alias modalias='vi ~/.zsh/aliases.zsh'
alias mf='vi ~/.zsh/functions.zsh'
alias modfunc='vi ~/.zsh/functions.zsh'
alias modaws='vi ~/.aws/config'
alias hosts='ansible-inventory --graph'
alias pip='pip3'

# Quick Docker commands trong WezTerm
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dclogs='docker compose logs -f'
alias dprune='docker system prune -af' # Prune all unused docker objects

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services' 
alias kdesc='kubectl describe'
alias klogs='kubectl logs -f'
alias h='helm'
alias ctx='kubectx'
alias ns='kubens'
alias kctx='kubectl config get-contexts'
alias kns='kubectl config set-context --current --namespace'


# AWS
alias awsconfig='cat ~/.aws/config'
alias awslogin='aws sso login; aws configure list-profiles'
alias awsprofiles='aws configure list-profiles'

# Git (basic commands)
alias ga='git add'
alias gcms='git commit -m'
alias gst='git status'      # Changed from gs to avoid conflict
alias gpush='git push'      # Changed from gp to avoid conflict  
alias gpull='git pull'      # Changed from gl to avoid conflict
alias gcof='git fetch && git checkout $(git branch | fzf | sed 's/^..//')'
alias gpr='gh pr create'           
alias gprs='gh pr status'          
alias gpl='gh pr list'             
alias gis='gh issue status'        
alias gil='gh issue list'          
alias gic='gh issue create'
alias gclone='gh repo clone'
alias copq='gh copilot suggest'
alias cope='gh copilot explain'
alias copf='gh copilot fix'
alias glog="git log --oneline --graph --decorate"
alias gclean='git_clean_merged'
alias gsecrets='gh api repos/$(git config --get remote.origin.url | sed -E "s#.*github.com[:/](.*)\.git#\1#")/actions/secrets'

# Tmux Layouts
alias tjava='~/dotfiles/scripts/tmux-java-layout.sh'
alias tgo='~/dotfiles/scripts/tmux-go-layout.sh'

# Go-specific aliases
alias gor='go run .'
alias gob='go build .'
alias got='go test ./...'
alias gotv='go test -v ./...'
alias gom='go mod tidy'
alias goi='go install'
alias gof='gofumpt -w .'
alias gol='golangci-lint run'

# --- OpenCode & Serena Integration ---

# Layer 1: Session Management & Basic Commands
alias oc='opencode' # Ensure log directory exists
alias occ='opencode run --continue'           # Continue the last session (USE WITH CAUTION: only if model is the same)
alias ocs='opencode run --share'              # Run and share a session
alias ocup='opencode upgrade'                 # Upgrade to the latest version
alias ochelp='opencode --help'                # Show help
alias ocver='opencode --version'              # Show version

# Layer 1.1: Authentication
alias ocauth='opencode auth'                  # Manage authentication
alias oclogin='opencode auth login'           # Login to providers
alias oclist='opencode auth list'             # List authenticated providers
alias oclogout='opencode auth logout'         # Logout from a provider

# Layer 2: Safe Mode-based Session Starters
# These aliases ALWAYS start a NEW session with the specified powerful model.
alias oc-dev='opencode --mode dev'            # Start NEW session in dev mode (GPT-4.1)
alias oc-plan='opencode --mode plan'          # Start NEW session in plan mode (GPT-4.1)
alias oc-build='opencode --mode build'        # Start NEW session in build mode (Gemini 2.5 Pro)
alias oc-enhanced='opencode --mode enhanced'  # Start NEW session in enhanced mode (Claude Sonnet 4)

# Layer 2.2: Auto-Chrome OpenCode Commands
# These commands automatically ensure Chrome is running before starting OpenCode
oc-chrome() {
    auto_chrome
    if [[ $? -eq 0 ]]; then
        echo "🔄 Starting OpenCode with Chrome ready..."
        opencode "$@"
    else
        echo "❌ Failed to start Chrome - OpenCode not launched"
        return 1
    fi
}

oc-enhanced-chrome() {
    auto_chrome
    if [[ $? -eq 0 ]]; then
        echo "🔄 Starting OpenCode Enhanced mode with Chrome ready..."
        opencode --mode enhanced "$@"
    else
        echo "❌ Failed to start Chrome - OpenCode not launched"
        return 1
    fi
}



# Runs a specific tool in a NEW, non-interactive session using a FREE model.
# Example: ocs-find "my_function"

# Security-hardened OpenCode wrapper functions with input validation
ocs_find() {
    if [[ -z "$1" ]]; then 
        printf "Usage: ocs-find <symbol>\n" >&2
        return 2
    fi
    # Validate input: allow only safe characters for symbol names
    case "$1" in
        *[!a-zA-Z0-9._/:@-]*) 
            printf "Error: Invalid characters in symbol name. Use only alphanumeric, dots, slashes, underscores, colons, @ and hyphens.\n" >&2
            return 1 ;;
        "") 
            printf "Error: Empty symbol name\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 200 ]]; then
        printf "Error: Symbol name too long (max 200 chars)\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena find_symbol $(printf %q "$1")"
}

ocs_refs() {
    if [[ -z "$1" || -z "$2" ]]; then 
        printf "Usage: ocs-refs <symbol> <relative_path>\n" >&2
        return 2
    fi
    # Validate both symbol and path arguments
    case "$1" in
        *[!a-zA-Z0-9._/:@-]*) 
            printf "Error: Invalid characters in symbol name\n" >&2
            return 1 ;;
    esac
    case "$2" in
        *[!a-zA-Z0-9._/:-]*) 
            printf "Error: Invalid characters in path. Use only alphanumeric, dots, slashes, underscores, colons and hyphens.\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 200 || ${#2} -gt 500 ]]; then
        printf "Error: Arguments too long\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena find_referencing_symbols $(printf %q "$1") relative_path:$(printf %q "$2")"
}

ocs_grep() {
    if [[ -z "$1" ]]; then 
        printf "Usage: ocs-grep <pattern>\n" >&2
        return 2
    fi
    if [[ ${#1} -gt 500 ]]; then
        printf "Error: Pattern too long (max 500 chars)\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena search_for_pattern $(printf %q "$1")"
}

ocs_list() {
    if [[ -z "$1" ]]; then 
        printf "Usage: ocs-list <directory>\n" >&2
        return 2
    fi
    # Validate directory path - more restrictive for security
    case "$1" in
        *[!a-zA-Z0-9._/:-]*) 
            printf "Error: Invalid characters in directory path\n" >&2
            return 1 ;;
        *..*)
            printf "Error: Path traversal not allowed\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 500 ]]; then
        printf "Error: Path too long (max 500 chars)\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena list_dir $(printf %q "$1")"
}

ocs_read() {
    if [[ -z "$1" ]]; then 
        printf "Usage: ocs-read <file_path>\n" >&2
        return 2
    fi
    # Extra security for file reading - confirm intent
    case "$1" in
        *[!a-zA-Z0-9._/:-]*) 
            printf "Error: Invalid characters in file path\n" >&2
            return 1 ;;
        *..*)
            printf "Error: Path traversal not allowed\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 500 ]]; then
        printf "Error: Path too long (max 500 chars)\n" >&2
        return 1
    fi
    printf "Reading file: %s\nContinue? [y/N] " "$1"
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) 
            opencode run --model 'github-copilot/gpt-4.1' "@read $(printf %q "$1")" ;;
        *) 
            printf "Cancelled\n" ;;
    esac
}

# Layer 3.1: Serena Memory Management (using FREE model) - Security Hardened
ocs_memw() { 
    if [[ -z "$1" || -z "$2" ]]; then 
        printf "Usage: ocs-memw <memory_name> <content>\n" >&2
        return 2
    fi
    # Validate memory name (alphanumeric, underscore, hyphen only)
    case "$1" in
        *[!a-zA-Z0-9._-]*) 
            printf "Error: Memory name contains invalid characters\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 100 || ${#2} -gt 2000 ]]; then
        printf "Error: Memory name or content too long\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena write_memory $(printf %q "$1") content:$(printf %q "$2")"
}

ocs_memr() { 
    if [[ -z "$1" ]]; then 
        printf "Usage: ocs-memr <memory_name>\n" >&2
        return 2
    fi
    case "$1" in
        *[!a-zA-Z0-9._-]*) 
            printf "Error: Memory name contains invalid characters\n" >&2
            return 1 ;;
    esac
    if [[ ${#1} -gt 100 ]]; then
        printf "Error: Memory name too long\n" >&2
        return 1
    fi
    opencode run --model 'github-copilot/gpt-4.1' "@serena read_memory $(printf %q "$1")"
}

ocs_memlist() { opencode run --model 'github-copilot/gpt-4.1' "@serena list_memories"; }

# Create aliases for the hyphenated versions (backward compatibility)
alias ocs-find='ocs_find'
alias ocs-refs='ocs_refs'
alias ocs-grep='ocs_grep'
alias ocs-list='ocs_list'
alias ocs-read='ocs_read'
alias ocs-memw='ocs_memw'
alias ocs-memr='ocs_memr'
alias ocs-memlist='ocs_memlist'

# Layer 3.2: General Purpose Quick Commands (using FREE model)
oc_explain() { opencode run --model 'github-copilot/gpt-4.1' "Explain this: $1"; }
oc_fix() { opencode run --model 'github-copilot/gpt-4.1' "Fix this code: $1"; }
oc_test() { opencode run "Write tests for this: $1"; }

# Aliases for backward compatibility
alias oc-explain='oc_explain'
alias oc-fix='oc_fix'
alias oc-test='oc_test'

# Layer 4: Performance and Development Tools
alias brew-perf="$HOME/dotfiles/scripts/dev/brew-perf.sh"     # Optimized Homebrew operations
alias git-perf="$HOME/dotfiles/scripts/dev/git-perf.sh"       # Cached git operations
alias bp="brew-perf"                                          # Short alias for brew performance
alias gp="git-perf"                                           # Short alias for git performance

# Performance aliases for common operations
alias gs="git-perf status"                                    # Cached git status
alias gl="git-perf log"                                       # Cached git log
alias gf="git-perf fetch"                                     # Smart git fetch
alias ghealth="git-perf health"                               # Git repository health check
alias gopt="git-perf optimize"                                # Apply git performance settings
alias grefresh="git-perf refresh"                             # Force refresh all caches
alias gcleanup="git-perf cleanup"                             # Clean git caches
alias brewup="brew-perf update"                               # Smart brew update
alias brewclean="brew-perf cleanup"                           # Optimized brew cleanup

# Development workflow optimization
alias dev-status="git-perf status && brew-perf status"       # Combined status check
alias dev-update="git-perf fetch && brew-perf update"        # Update everything

# Auto-open Chrome for MCP Chrome Bridge usage
# Ensures Chrome is running before MCP operations, using your regular browser
# with all your extensions, logins, and settings intact
auto_chrome() {
    echo "🔍 Checking Chrome status..."
    
    # Check if Chrome is already running
    if pgrep -f "Google Chrome" >/dev/null 2>&1; then
        echo "✅ Chrome is already running"
        echo "🔗 Ready for MCP Chrome Bridge operations"
        return 0
    fi
    
    echo "🚀 Starting Chrome for MCP operations..."
    
    # Detect platform and launch Chrome
    case "$(uname -s)" in
        Darwin)
            if command -v "open" >/dev/null; then
                open -a "Google Chrome"
                echo "📱 Launched Chrome on macOS"
            else
                echo "❌ Error: 'open' command not found on macOS" >&2
                return 1
            fi
            ;;
        Linux)
            if command -v google-chrome >/dev/null 2>&1; then
                nohup google-chrome >/dev/null 2>&1 &
                echo "🐧 Launched google-chrome on Linux"
            elif command -v google-chrome-stable >/dev/null 2>&1; then
                nohup google-chrome-stable >/dev/null 2>&1 &
                echo "🐧 Launched google-chrome-stable on Linux"
            elif command -v chromium >/dev/null 2>&1; then
                nohup chromium >/dev/null 2>&1 &
                echo "🐧 Launched chromium on Linux"
            elif command -v chromium-browser >/dev/null 2>&1; then
                nohup chromium-browser >/dev/null 2>&1 &
                echo "🐧 Launched chromium-browser on Linux"
            else
                echo "❌ Error: No Chrome/Chromium found on Linux" >&2
                return 1
            fi
            ;;
        *)
            echo "❌ Error: Unsupported OS for auto-chrome" >&2
            return 1
            ;;
    esac
    
    # Wait for Chrome to start
    echo "⏳ Waiting for Chrome to initialize..."
    sleep 3
    
    # Verify Chrome started
    if pgrep -f "Google Chrome\|google-chrome\|chromium" >/dev/null 2>&1; then
        echo "✅ Chrome started successfully"
        echo "🔗 Ready for MCP Chrome Bridge operations"
        echo "💡 Tip: Use 'oc-enhanced' or other OpenCode commands with Chrome tools"
    else
        echo "⚠️  Chrome may still be starting..."
        echo "💡 Check manually or try again in a few seconds"
    fi
}

# Shortcut aliases
alias auto-chrome='auto_chrome'
alias ac='auto_chrome'


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

# === OPENCODE ALIASES ===
# Standard OpenCode with colors
alias oc="FORCE_COLOR=1 opencode"

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


# Password management
alias pcopy='pass -c'
alias pgen='pass generate'
alias pls='pass ls'
alias pedit='pass edit'
alias pinsert='pass insert'
alias prm='pass rm'
alias pfind='pass find'
alias pshow='pass show'
alias pmv='pass mv'
alias pcp='pass cp'
alias pgit='pass git'
alias pinit='pass init'
alias pgrep='pass grep'
alias phelp='pass help'

# GPG Management
alias gpg-restart='gpgconf --kill gpg-agent && gpg-agent --daemon'
alias gpg-status='gpg-agent --status'
alias gpg-stop='gpgconf --kill gpg-agent'
alias gpg-list-keys='gpg --list-secret-keys --keyid-format LONG'
alias gpg-list-public='gpg --list-keys --keyid-format LONG'
alias gpg-export='gpg --armor --export'
alias gpg-import='gpg --import'
alias gpg-delete='gpg --delete-secret-key'
alias gpg-trust='gpg --edit-key'


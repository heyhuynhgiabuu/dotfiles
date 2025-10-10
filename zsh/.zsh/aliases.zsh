# UNIFIED ALIAS CONFIGURATION
# All aliases organized by category for better maintenance

# =============================================================================
# MODERN TOOLS (Core workflow)
# =============================================================================
alias rg='rg --smart-case --color=always'
alias rgrep='rg --smart-case --color=always'
alias fd='fd --color=always'
alias bat='bat --style=plain --paging=never'
alias delta='delta'
alias sd='sd'
alias jq='jq'

# =============================================================================
# NAVIGATION & FILES
# =============================================================================
alias cd='z'          # Use zoxide for smart directory jumping
alias ..='cd ..'
alias ...='cd ../..'
alias ll='eza --color=always --icons --long'
alias ls='eza --color=always --icons --long --no-user --git --no-time --no-filesize --no-permissions'
alias cl='clear'
alias rm='rm -i'

# =============================================================================
# EDITORS
# =============================================================================
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Quick config edits
alias vcf='cd ~/.config/nvim && nvim'
alias mos='vi ~/.zshrc'
alias ma='vi ~/.zsh/aliases.zsh'
alias mf='vi ~/.zsh/functions.zsh'
alias mssh='vi ~/.ssh/config'
alias sos='source ~/.zshrc'

# =============================================================================
# OPENCODE
# =============================================================================
alias oc="FORCE_COLOR=1 opencode"
alias ocd="FORCE_COLOR=1 opencode --directory"

# =============================================================================
# ENV FILES
# =============================================================================
# Manual .env sourcing (better than annoying auto-prompts)
alias loadenv='[ -f .env ] && export $(cat .env | grep -v "^#" | xargs) && echo "✅ Loaded .env" || echo "❌ No .env file found"'
alias showenv='[ -f .env ] && cat .env || echo "❌ No .env file found"'

# =============================================================================
# FUZZY FINDER (FZF)
# =============================================================================
alias f='fzf'
alias fp="fzf --preview='bat --color=always {}'"

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

# =============================================================================
# GIT
# =============================================================================
alias ga='git add'
alias gcms='git commit -m'
alias gst='git status'
alias gpush='git push'
alias gpull='git pull'
alias glog="git log --oneline --graph --decorate"
alias gclean='git_clean_merged'

# GitHub CLI
alias gpr='gh pr create'
alias gprs='gh pr status'
alias gpl='gh pr list'
alias gis='gh issue status'
alias gil='gh issue list'
alias gic='gh issue create'
alias gclone='gh repo clone'

# GitHub Copilot
alias copq='gh copilot suggest'
alias cope='gh copilot explain'
alias copf='gh copilot fix'

# Advanced git operations
alias gcof='git fetch && git checkout $(git branch | fzf | sed '\''s/^..//'\'')'
alias gsecrets='gh api repos/$(git config --get remote.origin.url | sed -E "s#.*github.com[:/](.*)\.git#\1#")/actions/secrets'

# =============================================================================
# DOCKER
# =============================================================================
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dclogs='docker compose logs -f'
alias dprune='docker system prune -af'

# =============================================================================
# KUBERNETES
# =============================================================================
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

# =============================================================================
# AWS
# =============================================================================
alias awsconfig='cat ~/.aws/config'
alias awslogin='aws sso login; aws configure list-profiles'
alias awsprofiles='aws configure list-profiles'
alias modaws='vi ~/.aws/config'

# =============================================================================
# GO DEVELOPMENT
# =============================================================================
alias gor='go run .'
alias gob='go build .'
alias got='go test ./...'
alias gotv='go test -v ./...'
alias gom='go mod tidy'
alias goi='go install'
alias gof='gofumpt -w .'
alias gol='golangci-lint run'
alias gr='./gradlew'

# =============================================================================
# PASSWORD MANAGEMENT
# =============================================================================
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

# =============================================================================
# GPG MANAGEMENT
# =============================================================================
alias gpg-restart='gpgconf --kill gpg-agent && gpg-agent --daemon'
alias gpg-status='gpg-agent --status'
alias gpg-stop='gpgconf --kill gpg-agent'
alias gpg-list-keys='gpg --list-secret-keys --keyid-format LONG'
alias gpg-list-public='gpg --list-keys --keyid-format LONG'
alias gpg-export='gpg --armor --export'
alias gpg-import='gpg --import'
alias gpg-delete='gpg --delete-secret-key'
alias gpg-trust='gpg --edit-key'

# =============================================================================
# TMUX LAYOUTS
# =============================================================================
alias tjava='~/dotfiles/scripts/tmux-java-layout.sh'
alias tgo='~/dotfiles/scripts/tmux-go-layout.sh'
alias stm='tmux source-file ~/.tmux.conf \;'

# =============================================================================
# MISCELLANEOUS
# =============================================================================
alias grep='grep -i --color'
alias sshconfig='cat ~/.ssh/config'
alias hosts='ansible-inventory --graph'
alias pip='pip3'
alias ports='lsof -i -P | grep LISTEN'

# Zoxide shortcuts
alias zz='z -'
alias zi='z -i'

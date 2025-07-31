#Basics
alias ll='eza --color=always --icons --long'
alias ls='eza --color=always --icons --long --no-user --git --no-time --no-filesize --no-permissions'
alias cl='clear'
alias rm='rm -i'
alias grep='grep -i --color'
alias gr='./gradlew'
alias stm='tmux source-file ~/.tmux.conf \;'
alias vcf='cd ~/.config/nvim && nvim'


#fzf
alias f='fzf'
alias fp='fzf --preview='bat --color=always {}'' # preview with bat
alias fv='nvim $(fzf -m --preview='bat --color=always {}')' # open neovim with select file by tab

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
alias dps='docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}''
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

# Git
alias ga='git add'
alias gcms='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
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
alias oc='opencode'                           # Start OpenCode TUI in current directory
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

# Layer 3: Cost-Effective Quick-Fire Commands
# Runs a specific tool in a NEW, non-interactive session using a FREE model.
# Example: ocs-find "my_function"
ocs-find() { opencode run --model 'github-copilot/gpt-4.1' "@serena find_symbol \"$1\""; }
ocs-refs() { opencode run --model 'github-copilot/gpt-4.1' "@serena find_referencing_symbols \"$1\" relative_path:\"$2\""; }
ocs-grep() { opencode run --model 'github-copilot/gpt-4.1' "@serena search_for_pattern \"$1\""; }
ocs-list() { opencode run --model 'github-copilot/gpt-4.1' "@serena list_dir \"$1\""; }
ocs-read() { opencode run --model 'github-copilot/gpt-4.1' "@read \"$1\""; }

# Layer 3.1: Serena Memory Management (using FREE model)
ocs-memw() { opencode run --model 'github-copilot/gpt-4.1' "@serena write_memory '$1' content:'$2'"; }
ocs-memr() { opencode run --model 'github-copilot/gpt-4.1' "@serena read_memory '$1'"; }
ocs-memlist() { opencode run --model 'github-copilot/gpt-4.1' "@serena list_memories"; }

# Layer 3.2: General Purpose Quick Commands (using FREE model)
oc-explain() { opencode run --model 'github-copilot/gpt-4.1' "Explain this: $1"; }
oc-fix() { opencode run --model 'github-copilot/gpt-4.1' "Fix this code: $1"; }
oc-test() { opencode run "Write tests for this: $1"; }


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
alias dps='docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}''
alias dlogs='docker logs -f'
alias dclogs='docker compose logs -f'

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

# Tmux
alias tjava='~/dotfiles/scripts/tmux-java-layout.sh'

# Go-specific aliases
alias gor='go run .'
alias gob='go build .'
alias got='go test ./...'
alias gotv='go test -v ./...'
alias gom='go mod tidy'
alias goi='go install'
alias gof='gofumpt -w .'
alias gol='golangci-lint run'

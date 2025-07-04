#Basics
alias ll="eza --color=always --icons --long"
alias ls="eza --color=always --icons --long --no-user --git --no-time --no-filesize --no-permissions"
alias cd="z"       # Thay thế cd bằng z
alias zz="z -"     # Chuyển đến thư mục trước đó
alias zi="z -i"           # Kích hoạt tìm kiếm nhanh hơn
alias vi='nvim'
alias vim='nvim'
alias modvim='vi ~/.config/nvim/init.vim'
alias sshconfig='cat ~/.ssh/config'
alias modssh='vi ~/.ssh/config'
alias modzsh='vi ~/.zshrc'
alias modbash='vi ~/.zshrc'
alias modalias='vi ~/.zsh/aliases.zsh'
alias modfunc='~/.zsh/functions.zsh'
alias modaws='vi ~/.aws/config'
alias hosts='ansible-inventory --graph'
alias grep='grep -i --color'
alias pip='pip3'

# Kubernetes
alias k='kubectl'
alias h='helm'
alias ctx='kubectx'
alias ns='kubens'
alias contexts='kubectl config get-contexts'

# AWS
alias awsconfig='cat ~/.aws/config'
alias awslogin='aws sso login; aws configure list-profiles'
alias awsprofiles='aws configure list-profiles'

# Git
alias gs="git status"
alias gp="git push"
alias gl="git pull"

# Tmux
alias tjava="~/dotfiles/scripts/tmux-java-layout.sh"

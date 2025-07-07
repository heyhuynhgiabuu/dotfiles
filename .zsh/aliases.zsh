#Basics
alias ll="eza --color=always --icons --long"
alias ls="eza --color=always --icons --long --no-user --git --no-time --no-filesize --no-permissions"
alias cl="clear"
alias rm="rm -i"
alias grep="grep -i --color"
alias gr="./gradlew"
alias stm="tmux source-file ~/.tmux.conf \;"
alias vcf="cd ~/.config/nvim && nvim"


#fzf
alias f="fzf"
alias fp='fzf --preview="bat --color=always {}"' # preview with bat
alias fv='nvim $(fzf -m --preview="bat --color=always {}")' # open neovim with select file by tab

#z
alias cd="z"       # Thay thế cd bằng z
alias zz="z -"     # Chuyển đến thư mục trước đó
alias zi="z -i"    # Kích hoạt tìm kiếm nhanh hơn

#editor
alias v="nvim"
alias vi='nvim'
alias vim="nvim"
alias mv="vi ~/.config/nvim/init.vim"
alias modvim="vi ~/.config/nvim/init.vim"
alias sshconfig="cat ~/.ssh/config"
alias mssh="vi ~/.ssh/config"
alias modssh="vi ~/.ssh/config"
alias sos="source ~/.zshrc"
alias mos="vi ~/.zshrc"
alias modzsh="vi ~/.zshrc"
alias modbash="vi ~/.zshrc"
alias ma="vi ~/.zsh/aliases.zsh"
alias modalias="vi ~/.zsh/aliases.zsh"
alias mf="vi ~/.zsh/functions.zsh"
alias modfunc="vi ~/.zsh/functions.zsh"
alias modaws="vi ~/.aws/config"
alias hosts="ansible-inventory --graph"
alias pip="pip3"

# Kubernetes
alias k="kubectl"
alias h="helm"
alias ctx="kubectx"
alias ns="kubens"
alias contexts="kubectl config get-contexts"

# AWS
alias awsconfig="cat ~/.aws/config"
alias awslogin="aws sso login; aws configure list-profiles"
alias awsprofiles="aws configure list-profiles"

# Git
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias gcof="git fetch && git checkout $(git branch | fzf | sed "s/^..//")"


# Tmux
alias tjava="~/dotfiles/scripts/tmux-java-layout.sh"

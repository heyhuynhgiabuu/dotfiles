# =============================================================================
# 🎯 ADVANCED COMPLETION FUNCTIONS
# =============================================================================

# Enhanced Go command completions
_go_enhanced() {
    local -a subcmds
    subcmds=(
        'build:compile packages and dependencies'
        'run:compile and run Go program'
        'test:test packages'
        'fmt:gofmt (reformat) package sources'
        'get:download and install packages and dependencies'
        'install:compile and install packages and dependencies'
        'list:list packages or modules'
        'mod:module maintenance'
        'work:workspace maintenance'
        'clean:remove object files and cached files'
        'doc:show documentation for package or symbol'
        'env:print Go environment information'
        'bug:start a bug report'
        'fix:update packages to use new APIs'
        'generate:generate Go files by processing source'
        'tool:run specified go tool'
        'version:print Go version'
        'vet:report likely mistakes in packages'
    )
    
    case $words[1] in
        mod)
            local -a mod_subcmds
            mod_subcmds=(
                'download:download modules to local cache'
                'edit:edit go.mod from tools or scripts'
                'graph:print module requirement graph'
                'init:initialize new module in current directory'
                'tidy:add missing and remove unused modules'
                'vendor:make vendored copy of dependencies'
                'verify:verify dependencies have expected content'
                'why:explain why packages or modules are needed'
            )
            _describe 'go mod commands' mod_subcmds
            ;;
        test)
            _arguments \
                '-v[verbose output]' \
                '-race[enable data race detection]' \
                '-cover[enable coverage analysis]' \
                '*:test packages:_go_packages'
            ;;
        *)
            _describe 'go commands' subcmds
            ;;
    esac
}

# Docker command completions
_docker_enhanced() {
    local -a docker_cmds
    docker_cmds=(
        'run:run a command in a new container'
        'build:build an image from a Dockerfile'
        'pull:pull an image or a repository from a registry'
        'push:push an image or a repository to a registry'
        'images:list images'
        'ps:list containers'
        'exec:run a command in a running container'
        'logs:fetch the logs of a container'
        'stop:stop one or more running containers'
        'start:start one or more stopped containers'
        'restart:restart one or more containers'
        'rm:remove one or more containers'
        'rmi:remove one or more images'
        'inspect:return low-level information on Docker objects'
        'stats:display a live stream of container(s) resource usage'
        'top:display the running processes of a container'
        'volume:manage volumes'
        'network:manage networks'
        'system:manage Docker'
    )
    _describe 'docker commands' docker_cmds
}

# Git enhanced completions
_git_enhanced() {
    local -a git_cmds
    git_cmds=(
        'add:add file contents to the index'
        'commit:record changes to the repository'
        'push:update remote refs along with associated objects'
        'pull:fetch from and integrate with another repository'
        'status:show the working tree status'
        'log:show commit logs'
        'diff:show changes between commits, commit and working tree'
        'branch:list, create, or delete branches'
        'checkout:switch branches or restore working tree files'
        'merge:join two or more development histories together'
        'rebase:reapply commits on top of another base tip'
        'reset:reset current HEAD to the specified state'
        'stash:stash the changes in a dirty working directory'
        'tag:create, list, delete or verify a tag object'
        'remote:manage set of tracked repositories'
        'clone:clone a repository into a new directory'
        'init:create an empty Git repository'
        'fetch:download objects and refs from another repository'
    )
    _describe 'git commands' git_cmds
}

# Register enhanced completions
compdef _go_enhanced go
compdef _docker_enhanced docker
compdef _git_enhanced git

# =============================================================================
# 🎯 SMART COMPLETION BEHAVIOR
# =============================================================================

# Auto-completion on first tab, menu on second
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' expand prefix suffix

# =============================================================================
# 🚀 COMMAND SUGGESTIONS & HISTORY
# =============================================================================

# Enhanced history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind arrow keys for history search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# History completion with menu
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# =============================================================================
# 🎨 ENHANCED COMPLETION STYLING
# =============================================================================

# Enhanced menu selection with VS Code-like appearance
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# VS Code-style color scheme with background highlights
zstyle ':completion:*' list-colors \
    'di=1;34:ln=1;36:so=1;35:ex=1;32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# Enhanced completion descriptions with VS Code-style formatting
zstyle ':completion:*:descriptions' format '%K{blue}%F{white}%B ▶ %d %b%f%k'
zstyle ':completion:*:messages' format '%K{magenta}%F{white}%B ◆ %d %b%f%k'
zstyle ':completion:*:warnings' format '%K{red}%F{white}%B ✗ No matches found %b%f%k'
zstyle ':completion:*:corrections' format '%K{yellow}%F{black}%B ◉ %d (errors: %e) %b%f%k'

# Group organization with better visual separation
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*' group-name ''

# Enhanced completion menu appearance
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%K{cyan}%F{black}%B — %d —%b%f%k'

# Command-specific styling
zstyle ':completion:*:*:go:*:descriptions' format '%K{green}%F{white}%B Go Commands %b%f%k'
zstyle ':completion:*:*:docker:*:descriptions' format '%K{blue}%F{white}%B Docker Commands %b%f%k'
zstyle ':completion:*:*:git:*:descriptions' format '%K{magenta}%F{white}%B Git Commands %b%f%k'

# File completion with enhanced visuals
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-dirs-first true

# Process completion styling
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;32'

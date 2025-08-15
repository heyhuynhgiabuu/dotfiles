#!/usr/bin/env sh

# Go development environment setup - cross-platform (macOS & Linux)
# Installs Go and development tools
# Usage: bash scripts/setup-go.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly GO_ALIASES=(
    'alias gor="go run ."'
    'alias gob="go build ."'
    'alias got="go test ./..."'
    'alias gotv="go test -v ./..."'
    'alias gom="go mod tidy"'
    'alias goi="go install"'
    'alias gof="gofumpt -w ."'
    'alias gol="golangci-lint run"'
)

main() {
    log_header "Setting up Go development environment"
    
    # Install Go if needed
    install_go
    
    # Setup Go workspace
    setup_go_workspace
    
    # Install Go development tools
    install_go_development_tools
    
    # Add Go environment to shell
    configure_shell_environment
    
    show_completion_info
}

install_go() {
    if ! cmd_exists go; then
        log_warning "Go is not installed. Installing..."
        install_package "go"
    else
        log_success "Go is already installed: $(go version)"
    fi
}

setup_go_workspace() {
    log_info "Setting up Go workspace..."
    
    setup_go_environment
    
    # Create user-specific directory structure
    local username
    username=$(git config user.name 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    if [[ -n "$username" ]]; then
        mkdir -p "${HOME}/go/src/github.com/${username}"
        log_success "Created workspace for github.com/${username}"
    fi
}

install_go_development_tools() {
    log_info "Installing Go development tools..."
    
    if cmd_exists go; then
        install_go_tools
    else
        log_error "Go installation failed, skipping tools installation"
        return 1
    fi
}

configure_shell_environment() {
    log_info "Configuring shell environment..."
    
    local zshrc_file="${DOTFILES_DIR}/zsh/.zshrc"
    
    # Check if Go paths are already configured
    if ! grep -q "GOPATH" "$zshrc_file" 2>/dev/null; then
        log_step "Adding Go environment variables to .zshrc..."
        
        cat >> "$zshrc_file" << 'EOF'

# Go development environment
export GOPATH=$HOME/go
export GOROOT=$(go env GOROOT 2>/dev/null || echo "/usr/local/go")
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

EOF
        
        # Add Go aliases
        for alias_cmd in "${GO_ALIASES[@]}"; do
            echo "$alias_cmd" >> "$zshrc_file"
        done
        
        echo >> "$zshrc_file"
        
        log_success "Go environment added to .zshrc"
    else
        log_success "Go environment already configured in .zshrc"
    fi
}

show_completion_info() {
    echo
    log_success "Go development setup complete!"
    echo
    log_info "Next steps:"
    echo "  1. Run: source ~/.zshrc"
    echo "  2. Create your first Go project:"
    echo "     mkdir ~/go/src/hello && cd ~/go/src/hello"
    echo "  3. Start coding with: nvim main.go"
    echo "  4. Use tmux layout: tmux-go-layout"
    echo
    log_info "Available Go aliases:"
    printf "  %s
" "${GO_ALIASES[@]}" | sed 's/alias /  /'
}

# Execute main function
main "$@"#!/bin/bash

# Go development environment setup - cross-platform (macOS & Linux)
# Installs Go and development tools
# Usage: bash scripts/setup-go.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly GO_ALIASES=(
    'alias gor="go run ."'
    'alias gob="go build ."'
    'alias got="go test ./..."'
    'alias gotv="go test -v ./..."'
    'alias gom="go mod tidy"'
    'alias goi="go install"'
    'alias gof="gofumpt -w ."'
    'alias gol="golangci-lint run"'
)

main() {
    log_header "Setting up Go development environment"
    
    # Install Go if needed
    install_go
    
    # Setup Go workspace
    setup_go_workspace
    
    # Install Go development tools
    install_go_development_tools
    
    # Add Go environment to shell
    configure_shell_environment
    
    show_completion_info
}

install_go() {
    if ! cmd_exists go; then
        log_warning "Go is not installed. Installing..."
        install_package "go"
    else
        log_success "Go is already installed: $(go version)"
    fi
}

setup_go_workspace() {
    log_info "Setting up Go workspace..."
    
    setup_go_environment
    
    # Create user-specific directory structure
    local username
    username=$(git config user.name 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    if [[ -n "$username" ]]; then
        mkdir -p "${HOME}/go/src/github.com/${username}"
        log_success "Created workspace for github.com/${username}"
    fi
}

install_go_development_tools() {
    log_info "Installing Go development tools..."
    
    if cmd_exists go; then
        install_go_tools
    else
        log_error "Go installation failed, skipping tools installation"
        return 1
    fi
}

configure_shell_environment() {
    log_info "Configuring shell environment..."
    
    local zshrc_file="${DOTFILES_DIR}/zsh/.zshrc"
    
    # Check if Go paths are already configured
    if ! grep -q "GOPATH" "$zshrc_file" 2>/dev/null; then
        log_step "Adding Go environment variables to .zshrc..."
        
        cat >> "$zshrc_file" << 'EOF'

# Go development environment
export GOPATH=$HOME/go
export GOROOT=$(go env GOROOT 2>/dev/null || echo "/usr/local/go")
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

EOF
        
        # Add Go aliases
        for alias_cmd in "${GO_ALIASES[@]}"; do
            echo "$alias_cmd" >> "$zshrc_file"
        done
        
        echo >> "$zshrc_file"
        
        log_success "Go environment added to .zshrc"
    else
        log_success "Go environment already configured in .zshrc"
    fi
}

show_completion_info() {
    echo
    log_success "Go development setup complete!"
    echo
    log_info "Next steps:"
    echo "  1. Run: source ~/.zshrc"
    echo "  2. Create your first Go project:"
    echo "     mkdir ~/go/src/hello && cd ~/go/src/hello"
    echo "  3. Start coding with: nvim main.go"
    echo "  4. Use tmux layout: tmux-go-layout"
    echo
    log_info "Available Go aliases:"
    printf "  %s
" "${GO_ALIASES[@]}" | sed 's/alias /  /'
}

# Execute main function
main "$@"
#!/usr/bin/env sh

# Enhanced Development Environment Setup - cross-platform (macOS & Linux)
# Sets up Go and Java development with enhanced autocompletion
# Usage: bash scripts/setup-enhanced-dev.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly WORKSPACE_BASE="${HOME}/Development"
readonly WORKSPACE_DIRS=(
    "go"
    "java"
    "projects"
    "go/bin"
    "go/src"
    "go/pkg"
    "java/projects"
    "java/libraries"
)

main() {
    log_header "Setting up enhanced Go and Java development environment"
    
    # Check and install prerequisites
    check_prerequisites
    
    # Install development tools
    install_go_tools_enhanced
    setup_java_environment_enhanced
    
    # Create workspace directories
    create_development_workspaces
    
    # Sync Neovim plugins
    sync_neovim_plugins
    
    # Test the setup
    test_enhanced_setup
    
    show_enhanced_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Go
    if ! cmd_exists go; then
        log_error "Go is not installed. Please install Go first."
        log_info "Visit: https://golang.org/dl/"
        exit 1
    else
        log_success "Go $(go version | cut -d' ' -f3) found"
    fi
    
    # Check and install Java
    if ! cmd_exists java; then
        log_warning "Java not found. Installing..."
        setup_java_environment "17"
    else
        log_success "Java $(java -version 2>&1 | head -n 1) found"
    fi
    
    # Check and install Node.js
    if ! cmd_exists node; then
        log_warning "Node.js not found. Installing..."
        install_package "node"
    else
        log_success "Node.js $(node -v) found"
    fi
}

install_go_tools_enhanced() {
    log_info "Installing enhanced Go development tools..."
    
    if cmd_exists go; then
        # Install standard Go tools plus additional ones
        local enhanced_tools=(
            "golang.org/x/tools/gopls@latest"
            "golang.org/x/tools/cmd/goimports@latest"
            "mvdan.cc/gofumpt@latest"
            "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
            "github.com/go-delve/delve/cmd/dlv@latest"
            "github.com/cweill/gotests/gotests@latest"
            "github.com/josharian/impl@latest"
            "github.com/fatih/gomodifytags@latest"
        )
        
        for tool in "${enhanced_tools[@]}"; do
            log_step "Installing $(basename "$tool" | cut -d'@' -f1)..."
            go install "$tool"
        done
        
        log_success "Enhanced Go tools installed successfully"
    else
        log_error "Go installation failed, skipping tools installation"
        return 1
    fi
}

setup_java_environment_enhanced() {
    log_info "Setting up enhanced Java development environment..."
    
    # Setup Java environment with version detection
    setup_java_environment "17"
    
    # Install Maven if not present
    if ! cmd_exists mvn; then
        log_warning "Maven not found. Installing..."
        install_package "maven"
    else
        log_success "Maven $(mvn -version | head -n 1 | cut -d' ' -f3) found"
    fi
    
    # Install Gradle if not present
    if ! cmd_exists gradle; then
        log_warning "Gradle not found. Installing..."
        install_package "gradle"
    else
        local gradle_version
        gradle_version=$(gradle -version 2>/dev/null | grep "Gradle" | cut -d' ' -f2 || echo "unknown")
        log_success "Gradle $gradle_version found"
    fi
}

create_development_workspaces() {
    log_info "Creating development workspaces..."
    
    for dir in "${WORKSPACE_DIRS[@]}"; do
        mkdir -p "${WORKSPACE_BASE}/$dir"
    done
    
    log_success "Development directories created in $WORKSPACE_BASE"
}

sync_neovim_plugins() {
    log_info "Syncing Neovim plugins..."
    
    if cmd_exists nvim; then
        # Start Neovim with plugin sync commands
        log_step "Running Lazy sync..."
        nvim --headless "+Lazy! sync" "+qa" 2>/dev/null || log_warning "Lazy sync may have issues"
        
        # Install/update Mason packages
        log_step "Running MasonInstallAll..."
        nvim --headless "+MasonInstallAll" "+qa" 2>/dev/null || log_warning "MasonInstallAll may need manual run"
        
        log_success "Neovim plugins sync attempted"
    else
        log_error "Neovim not found - skipping plugin sync"
    fi
}

test_enhanced_setup() {
    log_info "Testing the enhanced development setup..."
    
    # Test Go tools
    test_go_tools_enhanced
    
    # Test Java tools
    test_java_tools_enhanced
}

test_go_tools_enhanced() {
    log_info "Testing Go tools..."
    
    local go_tools=("gopls" "gofumpt" "dlv" "golangci-lint")
    
    for tool in "${go_tools[@]}"; do
        if cmd_exists "$tool"; then
            log_success "$tool is working"
        else
            log_warning "$tool not found in PATH"
        fi
    done
}

test_java_tools_enhanced() {
    log_info "Testing Java tools..."
    
    if [[ -n "$JAVA_HOME" ]]; then
        log_success "JAVA_HOME is set to: $JAVA_HOME"
    else
        log_warning "JAVA_HOME is not set"
    fi
    
    local java_tools=("mvn" "gradle")
    
    for tool in "${java_tools[@]}"; do
        if cmd_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warning "$tool not found"
        fi
    done
}

show_enhanced_completion_info() {
    echo
    log_success "Enhanced development environment setup completed!"
    echo
    log_info "Next Steps:"
    echo "1. Restart your terminal or source ~/.zshrc"
    echo "2. Open Neovim and test autocompletion:"
    echo "   - Create a Go file and type 'fmt.' - you should see suggestions"
    echo "   - Create a Java file and type 'System.' - you should see suggestions"
    echo "3. Test Go tools with:"
    echo "   - <leader>gr (Go run)"
    echo "   - <leader>gt (Go test)"
    echo "   - <leader>gf (Go format)"
    echo "4. Test Java tools with:"
    echo "   - <leader>jo (Java organize imports)"
    echo "   - <leader>jf (Java quick fix)"
    echo
    log_warning "Note: Some features may require restarting Neovim"
    echo
    log_info "Development workspaces created in: $WORKSPACE_BASE"
}

# Execute main function
main "$@"#!/bin/bash

# Enhanced Development Environment Setup - cross-platform (macOS & Linux)
# Sets up Go and Java development with enhanced autocompletion
# Usage: bash scripts/setup-enhanced-dev.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly WORKSPACE_BASE="${HOME}/Development"
readonly WORKSPACE_DIRS=(
    "go"
    "java"
    "projects"
    "go/bin"
    "go/src"
    "go/pkg"
    "java/projects"
    "java/libraries"
)

main() {
    log_header "Setting up enhanced Go and Java development environment"
    
    # Check and install prerequisites
    check_prerequisites
    
    # Install development tools
    install_go_tools_enhanced
    setup_java_environment_enhanced
    
    # Create workspace directories
    create_development_workspaces
    
    # Sync Neovim plugins
    sync_neovim_plugins
    
    # Test the setup
    test_enhanced_setup
    
    show_enhanced_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Go
    if ! cmd_exists go; then
        log_error "Go is not installed. Please install Go first."
        log_info "Visit: https://golang.org/dl/"
        exit 1
    else
        log_success "Go $(go version | cut -d' ' -f3) found"
    fi
    
    # Check and install Java
    if ! cmd_exists java; then
        log_warning "Java not found. Installing..."
        setup_java_environment "17"
    else
        log_success "Java $(java -version 2>&1 | head -n 1) found"
    fi
    
    # Check and install Node.js
    if ! cmd_exists node; then
        log_warning "Node.js not found. Installing..."
        install_package "node"
    else
        log_success "Node.js $(node -v) found"
    fi
}

install_go_tools_enhanced() {
    log_info "Installing enhanced Go development tools..."
    
    if cmd_exists go; then
        # Install standard Go tools plus additional ones
        local enhanced_tools=(
            "golang.org/x/tools/gopls@latest"
            "golang.org/x/tools/cmd/goimports@latest"
            "mvdan.cc/gofumpt@latest"
            "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
            "github.com/go-delve/delve/cmd/dlv@latest"
            "github.com/cweill/gotests/gotests@latest"
            "github.com/josharian/impl@latest"
            "github.com/fatih/gomodifytags@latest"
        )
        
        for tool in "${enhanced_tools[@]}"; do
            log_step "Installing $(basename "$tool" | cut -d'@' -f1)..."
            go install "$tool"
        done
        
        log_success "Enhanced Go tools installed successfully"
    else
        log_error "Go installation failed, skipping tools installation"
        return 1
    fi
}

setup_java_environment_enhanced() {
    log_info "Setting up enhanced Java development environment..."
    
    # Setup Java environment with version detection
    setup_java_environment "17"
    
    # Install Maven if not present
    if ! cmd_exists mvn; then
        log_warning "Maven not found. Installing..."
        install_package "maven"
    else
        log_success "Maven $(mvn -version | head -n 1 | cut -d' ' -f3) found"
    fi
    
    # Install Gradle if not present
    if ! cmd_exists gradle; then
        log_warning "Gradle not found. Installing..."
        install_package "gradle"
    else
        local gradle_version
        gradle_version=$(gradle -version 2>/dev/null | grep "Gradle" | cut -d' ' -f2 || echo "unknown")
        log_success "Gradle $gradle_version found"
    fi
}

create_development_workspaces() {
    log_info "Creating development workspaces..."
    
    for dir in "${WORKSPACE_DIRS[@]}"; do
        mkdir -p "${WORKSPACE_BASE}/$dir"
    done
    
    log_success "Development directories created in $WORKSPACE_BASE"
}

sync_neovim_plugins() {
    log_info "Syncing Neovim plugins..."
    
    if cmd_exists nvim; then
        # Start Neovim with plugin sync commands
        log_step "Running Lazy sync..."
        nvim --headless "+Lazy! sync" "+qa" 2>/dev/null || log_warning "Lazy sync may have issues"
        
        # Install/update Mason packages
        log_step "Running MasonInstallAll..."
        nvim --headless "+MasonInstallAll" "+qa" 2>/dev/null || log_warning "MasonInstallAll may need manual run"
        
        log_success "Neovim plugins sync attempted"
    else
        log_error "Neovim not found - skipping plugin sync"
    fi
}

test_enhanced_setup() {
    log_info "Testing the enhanced development setup..."
    
    # Test Go tools
    test_go_tools_enhanced
    
    # Test Java tools
    test_java_tools_enhanced
}

test_go_tools_enhanced() {
    log_info "Testing Go tools..."
    
    local go_tools=("gopls" "gofumpt" "dlv" "golangci-lint")
    
    for tool in "${go_tools[@]}"; do
        if cmd_exists "$tool"; then
            log_success "$tool is working"
        else
            log_warning "$tool not found in PATH"
        fi
    done
}

test_java_tools_enhanced() {
    log_info "Testing Java tools..."
    
    if [[ -n "$JAVA_HOME" ]]; then
        log_success "JAVA_HOME is set to: $JAVA_HOME"
    else
        log_warning "JAVA_HOME is not set"
    fi
    
    local java_tools=("mvn" "gradle")
    
    for tool in "${java_tools[@]}"; do
        if cmd_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warning "$tool not found"
        fi
    done
}

show_enhanced_completion_info() {
    echo
    log_success "Enhanced development environment setup completed!"
    echo
    log_info "Next Steps:"
    echo "1. Restart your terminal or source ~/.zshrc"
    echo "2. Open Neovim and test autocompletion:"
    echo "   - Create a Go file and type 'fmt.' - you should see suggestions"
    echo "   - Create a Java file and type 'System.' - you should see suggestions"
    echo "3. Test Go tools with:"
    echo "   - <leader>gr (Go run)"
    echo "   - <leader>gt (Go test)"
    echo "   - <leader>gf (Go format)"
    echo "4. Test Java tools with:"
    echo "   - <leader>jo (Java organize imports)"
    echo "   - <leader>jf (Java quick fix)"
    echo
    log_warning "Note: Some features may require restarting Neovim"
    echo
    log_info "Development workspaces created in: $WORKSPACE_BASE"
}

# Execute main function
main "$@"
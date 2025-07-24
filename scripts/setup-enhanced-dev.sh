#!/bin/bash

# Enhanced Development Environment Setup
# This script sets up Go and Java development with enhanced autocompletion

set -e

echo "🚀 Setting up enhanced Go and Java development environment"
echo "========================================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if required tools are installed
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Go
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go first."
        echo "Visit: https://golang.org/dl/"
        exit 1
    else
        print_success "Go $(go version | cut -d' ' -f3) found"
    fi
    
    # Check Java
    if ! command -v java &> /dev/null; then
        print_warning "Java not found. Installing with Homebrew..."
        if command -v brew &> /dev/null; then
            brew install openjdk@17
            print_success "Java installed"
        else
            print_error "Java not found and Homebrew not available. Please install Java manually."
            exit 1
        fi
    else
        print_success "Java $(java -version 2>&1 | head -n 1) found"
    fi
    
    # Check Node.js (for some language servers)
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not found. Installing with Homebrew..."
        if command -v brew &> /dev/null; then
            brew install node
            print_success "Node.js installed"
        fi
    else
        print_success "Node.js $(node -v) found"
    fi
}

# Install Go tools
install_go_tools() {
    print_step "Installing enhanced Go development tools..."
    
    # Essential Go tools
    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install mvdan.cc/gofumpt@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/cweill/gotests/gotests@latest
    go install github.com/josharian/impl@latest
    go install github.com/fatih/gomodifytags@latest
    
    print_success "Go tools installed successfully"
}

# Setup Java environment
setup_java_environment() {
    print_step "Setting up Java development environment..."
    
    # Ensure JAVA_HOME is set
    if [[ -z "$JAVA_HOME" ]]; then
        if [[ -d "/opt/homebrew/opt/openjdk@17" ]]; then
            export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
            echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
        elif [[ -d "/usr/local/opt/openjdk@17" ]]; then
            export JAVA_HOME="/usr/local/opt/openjdk@17"
            echo 'export JAVA_HOME="/usr/local/opt/openjdk@17"' >> ~/.zshrc
        fi
        print_success "JAVA_HOME configured"
    fi
    
    # Install Maven if not present
    if ! command -v mvn &> /dev/null; then
        print_warning "Maven not found. Installing with Homebrew..."
        if command -v brew &> /dev/null; then
            brew install maven
            print_success "Maven installed"
        fi
    else
        print_success "Maven $(mvn -version | head -n 1) found"
    fi
    
    # Install Gradle if not present
    if ! command -v gradle &> /dev/null; then
        print_warning "Gradle not found. Installing with Homebrew..."
        if command -v brew &> /dev/null; then
            brew install gradle
            print_success "Gradle installed"
        fi
    else
        print_success "Gradle $(gradle -version | grep Gradle | cut -d' ' -f2) found"
    fi
}

# Sync Neovim plugins
sync_neovim_plugins() {
    print_step "Syncing Neovim plugins..."
    
    # Start Neovim with plugin sync commands
    nvim --headless "+Lazy! sync" "+qa"
    
    # Install/update Mason packages
    nvim --headless "+MasonInstallAll" "+qa"
    
    print_success "Neovim plugins synced successfully"
}

# Create workspace directories
create_workspaces() {
    print_step "Creating development workspaces..."
    
    mkdir -p ~/Development/{go,java,projects}
    mkdir -p ~/Development/go/{bin,src,pkg}
    mkdir -p ~/Development/java/{projects,libraries}
    
    print_success "Development directories created"
}

# Test the setup
test_setup() {
    print_step "Testing the enhanced development setup..."
    
    # Test Go tools
    print_step "Testing Go tools..."
    if command -v gopls &> /dev/null; then
        print_success "gopls (Go LSP) is working"
    else
        print_error "gopls not found"
    fi
    
    if command -v gofumpt &> /dev/null; then
        print_success "gofumpt (Go formatter) is working"
    else
        print_error "gofumpt not found"
    fi
    
    # Test Java tools
    print_step "Testing Java tools..."
    if [[ -n "$JAVA_HOME" ]]; then
        print_success "JAVA_HOME is set to: $JAVA_HOME"
    else
        print_warning "JAVA_HOME is not set"
    fi
}

# Main setup process
main() {
    echo "Starting enhanced development environment setup..."
    
    check_prerequisites
    install_go_tools
    setup_java_environment
    create_workspaces
    sync_neovim_plugins
    test_setup
    
    echo ""
    print_success "Enhanced development environment setup completed!"
    echo ""
    echo "🎉 Next Steps:"
    echo "=============="
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
    echo ""
    print_warning "Note: Some features may require restarting Neovim"
}

main "$@"

#!/bin/bash

# GitHub Copilot Setup Script for dotfiles
# This script helps you authenticate and configure GitHub Copilot

set -e

echo "🚀 GitHub Copilot Setup for dotfiles"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if GitHub CLI is installed
print_step "Checking GitHub CLI installation..."
if command -v gh &> /dev/null; then
    print_success "GitHub CLI is installed"
    GH_VERSION=$(gh --version | head -n1)
    echo "   Version: $GH_VERSION"
else
    print_warning "GitHub CLI not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install gh
        print_success "GitHub CLI installed"
    else
        print_error "Homebrew not found. Please install GitHub CLI manually:"
        echo "   Visit: https://github.com/cli/cli#installation"
        exit 1
    fi
fi

# Check if user is authenticated with GitHub CLI
print_step "Checking GitHub CLI authentication..."
if gh auth status &> /dev/null; then
    print_success "Already authenticated with GitHub CLI"
    GITHUB_USER=$(gh api user --jq .login)
    echo "   Logged in as: $GITHUB_USER"
else
    print_warning "Not authenticated with GitHub CLI"
    echo "Please authenticate with GitHub CLI first:"
    echo "   gh auth login"
    read -p "Would you like to authenticate now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh auth login
        print_success "GitHub CLI authentication completed"
    else
        print_error "GitHub CLI authentication required for Copilot"
        exit 1
    fi
fi

# Check Copilot access
print_step "Checking GitHub Copilot access..."
if gh api user/copilot_seats &> /dev/null; then
    print_success "GitHub Copilot access confirmed"
else
    print_warning "GitHub Copilot access not found"
    echo "Please ensure you have:"
    echo "   1. GitHub Copilot subscription"
    echo "   2. Access to Copilot in your account/organization"
    echo "   Visit: https://github.com/features/copilot"
    
    read -p "Do you want to continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Setup Neovim with Copilot
print_step "Setting up Neovim configuration..."

# Check if Neovim is installed
if command -v nvim &> /dev/null; then
    print_success "Neovim found"
    NVIM_VERSION=$(nvim --version | head -n1)
    echo "   Version: $NVIM_VERSION"
else
    print_error "Neovim not found. Please install Neovim first."
    exit 1
fi

# Install/update plugins
print_step "Installing Neovim plugins..."
echo "Starting Neovim to install Copilot plugins..."
echo "Note: This may take a few minutes on first run..."

# Create a temporary init.lua to force plugin installation
cat > /tmp/install_copilot.lua << 'EOF'
-- Force sync plugins and quit
vim.cmd("Lazy sync")
-- Wait for sync to complete and quit
vim.defer_fn(function()
    vim.cmd("qa!")
end, 5000)
EOF

# Run nvim with temporary config to install plugins
if nvim --headless -u /tmp/install_copilot.lua; then
    print_success "Plugins installed successfully"
else
    print_warning "Plugin installation may have encountered issues"
fi

# Clean up temporary file
rm -f /tmp/install_copilot.lua

# Copilot authentication in Neovim
print_step "Setting up Copilot authentication..."
echo "Please follow these steps:"
echo "1. Open Neovim: nvim"
echo "2. Run: :Copilot auth"
echo "3. Follow the authentication flow"
echo "4. Run: :Copilot status to verify"

print_success "Copilot setup completed!"
echo ""
echo "🔧 Usage Instructions:"
echo "======================"
echo ""
echo "💡 Basic Copilot (Insert mode):"
echo "   Ctrl+L     - Accept suggestion"
echo "   Ctrl+J     - Next suggestion"
echo "   Ctrl+K     - Previous suggestion"
echo "   Ctrl+O     - Dismiss suggestion"
echo ""
echo "💬 Copilot Chat (Normal mode):"
echo "   <leader>cc - Open chat"
echo "   <leader>ce - Explain code"
echo "   <leader>ct - Generate tests"
echo "   <leader>cr - Review code"
echo "   <leader>cf - Refactor code"
echo "   <leader>cd - Documentation"
echo ""
echo "🚀 Next Steps:"
echo "1. Open Neovim and run: :Copilot auth"
echo "2. Test with any code file"
echo "3. Try Copilot Chat with <leader>cc"
echo ""
echo "📚 For more help: :help copilot"
echo ""
print_success "Happy coding with GitHub Copilot! 🎉"

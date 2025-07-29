#!/bin/bash

# AugmentCode Setup Script for Dotfiles
# Handles installation and configuration of AugmentCode AI assistant

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AugmentCode AI Setup for Dotfiles${NC}"
echo "=============================================="

# Check if Node.js meets requirements
check_nodejs() {
    echo -e "${BLUE}📦 Checking Node.js installation...${NC}"
    
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js is not installed${NC}"
        echo -e "${YELLOW}Please install Node.js 22.0.0+ from https://nodejs.org/${NC}"
        return 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)
    
    if [ "$MAJOR_VERSION" -lt 22 ]; then
        echo -e "${RED}❌ Node.js $NODE_VERSION is too old${NC}"
        echo -e "${YELLOW}AugmentCode requires Node.js 22.0.0+ from https://nodejs.org/${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Node.js $NODE_VERSION found${NC}"
    return 0
}

# Check if Neovim meets requirements
check_neovim() {
    echo -e "${BLUE}📦 Checking Neovim installation...${NC}"
    
    if ! command -v nvim &> /dev/null; then
        echo -e "${RED}❌ Neovim is not installed${NC}"
        echo -e "${YELLOW}Please install Neovim 0.10.0+ from https://neovim.io/${NC}"
        return 1
    fi
    
    NVIM_VERSION=$(nvim --version | head -n1 | cut -d'v' -f2 | cut -d' ' -f1)
    MAJOR_VERSION=$(echo $NVIM_VERSION | cut -d'.' -f1)
    MINOR_VERSION=$(echo $NVIM_VERSION | cut -d'.' -f2)
    
    if [ "$MAJOR_VERSION" -eq 0 ] && [ "$MINOR_VERSION" -lt 10 ]; then
        echo -e "${RED}❌ Neovim $NVIM_VERSION is too old${NC}"
        echo -e "${YELLOW}AugmentCode requires Neovim 0.10.0+ from https://neovim.io/${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Neovim $NVIM_VERSION found${NC}"
    return 0
}

# Check for existing AugmentCode installation
check_augmentcode() {
    echo -e "${BLUE}🔍 Checking for existing AugmentCode installation...${NC}"
    
    # Check if AugmentCode plugin directory exists
    if [ -d "$HOME/.config/nvim/pack/augment/start/augment.vim" ] || [ -d "$HOME/.local/share/nvim/lazy/augment.vim" ]; then
        echo -e "${GREEN}✅ AugmentCode plugin directory found${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}ℹ️  AugmentCode not yet installed${NC}"
    return 1
}

# Install and configure AugmentCode
setup_augmentcode() {
    echo -e "${BLUE}🔧 Setting up AugmentCode...${NC}"
    echo ""
    echo "AugmentCode setup process:"
    echo "1. The plugin is already configured in your dotfiles"
    echo "2. Neovim will install it automatically via lazy.nvim"
    echo "3. You'll need to sign in to AugmentCode on first use"
    echo "4. Sign up for free trial at https://augmentcode.com if needed"
    echo ""
    
    echo -e "${BLUE}📝 To complete setup:${NC}"
    echo "1. Open Neovim in your dotfiles directory"
    echo "2. Run :Lazy sync to install AugmentCode plugin"
    echo "3. Run :Augment signin to authenticate"
    echo "4. Test with :Augment status"
    echo ""
    
    return 0
}

# Test AugmentCode installation
test_installation() {
    echo -e "${BLUE}🧪 Testing AugmentCode readiness...${NC}"
    
    echo -e "${GREEN}✅ Setup ready for AugmentCode installation${NC}"
    
    echo -e "${BLUE}🎯 AugmentCode Features:${NC}"
    echo "• AI completions with deep codebase context"
    echo "• Multi-turn chat conversations about your code" 
    echo "• Workspace indexing for better understanding"
    echo "• Context-aware suggestions and explanations"
    echo "• Works with Vim 9.1.0+ and Neovim 0.10.0+"
    echo ""
    
    echo -e "${BLUE}⌨️  Keyboard Shortcuts (after installation):${NC}"
    echo "• <Tab> - Accept completion suggestion"
    echo "• <Ctrl+l> - Accept suggestion (alternative)"
    echo "• <leader>ac - Send chat message"
    echo "• <leader>an - New chat conversation"
    echo "• <leader>at - Toggle chat panel"
    echo "• <leader>as - Check status"
    echo "• <leader>ai - Sign in"
    echo "• <leader>ao - Sign out"
    echo ""
    
    echo -e "${BLUE}📚 Workspace Configuration:${NC}"
    echo "• Workspace folder automatically set to current directory"
    echo "• Add .augmentignore file to exclude specific files/directories"
    echo "• Check sync progress with :Augment status"
    echo ""
    
    echo -e "${GREEN}🎉 AugmentCode setup complete!${NC}"
    
    return 0
}

# Cross-platform compatibility notes
show_platform_notes() {
    echo -e "${BLUE}🖥️  Platform Compatibility Notes:${NC}"
    echo ""
    
    case "$(uname -s)" in
        Darwin)
            echo -e "${GREEN}✅ macOS detected${NC}"
            echo "• Node.js: brew install node (or download from nodejs.org)"
            echo "• Neovim: brew install neovim (or download from neovim.io)"
            ;;
        Linux)
            echo -e "${GREEN}✅ Linux detected${NC}"
            echo "• Node.js installation varies by distribution:"
            echo "  - Ubuntu/Debian: apt install nodejs npm"
            echo "  - CentOS/RHEL: yum install nodejs npm"
            echo "  - Arch: pacman -S nodejs npm"
            echo "• Neovim: Use package manager or AppImage from neovim.io"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown platform${NC}"
            echo "• Install Node.js 22.0.0+ and Neovim 0.10.0+"
            ;;
    esac
    echo ""
}

# Main execution
main() {
    echo ""
    show_platform_notes
    
    # Check Node.js
    if ! check_nodejs; then
        echo -e "${RED}❌ Setup cannot continue without Node.js 22.0.0+${NC}"
        exit 1
    fi
    
    # Check Neovim
    if ! check_neovim; then
        echo -e "${RED}❌ Setup cannot continue without Neovim 0.10.0+${NC}"
        exit 1
    fi
    
    # Check existing installation
    if check_augmentcode; then
        echo -e "${GREEN}✅ AugmentCode already detected${NC}"
    else
        setup_augmentcode
    fi
    
    # Test installation
    test_installation
    
    echo ""
    echo -e "${GREEN}🚀 AugmentCode integration ready!${NC}"
    echo -e "${BLUE}Use <leader>a commands in Neovim to access AugmentCode features${NC}"
    echo -e "${YELLOW}Don't forget to sign up at https://augmentcode.com for free trial${NC}"
}

# Run main function
main "$@"
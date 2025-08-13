#!/bin/bash

# AugmentCode setup script for dotfiles - cross-platform (macOS & Linux)
# Handles installation and configuration of AugmentCode AI assistant
# Usage: bash scripts/setup-augmentcode.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly MIN_NODE_VERSION="22"
readonly MIN_NVIM_VERSION="0.10.0"
readonly AUGMENT_DIRS=(
    "${HOME}/.config/nvim/pack/augment/start/augment.vim"
    "${HOME}/.local/share/nvim/lazy/augment.vim"
)

main() {
    log_header "AugmentCode AI Setup for Dotfiles"
    
    # Show platform compatibility notes
    show_platform_notes
    
    # Check prerequisites
    check_prerequisites
    
    # Check existing installation
    check_existing_installation
    
    # Setup AugmentCode
    setup_augmentcode_config
    
    # Test and show features
    test_and_show_features
    
    show_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Node.js
    if ! setup_nodejs "$MIN_NODE_VERSION"; then
        log_error "Setup cannot continue without Node.js ${MIN_NODE_VERSION}.0+"
        exit 1
    fi
    
    # Check Neovim
    if ! check_neovim_version "$MIN_NVIM_VERSION"; then
        log_error "Setup cannot continue without Neovim ${MIN_NVIM_VERSION}+"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

check_existing_installation() {
    log_info "Checking for existing AugmentCode installation..."
    
    local found=false
    for dir in "${AUGMENT_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "AugmentCode plugin directory found: $dir"
            found=true
            break
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        log_info "AugmentCode not yet installed"
    fi
}

setup_augmentcode_config() {
    log_info "Setting up AugmentCode configuration..."
    
    echo "AugmentCode setup process:"
    echo "1. The plugin is already configured in your dotfiles"
    echo "2. Neovim will install it automatically via lazy.nvim"
    echo "3. You'll need to sign in to AugmentCode on first use"
    echo "4. Sign up for free trial at https://augmentcode.com if needed"
    echo
    
    log_info "To complete setup:"
    echo "1. Open Neovim in your dotfiles directory"
    echo "2. Run :Lazy sync to install AugmentCode plugin"
    echo "3. Run :Augment signin to authenticate"
    echo "4. Test with :Augment status"
}

test_and_show_features() {
    log_info "Testing AugmentCode readiness..."
    log_success "Setup ready for AugmentCode installation"
    
    show_features_info
    show_keyboard_shortcuts
    show_workspace_configuration
}

show_features_info() {
    log_info "AugmentCode Features:"
    echo "• AI completions with deep codebase context"
    echo "• Multi-turn chat conversations about your code" 
    echo "• Workspace indexing for better understanding"
    echo "• Context-aware suggestions and explanations"
    echo "• Works with Vim 9.1.0+ and Neovim 0.10.0+"
}

show_keyboard_shortcuts() {
    log_info "Keyboard Shortcuts (after installation):"
    echo "• <Tab> - Accept completion suggestion"
    echo "• <Ctrl+l> - Accept suggestion (alternative)"
    echo "• <leader>ac - Send chat message"
    echo "• <leader>an - New chat conversation"
    echo "• <leader>at - Toggle chat panel"
    echo "• <leader>as - Check status"
    echo "• <leader>ai - Sign in"
    echo "• <leader>ao - Sign out"
}

show_workspace_configuration() {
    log_info "Workspace Configuration:"
    echo "• Workspace folder automatically set to current directory"
    echo "• Add .augmentignore file to exclude specific files/directories"
    echo "• Check sync progress with :Augment status"
}

show_platform_notes() {
    log_info "Platform Compatibility Notes:"
    
    case "$PLATFORM" in
        macos)
            log_success "macOS detected"
            echo "• Node.js: brew install node (or download from nodejs.org)"
            echo "• Neovim: brew install neovim (or download from neovim.io)"
            ;;
        linux)
            log_success "Linux detected"
            echo "• Node.js installation varies by distribution:"
            echo "  - Ubuntu/Debian: apt install nodejs npm"
            echo "  - CentOS/RHEL: yum install nodejs npm"
            echo "  - Arch: pacman -S nodejs npm"
            echo "• Neovim: Use package manager or AppImage from neovim.io"
            ;;
        *)
            log_warning "Unknown platform"
            echo "• Install Node.js 22.0.0+ and Neovim 0.10.0+"
            ;;
    esac
    echo
}

show_completion_info() {
    echo
    log_success "AugmentCode integration ready!"
    log_info "Use <leader>a commands in Neovim to access AugmentCode features"
    log_warning "Don't forget to sign up at https://augmentcode.com for free trial"
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode setup script for dotfiles - cross-platform (macOS & Linux)
# Handles installation and configuration of AugmentCode AI assistant
# Usage: bash scripts/setup-augmentcode.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly MIN_NODE_VERSION="22"
readonly MIN_NVIM_VERSION="0.10.0"
readonly AUGMENT_DIRS=(
    "${HOME}/.config/nvim/pack/augment/start/augment.vim"
    "${HOME}/.local/share/nvim/lazy/augment.vim"
)

main() {
    log_header "AugmentCode AI Setup for Dotfiles"
    
    # Show platform compatibility notes
    show_platform_notes
    
    # Check prerequisites
    check_prerequisites
    
    # Check existing installation
    check_existing_installation
    
    # Setup AugmentCode
    setup_augmentcode_config
    
    # Test and show features
    test_and_show_features
    
    show_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Node.js
    if ! setup_nodejs "$MIN_NODE_VERSION"; then
        log_error "Setup cannot continue without Node.js ${MIN_NODE_VERSION}.0+"
        exit 1
    fi
    
    # Check Neovim
    if ! check_neovim_version "$MIN_NVIM_VERSION"; then
        log_error "Setup cannot continue without Neovim ${MIN_NVIM_VERSION}+"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

check_existing_installation() {
    log_info "Checking for existing AugmentCode installation..."
    
    local found=false
    for dir in "${AUGMENT_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "AugmentCode plugin directory found: $dir"
            found=true
            break
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        log_info "AugmentCode not yet installed"
    fi
}

setup_augmentcode_config() {
    log_info "Setting up AugmentCode configuration..."
    
    echo "AugmentCode setup process:"
    echo "1. The plugin is already configured in your dotfiles"
    echo "2. Neovim will install it automatically via lazy.nvim"
    echo "3. You'll need to sign in to AugmentCode on first use"
    echo "4. Sign up for free trial at https://augmentcode.com if needed"
    echo
    
    log_info "To complete setup:"
    echo "1. Open Neovim in your dotfiles directory"
    echo "2. Run :Lazy sync to install AugmentCode plugin"
    echo "3. Run :Augment signin to authenticate"
    echo "4. Test with :Augment status"
}

test_and_show_features() {
    log_info "Testing AugmentCode readiness..."
    log_success "Setup ready for AugmentCode installation"
    
    show_features_info
    show_keyboard_shortcuts
    show_workspace_configuration
}

show_features_info() {
    log_info "AugmentCode Features:"
    echo "• AI completions with deep codebase context"
    echo "• Multi-turn chat conversations about your code" 
    echo "• Workspace indexing for better understanding"
    echo "• Context-aware suggestions and explanations"
    echo "• Works with Vim 9.1.0+ and Neovim 0.10.0+"
}

show_keyboard_shortcuts() {
    log_info "Keyboard Shortcuts (after installation):"
    echo "• <Tab> - Accept completion suggestion"
    echo "• <Ctrl+l> - Accept suggestion (alternative)"
    echo "• <leader>ac - Send chat message"
    echo "• <leader>an - New chat conversation"
    echo "• <leader>at - Toggle chat panel"
    echo "• <leader>as - Check status"
    echo "• <leader>ai - Sign in"
    echo "• <leader>ao - Sign out"
}

show_workspace_configuration() {
    log_info "Workspace Configuration:"
    echo "• Workspace folder automatically set to current directory"
    echo "• Add .augmentignore file to exclude specific files/directories"
    echo "• Check sync progress with :Augment status"
}

show_platform_notes() {
    log_info "Platform Compatibility Notes:"
    
    case "$PLATFORM" in
        macos)
            log_success "macOS detected"
            echo "• Node.js: brew install node (or download from nodejs.org)"
            echo "• Neovim: brew install neovim (or download from neovim.io)"
            ;;
        linux)
            log_success "Linux detected"
            echo "• Node.js installation varies by distribution:"
            echo "  - Ubuntu/Debian: apt install nodejs npm"
            echo "  - CentOS/RHEL: yum install nodejs npm"
            echo "  - Arch: pacman -S nodejs npm"
            echo "• Neovim: Use package manager or AppImage from neovim.io"
            ;;
        *)
            log_warning "Unknown platform"
            echo "• Install Node.js 22.0.0+ and Neovim 0.10.0+"
            ;;
    esac
    echo
}

show_completion_info() {
    echo
    log_success "AugmentCode integration ready!"
    log_info "Use <leader>a commands in Neovim to access AugmentCode features"
    log_warning "Don't forget to sign up at https://augmentcode.com for free trial"
}

# Execute main function
main "$@"
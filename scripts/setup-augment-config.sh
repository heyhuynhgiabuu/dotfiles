#!/bin/bash

# AugmentCode Configuration Setup Script - cross-platform (macOS & Linux)
# Manages AugmentCode configuration with stow integration
# Usage: bash scripts/setup-augment-config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly AUGMENT_CONFIGS=(
    ".local/share/vim-augment"
    ".config/augment"
)

main() {
    log_header "AugmentCode Configuration Setup"
    
    # Check prerequisites
    check_prerequisites
    
    # Validate environment
    validate_environment
    
    # Check plugin installation
    check_plugin_installation
    
    # Backup existing configuration
    backup_existing_configs
    
    # Setup stow configuration
    setup_stow_configuration
    
    # Verify installation
    verify_installation
    
    show_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if stow is available
    if ! cmd_exists stow; then
        log_error "GNU Stow is required but not installed"
        log_info "Install with:"
        if [[ "$PLATFORM" == "macos" ]]; then
            echo "  macOS: brew install stow"
        elif [[ "$PLATFORM" == "linux" ]]; then
            echo "  Ubuntu/Debian: sudo apt install stow"
            echo "  CentOS/RHEL: sudo yum install stow"
            echo "  Arch: sudo pacman -S stow"
        fi
        exit 1
    fi
    
    local stow_version
    stow_version=$(stow --version | head -1)
    log_success "GNU Stow found: $stow_version"
}

validate_environment() {
    log_info "Validating environment..."
    
    # Check if we're in the dotfiles directory
    if [[ ! -f "README.md" ]] || [[ ! -d "augment" ]]; then
        log_error "Please run this script from the dotfiles repository root"
        log_info "Expected: cd ~/dotfiles && bash scripts/setup-augment-config.sh"
        exit 1
    fi
    
    log_success "Running from dotfiles directory"
}

check_plugin_installation() {
    log_info "Checking AugmentCode plugin installation..."
    
    # Test if AugmentCode command is available
    if nvim --headless +"lua if pcall(function() vim.cmd('Augment status') end) then print('✅ AugmentCode plugin found') else print('❌ AugmentCode plugin not found') end" +qall 2>/dev/null | grep -q "✅"; then
        log_success "AugmentCode plugin is installed"
    else
        log_warning "AugmentCode plugin not found or not working"
        log_info "Run: nvim +':Lazy sync' +qall to install/update plugins"
    fi
}

backup_existing_configs() {
    log_info "Backing up existing configuration..."
    
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Backup vim-augment directory
    local vim_augment_dir="${HOME}/.local/share/vim-augment"
    if [[ -d "$vim_augment_dir" ]]; then
        local backup_dir="${vim_augment_dir}.backup.${backup_timestamp}"
        mv "$vim_augment_dir" "$backup_dir"
        log_success "Backed up vim-augment config to: $backup_dir"
    fi
    
    # Backup augment config directory
    local augment_config_dir="${HOME}/.config/augment"
    if [[ -d "$augment_config_dir" ]]; then
        local backup_dir="${augment_config_dir}.backup.${backup_timestamp}"
        mv "$augment_config_dir" "$backup_dir"
        log_success "Backed up augment config to: $backup_dir"
    fi
    
    # Backup augmentignore file
    local augmentignore_file="${HOME}/.augmentignore"
    if [[ -f "$augmentignore_file" ]]; then
        backup_file "$augmentignore_file" ".backup.${backup_timestamp}"
        log_success "Backed up .augmentignore"
    fi
}

setup_stow_configuration() {
    log_info "Setting up AugmentCode configuration with stow..."
    
    cd "$DOTFILES_DIR"
    
    # Check if augment directory exists
    if [[ ! -d "augment" ]]; then
        log_error "AugmentCode configuration directory 'augment' not found"
        log_info "Please ensure the augment directory exists in your dotfiles"
        exit 1
    fi
    
    # Use stow to symlink configuration
    if stow -v augment; then
        log_success "AugmentCode configuration symlinked successfully"
    else
        log_error "Failed to stow AugmentCode configuration"
        exit 1
    fi
}

verify_installation() {
    log_info "Verifying installation..."
    
    # Check symlinked files
    local config_files=(
        "${HOME}/.config/augment/keymaps.conf"
        "${HOME}/.config/augment/settings.conf"
        "${HOME}/.config/augment/workspace_folders.conf"
        "${HOME}/.augmentignore"
    )
    
    local all_files_exist=true
    for file in "${config_files[@]}"; do
        if [[ -L "$file" ]]; then
            log_success "Symlink exists: $(basename "$file")"
        elif [[ -f "$file" ]]; then
            log_warning "File exists (not symlink): $(basename "$file")"
        else
            log_error "Missing: $(basename "$file")"
            all_files_exist=false
        fi
    done
    
    if [[ "$all_files_exist" == "true" ]]; then
        log_success "All configuration files are in place"
    else
        log_warning "Some configuration files are missing"
    fi
    
    # Test AugmentCode functionality
    test_augmentcode_functionality
}

test_augmentcode_functionality() {
    log_info "Testing AugmentCode functionality..."
    
    # Test basic command availability
    if nvim --headless +"Augment status" +qall 2>/dev/null; then
        log_success "AugmentCode commands are working"
    else
        log_warning "AugmentCode commands not responding"
    fi
    
    # Check workspace configuration
    local workspace_config="${HOME}/.config/augment/workspace_folders.conf"
    if [[ -f "$workspace_config" ]]; then
        log_success "Workspace configuration loaded"
        log_info "Workspace folders: $(cat "$workspace_config" | head -3 | tr '
' ', ' | sed 's/,$//')"
    else
        log_warning "Workspace configuration not found"
    fi
}

show_completion_info() {
    echo
    log_success "AugmentCode configuration setup completed!"
    echo
    log_info "Configuration files installed:"
    echo "  • ~/.config/augment/keymaps.conf - Custom keybindings"
    echo "  • ~/.config/augment/settings.conf - AugmentCode settings"
    echo "  • ~/.config/augment/workspace_folders.conf - Workspace configuration"
    echo "  • ~/.augmentignore - Files to exclude from indexing"
    echo
    log_info "Next steps:"
    echo "1. Restart Neovim to load new configuration"
    echo "2. Run: :Augment signin to authenticate"
    echo "3. Test with: :Augment status"
    echo "4. Check workspace indexing progress"
    echo
    log_info "Configuration management:"
    echo "  • Edit files in ~/dotfiles/augment/.config/augment/"
    echo "  • Changes are automatically symlinked"
    echo "  • Use 'stow -D augment' to remove symlinks"
    echo "  • Use 'stow augment' to re-create symlinks"
    echo
    log_warning "Remember: Sign in to AugmentCode to complete setup"
}

# Execute main function
main "$@"#!/bin/bash

# AugmentCode Configuration Setup Script - cross-platform (macOS & Linux)
# Manages AugmentCode configuration with stow integration
# Usage: bash scripts/setup-augment-config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly AUGMENT_CONFIGS=(
    ".local/share/vim-augment"
    ".config/augment"
)

main() {
    log_header "AugmentCode Configuration Setup"
    
    # Check prerequisites
    check_prerequisites
    
    # Validate environment
    validate_environment
    
    # Check plugin installation
    check_plugin_installation
    
    # Backup existing configuration
    backup_existing_configs
    
    # Setup stow configuration
    setup_stow_configuration
    
    # Verify installation
    verify_installation
    
    show_completion_info
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if stow is available
    if ! cmd_exists stow; then
        log_error "GNU Stow is required but not installed"
        log_info "Install with:"
        if [[ "$PLATFORM" == "macos" ]]; then
            echo "  macOS: brew install stow"
        elif [[ "$PLATFORM" == "linux" ]]; then
            echo "  Ubuntu/Debian: sudo apt install stow"
            echo "  CentOS/RHEL: sudo yum install stow"
            echo "  Arch: sudo pacman -S stow"
        fi
        exit 1
    fi
    
    local stow_version
    stow_version=$(stow --version | head -1)
    log_success "GNU Stow found: $stow_version"
}

validate_environment() {
    log_info "Validating environment..."
    
    # Check if we're in the dotfiles directory
    if [[ ! -f "README.md" ]] || [[ ! -d "augment" ]]; then
        log_error "Please run this script from the dotfiles repository root"
        log_info "Expected: cd ~/dotfiles && bash scripts/setup-augment-config.sh"
        exit 1
    fi
    
    log_success "Running from dotfiles directory"
}

check_plugin_installation() {
    log_info "Checking AugmentCode plugin installation..."
    
    # Test if AugmentCode command is available
    if nvim --headless +"lua if pcall(function() vim.cmd('Augment status') end) then print('✅ AugmentCode plugin found') else print('❌ AugmentCode plugin not found') end" +qall 2>/dev/null | grep -q "✅"; then
        log_success "AugmentCode plugin is installed"
    else
        log_warning "AugmentCode plugin not found or not working"
        log_info "Run: nvim +':Lazy sync' +qall to install/update plugins"
    fi
}

backup_existing_configs() {
    log_info "Backing up existing configuration..."
    
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Backup vim-augment directory
    local vim_augment_dir="${HOME}/.local/share/vim-augment"
    if [[ -d "$vim_augment_dir" ]]; then
        local backup_dir="${vim_augment_dir}.backup.${backup_timestamp}"
        mv "$vim_augment_dir" "$backup_dir"
        log_success "Backed up vim-augment config to: $backup_dir"
    fi
    
    # Backup augment config directory
    local augment_config_dir="${HOME}/.config/augment"
    if [[ -d "$augment_config_dir" ]]; then
        local backup_dir="${augment_config_dir}.backup.${backup_timestamp}"
        mv "$augment_config_dir" "$backup_dir"
        log_success "Backed up augment config to: $backup_dir"
    fi
    
    # Backup augmentignore file
    local augmentignore_file="${HOME}/.augmentignore"
    if [[ -f "$augmentignore_file" ]]; then
        backup_file "$augmentignore_file" ".backup.${backup_timestamp}"
        log_success "Backed up .augmentignore"
    fi
}

setup_stow_configuration() {
    log_info "Setting up AugmentCode configuration with stow..."
    
    cd "$DOTFILES_DIR"
    
    # Check if augment directory exists
    if [[ ! -d "augment" ]]; then
        log_error "AugmentCode configuration directory 'augment' not found"
        log_info "Please ensure the augment directory exists in your dotfiles"
        exit 1
    fi
    
    # Use stow to symlink configuration
    if stow -v augment; then
        log_success "AugmentCode configuration symlinked successfully"
    else
        log_error "Failed to stow AugmentCode configuration"
        exit 1
    fi
}

verify_installation() {
    log_info "Verifying installation..."
    
    # Check symlinked files
    local config_files=(
        "${HOME}/.config/augment/keymaps.conf"
        "${HOME}/.config/augment/settings.conf"
        "${HOME}/.config/augment/workspace_folders.conf"
        "${HOME}/.augmentignore"
    )
    
    local all_files_exist=true
    for file in "${config_files[@]}"; do
        if [[ -L "$file" ]]; then
            log_success "Symlink exists: $(basename "$file")"
        elif [[ -f "$file" ]]; then
            log_warning "File exists (not symlink): $(basename "$file")"
        else
            log_error "Missing: $(basename "$file")"
            all_files_exist=false
        fi
    done
    
    if [[ "$all_files_exist" == "true" ]]; then
        log_success "All configuration files are in place"
    else
        log_warning "Some configuration files are missing"
    fi
    
    # Test AugmentCode functionality
    test_augmentcode_functionality
}

test_augmentcode_functionality() {
    log_info "Testing AugmentCode functionality..."
    
    # Test basic command availability
    if nvim --headless +"Augment status" +qall 2>/dev/null; then
        log_success "AugmentCode commands are working"
    else
        log_warning "AugmentCode commands not responding"
    fi
    
    # Check workspace configuration
    local workspace_config="${HOME}/.config/augment/workspace_folders.conf"
    if [[ -f "$workspace_config" ]]; then
        log_success "Workspace configuration loaded"
        log_info "Workspace folders: $(cat "$workspace_config" | head -3 | tr '
' ', ' | sed 's/,$//')"
    else
        log_warning "Workspace configuration not found"
    fi
}

show_completion_info() {
    echo
    log_success "AugmentCode configuration setup completed!"
    echo
    log_info "Configuration files installed:"
    echo "  • ~/.config/augment/keymaps.conf - Custom keybindings"
    echo "  • ~/.config/augment/settings.conf - AugmentCode settings"
    echo "  • ~/.config/augment/workspace_folders.conf - Workspace configuration"
    echo "  • ~/.augmentignore - Files to exclude from indexing"
    echo
    log_info "Next steps:"
    echo "1. Restart Neovim to load new configuration"
    echo "2. Run: :Augment signin to authenticate"
    echo "3. Test with: :Augment status"
    echo "4. Check workspace indexing progress"
    echo
    log_info "Configuration management:"
    echo "  • Edit files in ~/dotfiles/augment/.config/augment/"
    echo "  • Changes are automatically symlinked"
    echo "  • Use 'stow -D augment' to remove symlinks"
    echo "  • Use 'stow augment' to re-create symlinks"
    echo
    log_warning "Remember: Sign in to AugmentCode to complete setup"
}

# Execute main function
main "$@"
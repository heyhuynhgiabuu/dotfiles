#!/bin/bash

# NvChad update script - preserves custom configurations
# Updates NvChad v2.0 while maintaining custom dotfiles integration
# Usage: bash scripts/update-nvchad.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NVCHAD_BRANCH="v2.0"
readonly BACKUP_PREFIX="nvchad-update-backup-$(date +%Y%m%d_%H%M%S)"

main() {
    log_header "Updating NvChad v2.0 while preserving custom configurations"
    
    # Validate NvChad installation
    validate_nvchad_installation
    
    # Backup current configuration
    backup_current_config
    
    # Update NvChad
    update_nvchad_core
    
    # Restore custom configurations
    restore_custom_configs
    
    show_update_summary
}

validate_nvchad_installation() {
    log_info "Validating NvChad installation..."
    
    if [[ ! -d "$NVIM_CONFIG_DIR" || ! -f "${NVIM_CONFIG_DIR}/init.lua" ]]; then
        log_error "NvChad not found. Please run the main install script first."
        exit 1
    fi
    
    # Check if it's a git repository
    cd "$NVIM_CONFIG_DIR"
    if [[ ! -d .git ]]; then
        log_error "NvChad directory is not a git repository. Cannot update."
        log_info "Please reinstall NvChad using the main install script."
        exit 1
    fi
    
    log_success "NvChad installation validated"
}

backup_current_config() {
    log_info "Backing up current custom configurations..."
    
    local backup_dir="${DOTFILES_DIR}/${BACKUP_PREFIX}"
    mkdir -p "$backup_dir"
    
    if [[ -d "$NVIM_CUSTOM_DIR" ]]; then
        cp -r "$NVIM_CUSTOM_DIR" "$backup_dir/"
        log_success "Backup created at: $backup_dir"
    else
        log_warning "No custom configurations found to backup"
    fi
    
    # Save current commit info
    log_info "Current NvChad info:"
    git log --oneline -1
    echo
}

update_nvchad_core() {
    log_info "Updating NvChad core..."
    
    cd "$NVIM_CONFIG_DIR"
    
    # Fetch latest changes
    log_step "Fetching latest changes..."
    git fetch origin
    
    # Hard reset to latest v2.0
    log_step "Updating to latest v2.0..."
    git reset --hard "origin/$NVCHAD_BRANCH"
    
    log_success "NvChad core updated successfully"
}

restore_custom_configs() {
    log_info "Restoring custom configuration symlinks..."
    
    # Ensure custom directory exists
    mkdir -p "$NVIM_CUSTOM_DIR"
    
    # Remove any files that might have been added by the update
    rm -rf "${NVIM_CUSTOM_DIR:?}"/*
    
    # Recreate symlinks for all custom config files
    local source_custom_dir="${DOTFILES_DIR}/nvim/.config/nvim/lua/custom"
    if [[ -d "$source_custom_dir" ]]; then
        for item in "$source_custom_dir"/*; do
            if [[ -e "$item" ]]; then
                local item_name
                item_name=$(basename "$item")
                log_step "Symlinking custom/$item_name..."
                create_symlink "$item" "${NVIM_CUSTOM_DIR}/$item_name"
            fi
        done
        
        # Create specific symlink for lspconfig if it exists
        local lsp_config_file="${source_custom_dir}/lsp-config.lua"
        if [[ -f "$lsp_config_file" ]]; then
            log_step "Creating lspconfig symlink..."
            mkdir -p "${NVIM_CUSTOM_DIR}/configs"
            create_symlink "$lsp_config_file" "${NVIM_CUSTOM_DIR}/configs/lspconfig.lua"
        fi
        
        log_success "Custom configurations restored"
    else
        log_warning "No custom configurations found in dotfiles"
    fi
}

show_update_summary() {
    echo
    log_success "NvChad update completed!"
    
    cd "$NVIM_CONFIG_DIR"
    log_info "Updated NvChad info:"
    git log --oneline -1
    echo
    
    log_info "Notes:"
    echo "  • Your custom configurations have been preserved"
    echo "  • Backup created at: ${DOTFILES_DIR}/${BACKUP_PREFIX}"
    echo "  • If you encounter issues, you can restore from the backup"
    echo "  • Your dotfiles custom configs remain unchanged"
    echo "  • Restart Neovim to see the updates"
}

# Execute main function
main "$@"#!/bin/bash

# NvChad update script - preserves custom configurations
# Updates NvChad v2.0 while maintaining custom dotfiles integration
# Usage: bash scripts/update-nvchad.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NVCHAD_BRANCH="v2.0"
readonly BACKUP_PREFIX="nvchad-update-backup-$(date +%Y%m%d_%H%M%S)"

main() {
    log_header "Updating NvChad v2.0 while preserving custom configurations"
    
    # Validate NvChad installation
    validate_nvchad_installation
    
    # Backup current configuration
    backup_current_config
    
    # Update NvChad
    update_nvchad_core
    
    # Restore custom configurations
    restore_custom_configs
    
    show_update_summary
}

validate_nvchad_installation() {
    log_info "Validating NvChad installation..."
    
    if [[ ! -d "$NVIM_CONFIG_DIR" || ! -f "${NVIM_CONFIG_DIR}/init.lua" ]]; then
        log_error "NvChad not found. Please run the main install script first."
        exit 1
    fi
    
    # Check if it's a git repository
    cd "$NVIM_CONFIG_DIR"
    if [[ ! -d .git ]]; then
        log_error "NvChad directory is not a git repository. Cannot update."
        log_info "Please reinstall NvChad using the main install script."
        exit 1
    fi
    
    log_success "NvChad installation validated"
}

backup_current_config() {
    log_info "Backing up current custom configurations..."
    
    local backup_dir="${DOTFILES_DIR}/${BACKUP_PREFIX}"
    mkdir -p "$backup_dir"
    
    if [[ -d "$NVIM_CUSTOM_DIR" ]]; then
        cp -r "$NVIM_CUSTOM_DIR" "$backup_dir/"
        log_success "Backup created at: $backup_dir"
    else
        log_warning "No custom configurations found to backup"
    fi
    
    # Save current commit info
    log_info "Current NvChad info:"
    git log --oneline -1
    echo
}

update_nvchad_core() {
    log_info "Updating NvChad core..."
    
    cd "$NVIM_CONFIG_DIR"
    
    # Fetch latest changes
    log_step "Fetching latest changes..."
    git fetch origin
    
    # Hard reset to latest v2.0
    log_step "Updating to latest v2.0..."
    git reset --hard "origin/$NVCHAD_BRANCH"
    
    log_success "NvChad core updated successfully"
}

restore_custom_configs() {
    log_info "Restoring custom configuration symlinks..."
    
    # Ensure custom directory exists
    mkdir -p "$NVIM_CUSTOM_DIR"
    
    # Remove any files that might have been added by the update
    rm -rf "${NVIM_CUSTOM_DIR:?}"/*
    
    # Recreate symlinks for all custom config files
    local source_custom_dir="${DOTFILES_DIR}/nvim/.config/nvim/lua/custom"
    if [[ -d "$source_custom_dir" ]]; then
        for item in "$source_custom_dir"/*; do
            if [[ -e "$item" ]]; then
                local item_name
                item_name=$(basename "$item")
                log_step "Symlinking custom/$item_name..."
                create_symlink "$item" "${NVIM_CUSTOM_DIR}/$item_name"
            fi
        done
        
        # Create specific symlink for lspconfig if it exists
        local lsp_config_file="${source_custom_dir}/lsp-config.lua"
        if [[ -f "$lsp_config_file" ]]; then
            log_step "Creating lspconfig symlink..."
            mkdir -p "${NVIM_CUSTOM_DIR}/configs"
            create_symlink "$lsp_config_file" "${NVIM_CUSTOM_DIR}/configs/lspconfig.lua"
        fi
        
        log_success "Custom configurations restored"
    else
        log_warning "No custom configurations found in dotfiles"
    fi
}

show_update_summary() {
    echo
    log_success "NvChad update completed!"
    
    cd "$NVIM_CONFIG_DIR"
    log_info "Updated NvChad info:"
    git log --oneline -1
    echo
    
    log_info "Notes:"
    echo "  • Your custom configurations have been preserved"
    echo "  • Backup created at: ${DOTFILES_DIR}/${BACKUP_PREFIX}"
    echo "  • If you encounter issues, you can restore from the backup"
    echo "  • Your dotfiles custom configs remain unchanged"
    echo "  • Restart Neovim to see the updates"
}

# Execute main function
main "$@"
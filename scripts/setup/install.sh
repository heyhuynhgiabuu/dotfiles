#!/usr/bin/env sh

# Dotfiles installation script - cross-platform (macOS & Linux)
# Sets up symlinks and NvChad integration
# Usage: bash scripts/install.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NVCHAD_REPO="https://github.com/NvChad/NvChad.git"
readonly NVCHAD_BRANCH="v2.0"
readonly BACKUP_PREFIX="backup-$(date +%Y%m%d_%H%M%S)"

main() {
    log_header "Installing Dotfiles"
    
    # Setup shell configurations
    setup_shell_configs
    
    # Setup tmux configuration
    setup_tmux_config
    
    # Setup Neovim with NvChad
    setup_neovim_nvchad
    
    # Setup scripts in PATH
    setup_scripts
    
    show_completion_info
}

setup_shell_configs() {
    log_info "Setting up shell configurations..."
    
    # Backup and symlink zshrc
    backup_file "${HOME}/.zshrc"
    create_symlink "${DOTFILES_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
    
    # Setup zsh directory as single symlink
    backup_file "${HOME}/.zsh"
    create_symlink "${DOTFILES_DIR}/zsh/.zsh" "${HOME}/.zsh"    
    log_success "Shell configurations setup complete"
}

setup_tmux_config() {
    log_info "Setting up tmux configuration..."
    
    backup_file "${HOME}/.tmux.conf"
    create_symlink "${DOTFILES_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"
    
    log_success "Tmux configuration symlinked"
}

setup_neovim_nvchad() {
    log_info "Setting up Neovim with NvChad v2.0..."
    
    # Backup existing custom configurations
    backup_custom_configs
    
    # Install NvChad if needed
    install_nvchad
    
    # Setup custom configuration symlinks
    setup_custom_symlinks
    
    log_success "Neovim and NvChad setup complete"
}

backup_custom_configs() {
    local custom_dir="${NVIM_CONFIG_DIR}/lua/custom"
    
    if [[ -d "$custom_dir" && -n "$(ls -A "$custom_dir" 2>/dev/null)" ]]; then
        local backup_dir="${DOTFILES_DIR}/nvim-${BACKUP_PREFIX}"
        log_info "Backing up existing custom configurations to: $backup_dir"
        mkdir -p "$backup_dir"
        cp -r "$custom_dir" "$backup_dir/"
    fi
}

install_nvchad() {
    if [[ ! -d "$NVIM_CONFIG_DIR" || ! -f "${NVIM_CONFIG_DIR}/init.lua" ]]; then
        log_info "Installing NvChad v2.0..."
        rm -rf "$NVIM_CONFIG_DIR"
        git clone --depth 1 -b "$NVCHAD_BRANCH" "$NVCHAD_REPO" "$NVIM_CONFIG_DIR"
        log_success "NvChad v2.0 installed"
    else
        log_success "NvChad already installed, skipping..."
    fi
}

setup_custom_symlinks() {
    log_info "Setting up custom configuration symlinks..."
    
    local source_custom_dir="${DOTFILES_DIR}/nvim/.config/nvim/lua/custom"
    mkdir -p "$NVIM_CUSTOM_DIR"
    
    # Remove existing custom configurations
    rm -rf "${NVIM_CUSTOM_DIR:?}"/*
    
    # Create symlinks for all custom config files
    if [[ -d "$source_custom_dir" ]]; then
        for item in "$source_custom_dir"/*; do
            if [[ -e "$item" ]]; then
                item_name=$(basename "$item")
                log_step "Symlinking custom/$item_name..."
                create_symlink "$item" "${NVIM_CUSTOM_DIR}/$item_name"
            fi
        done
    fi
    
    # Create specific symlink for lspconfig
    local lsp_config_file="${source_custom_dir}/lsp-config.lua"
    if [[ -f "$lsp_config_file" ]]; then
        log_step "Creating lspconfig symlink..."
        mkdir -p "${NVIM_CUSTOM_DIR}/configs"
        create_symlink "$lsp_config_file" "${NVIM_CUSTOM_DIR}/configs/lspconfig.lua"
    fi
}

setup_scripts() {
    log_info "Setting up scripts in PATH..."
    
    mkdir -p "$BIN_DIR"
    
    # Symlink all scripts and make them executable
    for script in "${SCRIPTS_DIR}"/*; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            log_step "Symlinking $script_name..."
            create_symlink "$script" "${BIN_DIR}/$script_name"
            chmod +x "${BIN_DIR}/$script_name"
        fi
    done
    
    log_success "Scripts setup complete"
}

show_completion_info() {
    echo
    log_success "Dotfiles installation complete!"
    echo
    log_info "Next steps:"
    echo "  • Run: source ~/.zshrc"
    echo "  • Open Neovim to complete plugin installation"
    echo
    log_info "NvChad v2.0 Integration Notes:"
    echo "  • NvChad is installed in ~/.config/nvim"
    echo "  • Custom configs are in ~/dotfiles/nvim/.config/nvim/lua/custom/"
    echo "  • Custom configs are symlinked to NvChad's custom directory"
    echo "  • To update NvChad: run 'update-nvchad' script"
    echo "  • Your customizations are preserved in the dotfiles repo"
}

# Execute main function
main "$@"#!/bin/bash

# Dotfiles installation script - cross-platform (macOS & Linux)
# Sets up symlinks and NvChad integration
# Usage: bash scripts/install.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NVCHAD_REPO="https://github.com/NvChad/NvChad.git"
readonly NVCHAD_BRANCH="v2.0"
readonly BACKUP_PREFIX="backup-$(date +%Y%m%d_%H%M%S)"

main() {
    log_header "Installing Dotfiles"
    
    # Setup shell configurations
    setup_shell_configs
    
    # Setup tmux configuration
    setup_tmux_config
    
    # Setup Neovim with NvChad
    setup_neovim_nvchad
    
    # Setup scripts in PATH
    setup_scripts
    
    show_completion_info
}

setup_shell_configs() {
    log_info "Setting up shell configurations..."
    
    # Backup and symlink zshrc
    backup_file "${HOME}/.zshrc"
    create_symlink "${DOTFILES_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
    
    # Setup zsh directory as single symlink
    backup_file "${HOME}/.zsh"
    create_symlink "${DOTFILES_DIR}/zsh/.zsh" "${HOME}/.zsh"    
    log_success "Shell configurations setup complete"
}

setup_tmux_config() {
    log_info "Setting up tmux configuration..."
    
    backup_file "${HOME}/.tmux.conf"
    create_symlink "${DOTFILES_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"
    
    log_success "Tmux configuration symlinked"
}

setup_neovim_nvchad() {
    log_info "Setting up Neovim with NvChad v2.0..."
    
    # Backup existing custom configurations
    backup_custom_configs
    
    # Install NvChad if needed
    install_nvchad
    
    # Setup custom configuration symlinks
    setup_custom_symlinks
    
    log_success "Neovim and NvChad setup complete"
}

backup_custom_configs() {
    local custom_dir="${NVIM_CONFIG_DIR}/lua/custom"
    
    if [[ -d "$custom_dir" && -n "$(ls -A "$custom_dir" 2>/dev/null)" ]]; then
        local backup_dir="${DOTFILES_DIR}/nvim-${BACKUP_PREFIX}"
        log_info "Backing up existing custom configurations to: $backup_dir"
        mkdir -p "$backup_dir"
        cp -r "$custom_dir" "$backup_dir/"
    fi
}

install_nvchad() {
    if [[ ! -d "$NVIM_CONFIG_DIR" || ! -f "${NVIM_CONFIG_DIR}/init.lua" ]]; then
        log_info "Installing NvChad v2.0..."
        rm -rf "$NVIM_CONFIG_DIR"
        git clone --depth 1 -b "$NVCHAD_BRANCH" "$NVCHAD_REPO" "$NVIM_CONFIG_DIR"
        log_success "NvChad v2.0 installed"
    else
        log_success "NvChad already installed, skipping..."
    fi
}

setup_custom_symlinks() {
    log_info "Setting up custom configuration symlinks..."
    
    local source_custom_dir="${DOTFILES_DIR}/nvim/.config/nvim/lua/custom"
    mkdir -p "$NVIM_CUSTOM_DIR"
    
    # Remove existing custom configurations
    rm -rf "${NVIM_CUSTOM_DIR:?}"/*
    
    # Create symlinks for all custom config files
    if [[ -d "$source_custom_dir" ]]; then
        for item in "$source_custom_dir"/*; do
            if [[ -e "$item" ]]; then
                item_name=$(basename "$item")
                log_step "Symlinking custom/$item_name..."
                create_symlink "$item" "${NVIM_CUSTOM_DIR}/$item_name"
            fi
        done
    fi
    
    # Create specific symlink for lspconfig
    local lsp_config_file="${source_custom_dir}/lsp-config.lua"
    if [[ -f "$lsp_config_file" ]]; then
        log_step "Creating lspconfig symlink..."
        mkdir -p "${NVIM_CUSTOM_DIR}/configs"
        create_symlink "$lsp_config_file" "${NVIM_CUSTOM_DIR}/configs/lspconfig.lua"
    fi
}

setup_scripts() {
    log_info "Setting up scripts in PATH..."
    
    mkdir -p "$BIN_DIR"
    
    # Symlink all scripts and make them executable
    for script in "${SCRIPTS_DIR}"/*; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            log_step "Symlinking $script_name..."
            create_symlink "$script" "${BIN_DIR}/$script_name"
            chmod +x "${BIN_DIR}/$script_name"
        fi
    done
    
    log_success "Scripts setup complete"
}

show_completion_info() {
    echo
    log_success "Dotfiles installation complete!"
    echo
    log_info "Next steps:"
    echo "  • Run: source ~/.zshrc"
    echo "  • Open Neovim to complete plugin installation"
    echo
    log_info "NvChad v2.0 Integration Notes:"
    echo "  • NvChad is installed in ~/.config/nvim"
    echo "  • Custom configs are in ~/dotfiles/nvim/.config/nvim/lua/custom/"
    echo "  • Custom configs are symlinked to NvChad's custom directory"
    echo "  • To update NvChad: run 'update-nvchad' script"
    echo "  • Your customizations are preserved in the dotfiles repo"
}

# Execute main function
main "$@"
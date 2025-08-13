#!/bin/bash

# Dotfiles bootstrap script - cross-platform (macOS & Linux)
# Installs GNU Stow and symlinks configurations
# Usage: bash scripts/bootstrap.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly STOW_CONFIGS=(nvim tmux zsh aerospace wezterm)
readonly TPM_REPO="https://github.com/tmux-plugins/tpm"
readonly TPM_DIR="${HOME}/.tmux/plugins/tpm"

main() {
    log_header "Dotfiles Bootstrap Setup"
    
    # Install GNU Stow
    install_stow
    
    # Stow configurations
    stow_configurations
    
    # Setup Tmux Plugin Manager
    setup_tpm
    
    # Reload tmux configuration
    reload_tmux_config
    
    log_success "Bootstrap complete! Your dotfiles are symlinked with Stow."
    log_info "You may now run: tmux"
}

install_stow() {
    if ! cmd_exists stow; then
        log_info "Installing GNU Stow..."
        install_package "stow"
    else
        log_success "GNU Stow is already installed"
    fi
}

stow_configurations() {
    log_info "Stowing configurations..."
    cd "$DOTFILES_DIR"
    
    for config in "${STOW_CONFIGS[@]}"; do
        if [[ -d "$config" ]]; then
            log_step "Stowing $config..."
            stow -v "$config"
        else
            log_warning "Configuration directory '$config' not found, skipping..."
        fi
    done
}

setup_tpm() {
    log_info "Setting up Tmux Plugin Manager..."
    
    if [[ ! -d "$TPM_DIR" ]]; then
        log_step "Cloning TPM..."
        git clone "$TPM_REPO" "$TPM_DIR"
        log_success "TPM installed"
    else
        log_success "TPM already installed"
    fi
}

reload_tmux_config() {
    if cmd_exists tmux; then
        log_info "Reloading tmux configuration..."
        
        # Start tmux server if not running
        tmux start-server 2>/dev/null || true
        
        # Create temporary session, reload config, then cleanup
        tmux new-session -d -s "bootstrap_reload" 2>/dev/null || true
        tmux send-keys -t "bootstrap_reload" "tmux source-file ~/.tmux.conf" C-m 2>/dev/null || true
        tmux kill-session -t "bootstrap_reload" 2>/dev/null || true
        
        log_success "Tmux configuration reloaded"
    else
        log_warning "Tmux not found - configuration will be loaded on first run"
    fi
}

# Execute main function
main "$@"#!/bin/bash

# Dotfiles bootstrap script - cross-platform (macOS & Linux)
# Installs GNU Stow and symlinks configurations
# Usage: bash scripts/bootstrap.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly STOW_CONFIGS=(nvim tmux zsh aerospace wezterm)
readonly TPM_REPO="https://github.com/tmux-plugins/tpm"
readonly TPM_DIR="${HOME}/.tmux/plugins/tpm"

main() {
    log_header "Dotfiles Bootstrap Setup"
    
    # Install GNU Stow
    install_stow
    
    # Stow configurations
    stow_configurations
    
    # Setup Tmux Plugin Manager
    setup_tpm
    
    # Reload tmux configuration
    reload_tmux_config
    
    log_success "Bootstrap complete! Your dotfiles are symlinked with Stow."
    log_info "You may now run: tmux"
}

install_stow() {
    if ! cmd_exists stow; then
        log_info "Installing GNU Stow..."
        install_package "stow"
    else
        log_success "GNU Stow is already installed"
    fi
}

stow_configurations() {
    log_info "Stowing configurations..."
    cd "$DOTFILES_DIR"
    
    for config in "${STOW_CONFIGS[@]}"; do
        if [[ -d "$config" ]]; then
            log_step "Stowing $config..."
            stow -v "$config"
        else
            log_warning "Configuration directory '$config' not found, skipping..."
        fi
    done
}

setup_tpm() {
    log_info "Setting up Tmux Plugin Manager..."
    
    if [[ ! -d "$TPM_DIR" ]]; then
        log_step "Cloning TPM..."
        git clone "$TPM_REPO" "$TPM_DIR"
        log_success "TPM installed"
    else
        log_success "TPM already installed"
    fi
}

reload_tmux_config() {
    if cmd_exists tmux; then
        log_info "Reloading tmux configuration..."
        
        # Start tmux server if not running
        tmux start-server 2>/dev/null || true
        
        # Create temporary session, reload config, then cleanup
        tmux new-session -d -s "bootstrap_reload" 2>/dev/null || true
        tmux send-keys -t "bootstrap_reload" "tmux source-file ~/.tmux.conf" C-m 2>/dev/null || true
        tmux kill-session -t "bootstrap_reload" 2>/dev/null || true
        
        log_success "Tmux configuration reloaded"
    else
        log_warning "Tmux not found - configuration will be loaded on first run"
    fi
}

# Execute main function
main "$@"
#!/usr/bin/env sh

# Dotfiles setup script - cross-platform (macOS & Linux)
# Installs GNU Stow and symlinks configurations
# Usage: sh scripts/setup/setup.sh

set -e  # Exit on error
set -u  # Exit on undefined variable

# Source common utilities (includes root safety check)
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/common.sh" || { echo "Failed to source common.sh"; exit 1; }

# Configuration (POSIX-compliant space-separated list)
readonly STOW_CONFIGS="nvim tmux zsh aerospace wezterm"
readonly TPM_REPO="https://github.com/tmux-plugins/tpm"
readonly TPM_DIR="${HOME}/.tmux/plugins/tpm"

main() {
    log_header "Dotfiles Bootstrap Setup"
    
    # Install GNU Stow
    install_stow || { log_error "Failed to install stow"; exit 1; }
    
    # Stow configurations
    stow_configurations || { log_error "Failed to stow configurations"; exit 1; }
    
    # Setup Tmux Plugin Manager
    setup_tpm || { log_error "Failed to setup TPM"; exit 1; }
    
    # Reload tmux configuration
    reload_tmux_config
    
    log_success "Bootstrap complete! Your dotfiles are symlinked with Stow."
    log_info "You may now run: tmux"
}

install_stow() {
    if ! cmd_exists stow; then
        log_info "Installing GNU Stow..."
        if ! install_package "stow"; then
            log_error "Failed to install GNU Stow"
            return 1
        fi
    else
        log_success "GNU Stow is already installed"
    fi
}

stow_configurations() {
    log_info "Stowing configurations..."
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi
    
    cd "$DOTFILES_DIR" || {
        log_error "Failed to change to dotfiles directory"
        return 1
    }
    
    for config in $STOW_CONFIGS; do
        if [ -d "$config" ]; then
            log_step "Stowing $config..."
            if ! stow -v "$config" 2>/dev/null; then
                log_warning "Failed to stow $config, checking for conflicts..."
                if ! stow -R -v "$config"; then
                    log_error "Failed to restow $config"
                    return 1
                fi
            fi
        else
            log_warning "Configuration directory '$config' not found, skipping..."
        fi
    done
}

setup_tpm() {
    log_info "Setting up Tmux Plugin Manager..."
    
    if [ ! -d "$TPM_DIR" ]; then
        log_step "Cloning TPM..."
        if ! git clone "$TPM_REPO" "$TPM_DIR"; then
            log_error "Failed to clone TPM repository"
            return 1
        fi
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
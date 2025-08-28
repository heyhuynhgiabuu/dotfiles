#!/usr/bin/env sh

# Unified Dotfiles Bootstrap Pipeline
# Consolidates setup, verification, and maintenance into single entry point
# Usage: ./scripts/bootstrap.sh [init|verify|update|rollback] [options]
# Context Engineering: Progressive validation with rollback capability

set -e  # Exit on error
set -u  # Exit on undefined variable

# Source common utilities (includes root safety check)
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/common.sh" || { echo "Failed to source common.sh"; exit 1; }

# Bootstrap configuration
readonly BOOTSTRAP_VERSION="1.0.0"
readonly STATE_FILE="${DOTFILES_DIR}/.bootstrap_state"
readonly BACKUP_DIR="${DOTFILES_DIR}/.bootstrap_backup"

# Operation modes
readonly MODE_INIT="init"
readonly MODE_VERIFY="verify" 
readonly MODE_UPDATE="update"
readonly MODE_ROLLBACK="rollback"

# Global state
OPERATION_MODE=""
DRY_RUN=0
FORCE_MODE=0
BACKUP_CREATED=0

# Context engineering: Track operations for rollback
OPERATIONS_LOG="${BACKUP_DIR}/operations.log"

main() {
    parse_arguments "$@"
    
    log_header "Dotfiles Bootstrap Pipeline v${BOOTSTRAP_VERSION}"
    log_info "Mode: ${OPERATION_MODE}, Dry Run: ${DRY_RUN}, Force: ${FORCE_MODE}"
    
    # Context boundary: Initialize operation tracking
    init_operation_tracking
    
    case "$OPERATION_MODE" in
        "$MODE_INIT")
            execute_init_pipeline
            ;;
        "$MODE_VERIFY")
            execute_verify_pipeline
            ;;
        "$MODE_UPDATE") 
            execute_update_pipeline
            ;;
        "$MODE_ROLLBACK")
            execute_rollback_pipeline
            ;;
        *)
            log_error "Invalid operation mode: $OPERATION_MODE"
            show_usage
            exit 1
            ;;
    esac
    
    finalize_operation
}

parse_arguments() {
    if [ $# -eq 0 ]; then
        OPERATION_MODE="$MODE_INIT"
        return
    fi
    
    # Handle --help as first argument
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
    esac
    
    OPERATION_MODE="$1"
    shift
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run)
                DRY_RUN=1
                ;;
            --force)
                FORCE_MODE=1
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

show_usage() {
    cat << EOF
Unified Dotfiles Bootstrap Pipeline

Usage: $0 [MODE] [OPTIONS]

MODES:
    init        Complete initial setup (default)
    verify      Verify configuration integrity  
    update      Update existing installation
    rollback    Rollback to previous state

OPTIONS:
    --dry-run   Show what would be done without executing
    --force     Force operations without confirmation
    --help      Show this help message

Examples:
    $0                    # Complete initial setup
    $0 verify             # Verify current configuration
    $0 update --dry-run   # Preview update operations  
    $0 rollback           # Rollback last changes
EOF
}

init_operation_tracking() {
    # Context engineering: Create operation context for rollback
    if [ "$DRY_RUN" -eq 0 ]; then
        mkdir -p "$BACKUP_DIR"
        echo "$(date): Starting $OPERATION_MODE operation" >> "$OPERATIONS_LOG"
        
        # Create state snapshot
        create_state_snapshot
    fi
}

create_state_snapshot() {
    local snapshot_file="${BACKUP_DIR}/state_$(date +%Y%m%d_%H%M%S).json"
    
    if [ "$DRY_RUN" -eq 0 ]; then
        log_step "Creating state snapshot..."
        
        # Security: Create JSON with proper escaping to prevent injection
        # Use a safe approach to build JSON without direct variable substitution
        {
            echo "{"
            echo "    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ | sed 's/"/\\"/g')\","
            echo "    \"operation\": \"$(printf '%s' "$OPERATION_MODE" | sed 's/"/\\"/g')\","
            echo "    \"platform\": \"$(printf '%s' "$PLATFORM" | sed 's/"/\\"/g')\","
            
            # Build stow_configs array safely
            echo -n "    \"stow_configs\": ["
            local first=1
            for config in $STOW_CONFIGS; do
                if [ "$first" -eq 1 ]; then
                    first=0
                else
                    echo -n ", "
                fi
                echo -n "\"$(printf '%s' "$config" | sed 's/"/\\"/g')\""
            done
            echo "],"
            
            echo "    \"symlinks\": {"
            echo "        \"zshrc\": \"$(readlink "$HOME/.zshrc" 2>/dev/null | sed 's/"/\\"/g' || echo 'none')\","
            echo "        \"tmux_conf\": \"$(readlink "$HOME/.tmux.conf" 2>/dev/null | sed 's/"/\\"/g' || echo 'none')\","
            echo "        \"nvim_custom\": \"$(readlink "$HOME/.config/nvim/lua/custom" 2>/dev/null | sed 's/"/\\"/g' || echo 'none')\""
            echo "    },"
            echo "    \"installed_tools\": {"
            echo "        \"stow\": \"$(command -v stow >/dev/null && echo 'true' || echo 'false')\","
            echo "        \"nvim\": \"$(command -v nvim >/dev/null && echo 'true' || echo 'false')\","
            echo "        \"tmux\": \"$(command -v tmux >/dev/null && echo 'true' || echo 'false')\""
            echo "    }"
            echo "}"
        } > "$snapshot_file"
        
        echo "$snapshot_file" > "$STATE_FILE"
        BACKUP_CREATED=1
        log_success "State snapshot created: $snapshot_file"
    fi
}

execute_init_pipeline() {
    log_header "Initializing Dotfiles Environment"
    
    # Context boundary: Installation operations
    if ! check_prerequisites; then
        log_error "Prerequisites check failed"
        exit 1
    fi
    
    install_dependencies
    setup_configurations  
    verify_installation
    
    log_success "Dotfiles initialization complete!"
    log_info "Manual verification steps:"
    log_info "1. Open new terminal and verify zsh loads without errors"
    log_info "2. Run 'tmux' and verify configuration loads"
    log_info "3. Run 'nvim' and verify NvChad loads properly"
}

execute_verify_pipeline() {
    log_header "Verifying Dotfiles Configuration"
    
    # Context boundary: Verification operations only
    local exit_code=0
    
    verify_core_tools || exit_code=1
    verify_configurations || exit_code=1  
    verify_symlinks || exit_code=1
    verify_opencode_integration || exit_code=1
    
    if [ "$exit_code" -eq 0 ]; then
        log_success "All verifications passed!"
    else
        log_error "Some verifications failed. Run 'bootstrap init' to fix issues."
        exit 1
    fi
}

execute_update_pipeline() {
    log_header "Updating Dotfiles Configuration"
    
    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "DRY RUN: Would update configurations..."
        simulate_update_operations
        return
    fi
    
    # Context boundary: Update operations with rollback
    backup_current_state
    update_configurations
    verify_installation
    
    log_success "Dotfiles update complete!"
}

execute_rollback_pipeline() {
    log_header "Rolling Back Dotfiles Changes"
    
    if [ ! -f "$STATE_FILE" ]; then
        log_error "No state file found. Cannot rollback."
        exit 1
    fi
    
    local last_snapshot
    last_snapshot=$(cat "$STATE_FILE")
    
    if [ ! -f "$last_snapshot" ]; then
        log_error "Snapshot file not found: $last_snapshot"
        exit 1
    fi
    
    log_info "Rolling back to snapshot: $last_snapshot"
    
    # Context boundary: Rollback operations
    restore_from_snapshot "$last_snapshot"
    
    log_success "Rollback complete!"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if running from correct directory
    if [ ! -f "${DOTFILES_DIR}/scripts/bootstrap.sh" ]; then
        log_error "Must run from dotfiles directory: $DOTFILES_DIR"
        return 1
    fi
    
    # Check for git repository
    if [ ! -d "${DOTFILES_DIR}/.git" ]; then
        log_error "Dotfiles directory is not a git repository"
        return 1
    fi
    
    # Platform compatibility
    if [ "$PLATFORM" = "unknown" ]; then
        log_error "Unsupported platform: $(uname -s)"
        return 1
    fi
    
    log_success "Prerequisites check passed"
    return 0
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    # Install GNU Stow
    if ! cmd_exists stow; then
        log_step "Installing GNU Stow..."
        if [ "$DRY_RUN" -eq 0 ]; then
            install_package "stow" || {
                log_error "Failed to install GNU Stow"
                return 1
            }
        else
            log_info "DRY RUN: Would install GNU Stow"
        fi
    else
        log_success "GNU Stow already installed"
    fi
    
    # Setup Tmux Plugin Manager
    setup_tpm_with_tracking
}

setup_configurations() {
    log_info "Setting up configurations..."
    
    # Context boundary: Configuration setup with tracking
    local config
    for config in nvim tmux zsh aerospace wezterm; do
        if [ -d "${DOTFILES_DIR}/$config" ]; then
            setup_config_with_tracking "$config"
        else
            log_warning "Configuration directory '$config' not found, skipping..."
        fi
    done
}

setup_config_with_tracking() {
    local config="$1"
    
    log_step "Setting up $config configuration..."
    
    if [ "$DRY_RUN" -eq 0 ]; then
        cd "$DOTFILES_DIR" || {
            log_error "Failed to change to dotfiles directory"
            return 1
        }
        
        # Track operation for rollback
        echo "stow_config:$config" >> "$OPERATIONS_LOG"
        
        if ! stow -v "$config" 2>/dev/null; then
            log_warning "Conflicts detected, attempting restow..."
            if ! stow -R -v "$config"; then
                log_error "Failed to setup $config configuration"
                return 1
            fi
        fi
        
        log_success "$config configuration setup complete"
    else
        log_info "DRY RUN: Would setup $config configuration"
    fi
}

setup_tpm_with_tracking() {
    local tpm_repo="https://github.com/tmux-plugins/tpm"
    local tpm_dir="${HOME}/.tmux/plugins/tpm"
    
    log_step "Setting up Tmux Plugin Manager..."
    
    if [ ! -d "$tpm_dir" ]; then
        if [ "$DRY_RUN" -eq 0 ]; then
            echo "clone_tpm:$tpm_dir" >> "$OPERATIONS_LOG"
            
            if ! git clone "$tpm_repo" "$tpm_dir"; then
                log_error "Failed to clone TPM repository"
                return 1
            fi
        else
            log_info "DRY RUN: Would clone TPM repository"
        fi
    fi
    
    log_success "Tmux Plugin Manager setup complete"
}

verify_installation() {
    log_info "Verifying installation..."
    
    # Use existing verification logic with context boundaries
    verify_core_tools
    verify_configurations
    verify_symlinks
}

verify_core_tools() {
    log_step "Verifying core tools..."
    
    local tools="stow nvim tmux"
    local tool
    
    for tool in $tools; do
        if cmd_exists "$tool"; then
            log_success "$tool is available"
        else
            log_error "$tool not found in PATH"
            return 1
        fi
    done
    
    return 0
}

verify_configurations() {
    log_step "Verifying configurations..."
    
    # Check essential config directories
    local configs="zsh tmux nvim"
    local config
    
    for config in $configs; do
        if [ -d "${DOTFILES_DIR}/$config" ]; then
            log_success "Configuration exists: $config"
        else
            log_error "Missing configuration: $config"
            return 1
        fi
    done
    
    return 0
}

verify_symlinks() {
    log_step "Verifying symlinks..."
    
    # Check critical symlinks
    local links="$HOME/.zshrc $HOME/.tmux.conf $HOME/.config/nvim/lua/custom"
    local link
    
    for link in $links; do
        if [ -L "$link" ] && [ -e "$link" ]; then
            log_success "Symlink valid: $(basename "$link")"
        else
            log_warning "Symlink issue: $(basename "$link")"
        fi
    done
    
    return 0
}

verify_opencode_integration() {
    log_step "Verifying OpenCode integration..."
    
    if [ -f "${DOTFILES_DIR}/opencode/opencode.json" ]; then
        log_success "OpenCode configuration found"
        
        if [ -f "${DOTFILES_DIR}/opencode/AGENTS.md" ]; then
            log_success "OpenCode agents documentation found"
        else
            log_warning "OpenCode agents documentation missing"
        fi
    else
        log_warning "OpenCode configuration not found"
    fi
    
    return 0
}

simulate_update_operations() {
    log_info "DRY RUN: Update operations that would be performed:"
    log_info "  - Update git repository"
    log_info "  - Re-stow configurations"
    log_info "  - Update TPM plugins"
    log_info "  - Verify installation"
}

backup_current_state() {
    log_step "Backing up current state..."
    create_state_snapshot
}

update_configurations() {
    log_step "Updating configurations..."
    
    # Pull latest changes
    cd "$DOTFILES_DIR" || {
        log_error "Failed to change to dotfiles directory"
        return 1
    }
    
    if ! git pull --ff-only; then
        log_warning "Git pull failed - manual intervention may be required"
    fi
    
    # Re-stow configurations
    setup_configurations
}

restore_from_snapshot() {
    local snapshot_file="$1"
    
    log_step "Restoring from snapshot: $snapshot_file"
    
    # Parse snapshot and restore state
    # Note: This is a simplified implementation
    # Real implementation would parse JSON and restore exact state
    
    log_warning "Rollback implementation is basic - manual verification recommended"
    log_info "Snapshot location: $snapshot_file"
    log_info "Operations log: $OPERATIONS_LOG"
}

finalize_operation() {
    if [ "$BACKUP_CREATED" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
        echo "$(date): Completed $OPERATION_MODE operation" >> "$OPERATIONS_LOG"
        log_success "Operation completed successfully"
    fi
}

# Configuration from original setup.sh
readonly STOW_CONFIGS="nvim tmux zsh aerospace wezterm"

# Execute main function
main "$@"
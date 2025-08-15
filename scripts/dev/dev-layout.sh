#!/usr/bin/env sh

# General development tmux layout
# Usage: dev-layout.sh [session-name]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="devlayout"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    
    log_info "Creating development tmux layout: $session_name"
    
    # Create or attach to session
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name"
    
    # Setup layout
    setup_development_layout "$session_name"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_development_layout() {
    local session="$1"
    
    # Start with nvim in left pane
    tmux send-keys -t "$session" 'nvim' C-m
    
    # Split right vertically for opencode
    tmux split-window -h -t "$session"
    tmux send-keys -t "$session:0.1" 'opencode' C-m
    
    # Split bottom right horizontally for terminal
    tmux split-window -v -t "$session:0.1"
    
    # Select left pane (nvim) to start
    tmux select-pane -t "$session:0.0"
    
    log_success "Development layout created successfully"
}

# Execute main function
main "$@"#!/bin/bash

# General development tmux layout
# Usage: dev-layout.sh [session-name]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="devlayout"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    
    log_info "Creating development tmux layout: $session_name"
    
    # Create or attach to session
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name"
    
    # Setup layout
    setup_development_layout "$session_name"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_development_layout() {
    local session="$1"
    
    # Start with nvim in left pane
    tmux send-keys -t "$session" 'nvim' C-m
    
    # Split right vertically for opencode
    tmux split-window -h -t "$session"
    tmux send-keys -t "$session:0.1" 'opencode' C-m
    
    # Split bottom right horizontally for terminal
    tmux split-window -v -t "$session:0.1"
    
    # Select left pane (nvim) to start
    tmux select-pane -t "$session:0.0"
    
    log_success "Development layout created successfully"
}

# Execute main function
main "$@"
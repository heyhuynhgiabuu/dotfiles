#!/usr/bin/env sh

# Go development tmux layout with specialized windows
# Usage: tmux-go-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="go-dev"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating Go development tmux session: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup Go development layout
    setup_go_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_go_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create additional specialized windows
    create_test_window "$session" "$project_path"
    create_tools_window "$session" "$project_path"
    create_docs_window "$session" "$project_path"
    
    # Final configuration
    finalize_layout "$session"
}

setup_editor_window() {
    local session="$1"
    local project_path="$2"
    
    # Rename first window to 'editor'
    tmux rename-window -t "$session:0" "editor"
    
    # Split the editor window into panes
    tmux split-window -h -t "$session:editor" -c "$project_path"
    tmux split-window -v -t "$session:editor.1" -c "$project_path"
    
    # Setup panes with appropriate commands
    tmux send-keys -t "$session:editor.0" "nvim ." C-m
    tmux send-keys -t "$session:editor.1" "# Terminal for go run, go test, etc." C-m
    tmux send-keys -t "$session:editor.2" "# Watch mode or logs" C-m
    
    # Set pane sizes (editor takes 60%, terminal 25%, logs 15%)
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_test_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "test" -c "$project_path"
    tmux send-keys -t "$session:test" "# Run: go test -v ./..." C-m
}

create_tools_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "tools" -c "$project_path"
    tmux send-keys -t "$session:tools" "# Tools: gofmt, golangci-lint, etc." C-m
}

create_docs_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "docs" -c "$project_path"
    tmux send-keys -t "$session:docs" "# Go docs: go doc, or open pkg.go.dev" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "Go development layout created successfully"
}

# Execute main function
main "$@"#!/bin/bash

# Go development tmux layout with specialized windows
# Usage: tmux-go-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="go-dev"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating Go development tmux session: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup Go development layout
    setup_go_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_go_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create additional specialized windows
    create_test_window "$session" "$project_path"
    create_tools_window "$session" "$project_path"
    create_docs_window "$session" "$project_path"
    
    # Final configuration
    finalize_layout "$session"
}

setup_editor_window() {
    local session="$1"
    local project_path="$2"
    
    # Rename first window to 'editor'
    tmux rename-window -t "$session:0" "editor"
    
    # Split the editor window into panes
    tmux split-window -h -t "$session:editor" -c "$project_path"
    tmux split-window -v -t "$session:editor.1" -c "$project_path"
    
    # Setup panes with appropriate commands
    tmux send-keys -t "$session:editor.0" "nvim ." C-m
    tmux send-keys -t "$session:editor.1" "# Terminal for go run, go test, etc." C-m
    tmux send-keys -t "$session:editor.2" "# Watch mode or logs" C-m
    
    # Set pane sizes (editor takes 60%, terminal 25%, logs 15%)
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_test_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "test" -c "$project_path"
    tmux send-keys -t "$session:test" "# Run: go test -v ./..." C-m
}

create_tools_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "tools" -c "$project_path"
    tmux send-keys -t "$session:tools" "# Tools: gofmt, golangci-lint, etc." C-m
}

create_docs_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "docs" -c "$project_path"
    tmux send-keys -t "$session:docs" "# Go docs: go doc, or open pkg.go.dev" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "Go development layout created successfully"
}

# Execute main function
main "$@"
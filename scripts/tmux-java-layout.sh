#!/bin/bash

# Java development tmux layout
# Usage: tmux-java-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="java-dev"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating Java development tmux session: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup Java development layout
    setup_java_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_java_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create additional specialized windows
    create_build_window "$session" "$project_path"
    create_test_window "$session" "$project_path"
    create_debug_window "$session" "$project_path"
    
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
    tmux send-keys -t "$session:editor.1" "# Terminal for mvn/gradle commands" C-m
    tmux send-keys -t "$session:editor.2" "# Logs or server output" C-m
    
    # Set pane sizes
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_build_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "build" -c "$project_path"
    tmux send-keys -t "$session:build" "# Run: mvn compile or gradle build" C-m
}

create_test_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "test" -c "$project_path"
    tmux send-keys -t "$session:test" "# Run: mvn test or gradle test" C-m
}

create_debug_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "debug" -c "$project_path"
    tmux send-keys -t "$session:debug" "# Debugging and profiling tools" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "Java development layout created successfully"
}

# Execute main function
main "$@"#!/bin/bash

# Java development tmux layout
# Usage: tmux-java-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="java-dev"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating Java development tmux session: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup Java development layout
    setup_java_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_java_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create additional specialized windows
    create_build_window "$session" "$project_path"
    create_test_window "$session" "$project_path"
    create_debug_window "$session" "$project_path"
    
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
    tmux send-keys -t "$session:editor.1" "# Terminal for mvn/gradle commands" C-m
    tmux send-keys -t "$session:editor.2" "# Logs or server output" C-m
    
    # Set pane sizes
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_build_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "build" -c "$project_path"
    tmux send-keys -t "$session:build" "# Run: mvn compile or gradle build" C-m
}

create_test_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "test" -c "$project_path"
    tmux send-keys -t "$session:test" "# Run: mvn test or gradle test" C-m
}

create_debug_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "debug" -c "$project_path"
    tmux send-keys -t "$session:debug" "# Debugging and profiling tools" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "Java development layout created successfully"
}

# Execute main function
main "$@"
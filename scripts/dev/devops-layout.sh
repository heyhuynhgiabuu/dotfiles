#!/bin/bash

# DevOps development layout script
# Creates a specialized tmux layout for DevOps workflows
# Usage: devops-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="devops"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating DevOps tmux layout: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup DevOps layout
    setup_devops_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_devops_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create specialized windows for DevOps
    create_deployment_window "$session" "$project_path"
    create_monitoring_window "$session" "$project_path"
    create_infrastructure_window "$session" "$project_path"
    
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
    tmux send-keys -t "$session:editor.1" "# Terminal for commands" C-m
    tmux send-keys -t "$session:editor.2" "# Logs and monitoring" C-m
    
    # Set pane sizes
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_deployment_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "deploy" -c "$project_path"
    tmux send-keys -t "$session:deploy" "# Deployment commands: kubectl, terraform, ansible" C-m
}

create_monitoring_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "monitor" -c "$project_path"
    
    # Split for multiple monitoring tools
    tmux split-window -v -t "$session:monitor" -c "$project_path"
    
    tmux send-keys -t "$session:monitor.0" "# Application logs: tail -f logs/app.log" C-m
    tmux send-keys -t "$session:monitor.1" "# System monitoring: htop, docker stats" C-m
}

create_infrastructure_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "infra" -c "$project_path"
    tmux send-keys -t "$session:infra" "# Infrastructure: terraform, pulumi, cloudformation" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "DevOps layout created successfully"
}

# Execute main function
main "$@"#!/bin/bash

# DevOps development layout script
# Creates a specialized tmux layout for DevOps workflows
# Usage: devops-layout.sh [session-name] [project-path]

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly DEFAULT_SESSION="devops"

main() {
    local session_name="${1:-$DEFAULT_SESSION}"
    local project_path="${2:-$(pwd)}"
    
    log_header "Creating DevOps tmux layout: $session_name"
    log_info "Project path: $project_path"
    
    # Check if session already exists
    if tmux_session_exists "$session_name"; then
        log_info "Session '$session_name' already exists. Attaching..."
        tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create new session
    create_tmux_session "$session_name" "$project_path"
    
    # Setup DevOps layout
    setup_devops_layout "$session_name" "$project_path"
    
    # Attach to session
    tmux attach-session -t "$session_name"
}

setup_devops_layout() {
    local session="$1"
    local project_path="$2"
    
    # Setup main editor window
    setup_editor_window "$session" "$project_path"
    
    # Create specialized windows for DevOps
    create_deployment_window "$session" "$project_path"
    create_monitoring_window "$session" "$project_path"
    create_infrastructure_window "$session" "$project_path"
    
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
    tmux send-keys -t "$session:editor.1" "# Terminal for commands" C-m
    tmux send-keys -t "$session:editor.2" "# Logs and monitoring" C-m
    
    # Set pane sizes
    tmux resize-pane -t "$session:editor.0" -x 60%
    tmux resize-pane -t "$session:editor.1" -y 70%
}

create_deployment_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "deploy" -c "$project_path"
    tmux send-keys -t "$session:deploy" "# Deployment commands: kubectl, terraform, ansible" C-m
}

create_monitoring_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "monitor" -c "$project_path"
    
    # Split for multiple monitoring tools
    tmux split-window -v -t "$session:monitor" -c "$project_path"
    
    tmux send-keys -t "$session:monitor.0" "# Application logs: tail -f logs/app.log" C-m
    tmux send-keys -t "$session:monitor.1" "# System monitoring: htop, docker stats" C-m
}

create_infrastructure_window() {
    local session="$1"
    local project_path="$2"
    
    tmux new-window -t "$session" -n "infra" -c "$project_path"
    tmux send-keys -t "$session:infra" "# Infrastructure: terraform, pulumi, cloudformation" C-m
}

finalize_layout() {
    local session="$1"
    
    # Select the editor pane and window
    tmux select-pane -t "$session:editor.0"
    tmux select-window -t "$session:editor"
    
    log_success "DevOps layout created successfully"
}

# Execute main function
main "$@"
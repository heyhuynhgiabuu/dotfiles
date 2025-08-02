#!/bin/bash

# Note management script with tmux integration
# Find or create notes and open them in Neovim with tmux session management
# Usage: bash scripts/note.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NOTES_DIR="${DOTFILES_DIR}/notes"
readonly EDITOR="nvim"
readonly NOTES_SESSION="notes"

main() {
    # Ensure notes directory exists
    mkdir -p "$NOTES_DIR"
    
    # Check for fzf
    if ! cmd_exists fzf; then
        log_error "fzf is required but not installed"
        log_info "Install with: brew install fzf (macOS) or package manager (Linux)"
        exit 1
    fi
    
    # Select or create note
    local selected_file
    selected_file=$(select_note)
    
    if [[ -z "$selected_file" ]]; then
        log_info "No note selected"
        exit 0
    fi
    
    # Open note with appropriate method
    open_note "$selected_file"
}

select_note() {
    log_info "Searching for notes in $NOTES_DIR..."
    
    cd "$NOTES_DIR"
    
    # Use find instead of git ls-files for broader compatibility
    local selected_file
    selected_file=$(find . -type f -name "*.md" -o -name "*.txt" -o -name "*.org" 2>/dev/null | fzf --select-1 --exit-0 --prompt="Select note: ")
    
    if [[ -n "$selected_file" && ! -f "$selected_file" ]]; then
        create_note_file "$selected_file"
    fi
    
    echo "$selected_file"
}

create_note_file() {
    local file_path="$1"
    
    log_info "Creating new note: $file_path"
    
    # Create directory structure if needed
    mkdir -p "$(dirname "$file_path")"
    touch "$file_path"
    
    # Add basic markdown header if it's a markdown file
    if [[ "$file_path" == *.md ]]; then
        local note_title
        note_title=$(basename "$file_path" .md | tr '_-' ' ')
        echo "# $note_title" > "$file_path"
        echo "" >> "$file_path"
        echo "Created: $(date '+%Y-%m-%d %H:%M:%S')" >> "$file_path"
        echo "" >> "$file_path"
    fi
}

open_note() {
    local file="$1"
    local full_path="${NOTES_DIR}/${file}"
    
    if [[ -n "$TMUX" ]]; then
        open_in_tmux "$full_path"
    else
        open_new_tmux_session "$full_path"
    fi
}

open_in_tmux() {
    local file_path="$1"
    
    log_info "Opening note in current tmux session"
    
    # Check if nvim is already running in current session
    if tmux list-panes -F '#{pane_current_command}' | grep -q "nvim"; then
        tmux send-keys ":e $file_path" C-m
    else
        tmux new-window "$EDITOR $file_path"
    fi
}

open_new_tmux_session() {
    local file_path="$1"
    
    log_info "Creating new tmux session: $NOTES_SESSION"
    
    if tmux_session_exists "$NOTES_SESSION"; then
        tmux attach-session -t "$NOTES_SESSION"
    else
        tmux new-session -s "$NOTES_SESSION" "$EDITOR $file_path"
    fi
}

# Execute main function
main "$@"#!/bin/bash

# Note management script with tmux integration
# Find or create notes and open them in Neovim with tmux session management
# Usage: bash scripts/note.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Configuration
readonly NOTES_DIR="${DOTFILES_DIR}/notes"
readonly EDITOR="nvim"
readonly NOTES_SESSION="notes"

main() {
    # Ensure notes directory exists
    mkdir -p "$NOTES_DIR"
    
    # Check for fzf
    if ! cmd_exists fzf; then
        log_error "fzf is required but not installed"
        log_info "Install with: brew install fzf (macOS) or package manager (Linux)"
        exit 1
    fi
    
    # Select or create note
    local selected_file
    selected_file=$(select_note)
    
    if [[ -z "$selected_file" ]]; then
        log_info "No note selected"
        exit 0
    fi
    
    # Open note with appropriate method
    open_note "$selected_file"
}

select_note() {
    log_info "Searching for notes in $NOTES_DIR..."
    
    cd "$NOTES_DIR"
    
    # Use find instead of git ls-files for broader compatibility
    local selected_file
    selected_file=$(find . -type f -name "*.md" -o -name "*.txt" -o -name "*.org" 2>/dev/null | fzf --select-1 --exit-0 --prompt="Select note: ")
    
    if [[ -n "$selected_file" && ! -f "$selected_file" ]]; then
        create_note_file "$selected_file"
    fi
    
    echo "$selected_file"
}

create_note_file() {
    local file_path="$1"
    
    log_info "Creating new note: $file_path"
    
    # Create directory structure if needed
    mkdir -p "$(dirname "$file_path")"
    touch "$file_path"
    
    # Add basic markdown header if it's a markdown file
    if [[ "$file_path" == *.md ]]; then
        local note_title
        note_title=$(basename "$file_path" .md | tr '_-' ' ')
        echo "# $note_title" > "$file_path"
        echo "" >> "$file_path"
        echo "Created: $(date '+%Y-%m-%d %H:%M:%S')" >> "$file_path"
        echo "" >> "$file_path"
    fi
}

open_note() {
    local file="$1"
    local full_path="${NOTES_DIR}/${file}"
    
    if [[ -n "$TMUX" ]]; then
        open_in_tmux "$full_path"
    else
        open_new_tmux_session "$full_path"
    fi
}

open_in_tmux() {
    local file_path="$1"
    
    log_info "Opening note in current tmux session"
    
    # Check if nvim is already running in current session
    if tmux list-panes -F '#{pane_current_command}' | grep -q "nvim"; then
        tmux send-keys ":e $file_path" C-m
    else
        tmux new-window "$EDITOR $file_path"
    fi
}

open_new_tmux_session() {
    local file_path="$1"
    
    log_info "Creating new tmux session: $NOTES_SESSION"
    
    if tmux_session_exists "$NOTES_SESSION"; then
        tmux attach-session -t "$NOTES_SESSION"
    else
        tmux new-session -s "$NOTES_SESSION" "$EDITOR $file_path"
    fi
}

# Execute main function
main "$@"
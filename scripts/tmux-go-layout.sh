#!/bin/bash

# Go Development tmux layout
# Usage: tmux-go-layout [session-name] [project-path]

SESSION_NAME=${1:-"go-dev"}
PROJECT_PATH=${2:-$(pwd)}

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

echo "🐹 Creating Go development tmux session: $SESSION_NAME"
echo "📁 Project path: $PROJECT_PATH"

# Create new session
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_PATH"

# Rename first window to 'editor'
tmux rename-window -t "$SESSION_NAME:0" "editor"

# Split the editor window
tmux split-window -h -t "$SESSION_NAME:editor" -c "$PROJECT_PATH"
tmux split-window -v -t "$SESSION_NAME:editor.1" -c "$PROJECT_PATH"

# Set up panes
tmux send-keys -t "$SESSION_NAME:editor.0" "nvim ." C-m
tmux send-keys -t "$SESSION_NAME:editor.1" "# Terminal for go run, go test, etc." C-m
tmux send-keys -t "$SESSION_NAME:editor.2" "# Watch mode or logs" C-m

# Create additional windows
tmux new-window -t "$SESSION_NAME" -n "test" -c "$PROJECT_PATH"
tmux send-keys -t "$SESSION_NAME:test" "# Run: go test -v ./..." C-m

tmux new-window -t "$SESSION_NAME" -n "tools" -c "$PROJECT_PATH"
tmux send-keys -t "$SESSION_NAME:tools" "# Tools: gofmt, golangci-lint, etc." C-m

# Create a window for documentation/browser
tmux new-window -t "$SESSION_NAME" -n "docs" -c "$PROJECT_PATH"
tmux send-keys -t "$SESSION_NAME:docs" "# Go docs: go doc, or open pkg.go.dev" C-m

# Set pane sizes (editor takes 60%, terminal 25%, logs 15%)
tmux resize-pane -t "$SESSION_NAME:editor.0" -x 60%
tmux resize-pane -t "$SESSION_NAME:editor.1" -y 70%

# Select the editor pane and attach
tmux select-pane -t "$SESSION_NAME:editor.0"
tmux select-window -t "$SESSION_NAME:editor"
tmux attach-session -t "$SESSION_NAME"

# Tự động tạo layout cho project
# File: ~/.local/bin/dev-setup
#!/bin/bash
PROJECT_PATH="$1"
cd "$PROJECT_PATH" || exit

# Tạo 3 panes: code, logs, commands
wezterm cli split-pane --horizontal --cwd "$PROJECT_PATH"
wezterm cli split-pane --vertical --cwd "$PROJECT_PATH"

# Pane 1: Editor
wezterm cli send-text "nvim ." --pane-id 0

# Pane 2: Logs/monitoring  
wezterm cli send-text "tail -f logs/app.log" --pane-id 1

# Pane 3: Commands
wezterm cli activate-pane --pane-id 2

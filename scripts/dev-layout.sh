#!/bin/bash

SESSION="devlayout"

# Start a new tmux session, detached
tmux new-session -d -s $SESSION

# Left pane: nvim
tmux send-keys -t $SESSION 'nvim' C-m

# Split right vertically (creates right pane)
tmux split-window -h -t $SESSION

# Top right: opencode (replace 'opencode' with your actual command)
tmux send-keys -t $SESSION:0.1 'opencode' C-m

# Split bottom right horizontally (creates bottom right pane)
tmux split-window -v -t $SESSION:0.1

# Bottom right: terminal (default shell, so no command needed)

# Select left pane to start
tmux select-pane -t $SESSION:0.0

# Attach to the session
tmux attach-session -t $SESSION



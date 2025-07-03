#!/bin/bash
tmux new-session -d -s dev

tmux rename-window -t dev 'Code'
tmux send-keys -t dev 'cd ~/Developer && ls .' C-m

#tmux new-window -t dev -n 'Logs'
#tmux send-keys -t dev 'cd ~/Developer && tail -f logs/app.log' C-m

tmux attach -t dev


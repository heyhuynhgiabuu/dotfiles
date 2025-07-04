#!/bin/bash
SESSION=java
PROJECT_PATH=~/Developer

tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s $SESSION -c $PROJECT_PATH -n dev \
    \; send-keys -t $SESSION 'nvim .' C-m \
    \; split-window -h -c "#{pane_current_path}" \
    \; send-keys -t $SESSION:bash 'ls' C-m
    \; new-window -n git -c $PROJECT_PATH \
    \; send-keys -t $SESSION:git 'git status' C-m
fi

tmux attach-session -t $SESSION


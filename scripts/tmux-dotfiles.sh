#!/bin/bash

SESSION="dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Creating tmux session: $SESSION"
  
  tmux new-session -d -s "$SESSION" -c "$DOTFILES_DIR" -n "editor"
  tmux send-keys -t "$SESSION":1 'nvim' C-m
  
  tmux new-window -t "$SESSION":2 -n "git" -c "$DOTFILES_DIR"
  tmux send-keys -t "$SESSION":2 'git status' C-m
  
  tmux new-window -t "$SESSION":3 -n "terminal" -c "$DOTFILES_DIR"
  tmux split-window -h -t "$SESSION":3 -c "$DOTFILES_DIR"
  tmux split-window -v -t "$SESSION":3.2 -c "$DOTFILES_DIR"
  
  tmux new-window -t "$SESSION":4 -n "monitor" -c "$DOTFILES_DIR"
  
  tmux select-window -t "$SESSION":1
  
  echo "✅ Session created successfully!"
else
  echo "Session $SESSION already exists"
fi

tmux attach-t "$SESSION"

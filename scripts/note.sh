#!/usr/bin/env bash
#
# Find or create a note in my notes directory and open it in Neovim.
#
# This script is inspired by a similar one from @gothenburg.
#
# It fuzzy finds in the notes directory, which is a git repo. It will only
# search for files tracked by git, so to create a new file, you have to type
# the name of the file and press enter.
#
# To use this, you need to have fzf installed.
#
# It also includes the logic to either attach to an existing tmux session or
# create a new one, optionally attaching to an existing nvim instance if one is
# running in that session.

NOTES_DIR="$HOME/dotfiles/notes"
EDITOR="nvim"

# Ensure the notes directory exists
mkdir -p "$NOTES_DIR"

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf could not be found, please install it."
    exit 1
fi

# Use fzf to select a note. The fzf command will search for files under git
# control. If you type a filename that doesn't exist and press enter, fzf
# will output that filename.
#
# --select-1: Automatically select the only match
# --exit-0: Exit immediately if there's no match
# --print-query: Print the query if there are no results
# --search-path: The directory to search in
cd "$NOTES_DIR"
# file=$(git ls-files | fzf --select-1 --exit-0)
file=$(find . -type f | fzf --select-1 --exit-0)

# If fzf was cancelled (ESC), then exit
if [ -z "$file" ]; then
    echo "No note selected."
    exit 0
fi

# If the selected file doesn't exist, create it
if [ ! -f "$file" ]; then
    # file name may include slash, so we need to make sure the directory exists
    mkdir -p "$(dirname "$file")"
    touch "$file"
fi

# This part is for tmux integration.
# If we are inside tmux, we want to open the file in the current session.
# If we are not in tmux, we want to create a new session.
if [ -n "$TMUX" ]; then
    # If nvim is running in the current session, open the file in it.
    if tmux list-panes -F '#{pane_current_command}' | grep -q "nvim"; then
        tmux send-keys ":e $NOTES_DIR/$file" C-m
    else
        tmux new-window "$EDITOR $NOTES_DIR/$file"
    fi
else
    # If not in tmux, create a new session named "notes"
    tmux new-session -s "notes" "$EDITOR $NOTES_DIR/$file"
fi


# Tmux Best Practices Guide

Complete guide to mastering tmux workflows and CLI usage.

## Core Concepts

```
Session (entire tmux instance)
  └── Window (like browser tabs)
      └── Pane (split screen within window)
```

**Mental Model:**

- **Session** = Project (dotfiles, work, personal)
- **Window** = Task (code, server, docs, tests)
- **Pane** = View (editor + terminal, logs + commands)

## Essential Commands (CLI)

### Session Management

```bash
# Create new session
tmux new -s dotfiles              # Named session
tmux new -s work -c ~/projects    # Start in specific directory

# List all sessions
tmux ls

# Attach to session
tmux attach -t dotfiles           # Specific session
tmux a                            # Last session

# Kill session
tmux kill-session -t work         # Specific session
tmux kill-server                  # Kill ALL sessions

# Rename session (from outside)
tmux rename-session -t old new

# Switch between sessions (from inside)
Prefix + s                        # Interactive list
Prefix + (                        # Previous session
Prefix + )                        # Next session
```

### Window Management

```bash
# From CLI (when creating session)
tmux new -s dev \; split-window -h \; split-window -v

# Inside tmux (using Prefix = Ctrl+b by default)
Prefix + c                        # Create new window
Prefix + ,                        # Rename window
Prefix + &                        # Kill window (confirm)
Prefix + w                        # List all windows
Prefix + [0-9]                    # Jump to window number
Prefix + n                        # Next window
Prefix + p                        # Previous window
Prefix + l                        # Last window
```

### Pane Management

```bash
# Your custom keybindings (from .tmux.conf)
Prefix + h/j/k/l                  # Navigate panes (vi-style)

# Standard pane commands
Prefix + "                        # Split horizontal (top/bottom)
Prefix + %                        # Split vertical (left/right)
Prefix + x                        # Kill current pane
Prefix + z                        # Zoom/unzoom pane (fullscreen)
Prefix + {                        # Move pane left
Prefix + }                        # Move pane right
Prefix + Space                    # Cycle through layouts
Prefix + q                        # Show pane numbers (quick jump)
Prefix + !                        # Break pane to new window

# Resize panes (hold Prefix, then arrow keys)
Prefix + Ctrl+↑/↓/←/→            # Resize in direction

# With mouse enabled (you have this!)
Click pane border + drag          # Resize panes
Click pane                        # Switch to pane
```

## Best Practice Workflows

### 1. Project-Based Sessions

```bash
# Development workflow
tmux new -s myapp
Prefix + c                        # New window for server
Prefix + ,                        # Name it "server"
# Type: npm run dev

Prefix + c                        # New window for editor
Prefix + ,                        # Name it "editor"
# Type: nvim

Prefix + c                        # New window for git
Prefix + ,                        # Name it "git"

# Result: Clean separation by function
```

### 2. Split Pane Workflow

```bash
# Common layout: Editor + Terminal
tmux new -s code
Prefix + %                        # Split vertical
# Left pane: nvim src/app.js
# Right pane: npm test --watch

# Or: Code + Logs + Commands
Prefix + "                        # Split horizontal
Prefix + h                        # Move to left pane
Prefix + %                        # Split vertical again
# Layout: [Editor | Terminal]
#         [        | Logs    ]
```

### 3. Quick Context Switching

```bash
# Morning routine
tmux new -s dotfiles -c ~/dotfiles
tmux new -s work -c ~/projects/work
tmux new -s personal -c ~/projects/personal

# Switch between projects instantly
Prefix + s                        # Show session list
# Navigate with j/k (vi-mode), Enter to select

# From CLI (outside tmux)
tmux attach -t work               # Jump to work
```

### 4. Persistent Development Environment

```bash
# Start your day
tmux attach || tmux new -s main

# Work all day with multiple windows/panes
# Close terminal accidentally? No problem!

# Reconnect
tmux attach

# Everything still running! (thanks to tmux-resurrect plugin)
```

## Advanced CLI Patterns

### Scripted Session Setup

```bash
# Create file: ~/dotfiles/scripts/tmux-dev.sh
#!/bin/bash

SESSION="dev"
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # Create session
  tmux new-session -d -s $SESSION -c ~/projects

  # Window 1: Editor
  tmux rename-window -t $SESSION:1 'editor'
  tmux send-keys -t $SESSION:1 'nvim' C-m

  # Window 2: Server
  tmux new-window -t $SESSION:2 -n 'server'
  tmux send-keys -t $SESSION:2 'npm run dev' C-m

  # Window 3: Git
  tmux new-window -t $SESSION:3 -n 'git'

  # Window 4: Database (split panes)
  tmux new-window -t $SESSION:4 -n 'db'
  tmux send-keys -t $SESSION:4 'docker-compose up' C-m
  tmux split-window -h -t $SESSION:4
  tmux send-keys -t $SESSION:4 'psql mydb' C-m

  # Select first window
  tmux select-window -t $SESSION:1
fi

tmux attach-t $SESSION
```

```bash
# Make it executable
chmod +x ~/dotfiles/scripts/tmux-dev.sh

# Use it
~/dotfiles/scripts/tmux-dev.sh
```

### One-Liner Session Creation

```bash
# Create complete dev environment in one command
tmux new -s api -c ~/api \; \
  split-window -h \; \
  send-keys 'npm run dev' C-m \; \
  split-window -v \; \
  send-keys 'npm run test:watch' C-m \; \
  select-pane -t 0 \; \
  send-keys 'nvim' C-m

# Breakdown:
# \; = command separator
# C-m = Enter key
# -t 0 = select pane 0
```

### Remote Development

```bash
# On remote server
ssh user@server
tmux new -s remote-dev

# Start long-running tasks
npm run build
# Network dies? No problem!

# Reconnect later
ssh user@server
tmux attach -t remote-dev
# Build still running!
```

## Your Custom Keybindings (from .tmux.conf)

```bash
Prefix + r                        # Reload config (🔁 Reloaded!)
Prefix + h/j/k/l                  # Navigate panes (vi-style)
Prefix + n                        # Quick note with your script
Prefix + E                        # Quick note in split pane

# Vi-mode in copy mode (you have this enabled)
Prefix + [                        # Enter copy mode
h/j/k/l                          # Navigate
v                                # Visual selection
y                                # Yank (copy) - tmux-yank plugin
q                                # Quit copy mode
Prefix + ]                        # Paste
```

## Copy-Paste Best Practices

```bash
# Enter copy mode
Prefix + [

# Navigate with vi keys (h/j/k/l)
Space                            # Start selection
Enter                            # Copy selection (or 'y' with tmux-yank)
q                                # Exit copy mode

# Paste
Prefix + ]

# With mouse enabled (you have this!)
Click + drag                     # Select text
Release                          # Auto-copy (tmux-yank)
Middle-click / Cmd+V             # Paste
```

## Common Use Cases

### 1. Full-Stack Development

```bash
tmux new -s fullstack

# Window 1: Frontend
Prefix + c
Prefix + , → "frontend"
# Pane 1: nvim src/
# Pane 2: npm run dev (Prefix + ")

# Window 2: Backend
Prefix + c
Prefix + , → "backend"
# Pane 1: nvim api/
# Pane 2: node server.js

# Window 3: Database
Prefix + c
Prefix + , → "db"
# mongosh / psql

# Window 4: Git
Prefix + c
Prefix + , → "git"
```

### 2. System Monitoring

```bash
tmux new -s monitor

# Pane layout
Prefix + "                       # Split horizontal
Prefix + %                       # Split vertical
Prefix + %                       # Split vertical again

# Result: 4 panes
# [htop    | docker stats]
# [tail -f | git status   ]
```

### 3. Pair Programming

```bash
# Start shared session
tmux new -s pair

# Share session (same network)
# Partner connects:
tmux attach -t pair

# Both see same screen, can control simultaneously!
```

## Performance Tips

```bash
# Your config already has:
set -g history-limit 20000       # Good balance

# If tmux feels slow:
set -g status-interval 5         # Update status less frequently (you have 2)
set -g escape-time 0             # Faster command sequences

# Check tmux-sensible plugin - it handles many optimizations
```

## Troubleshooting

```bash
# Config not loading?
tmux source-file ~/.tmux.conf    # Manual reload
Prefix + r                       # Your custom reload

# Plugin not working?
Prefix + I                       # Install plugins (TPM)
Prefix + U                       # Update plugins

# Clear pane history
Prefix + :
clear-history

# Kill stuck session
tmux kill-session -t stuck

# Reset tmux completely
tmux kill-server
rm -rf ~/.tmux/resurrect/*       # Clear saved sessions
tmux
```

## Pro Tips

### 1. Session Naming Convention

```bash
# Use descriptive names
tmux new -s project-feature-123   # Work
tmux new -s dotfiles-cleanup      # Personal
tmux new -s api-performance       # Specific task
```

### 2. Window Naming

```bash
# Always name windows for quick navigation
Prefix + ,                        # Rename current window
# Prefix + w shows named list - easier to find
```

### 3. Zoom for Focus

```bash
Prefix + z                        # Zoom current pane (fullscreen)
# Work in fullscreen
Prefix + z                        # Zoom out to see all panes
```

### 4. Command Mode

```bash
Prefix + :                        # Enter command mode
# Now you can type any tmux command:
resize-pane -D 10                 # Resize down 10 lines
swap-pane -U                      # Swap with pane above
```

### 5. Mouse Mode (you have this!)

```bash
# Click to select pane (no Prefix needed)
# Click + drag border to resize
# Scroll wheel to scroll history
# Click + drag to select text (auto-copy with tmux-yank)
```

## Recommended Daily Workflow

```bash
# Morning
tmux attach || tmux new -s main

# Create project windows
Prefix + c                        # Code window
Prefix + c                        # Server window
Prefix + c                        # Git window

# Work in isolated spaces
Prefix + 0/1/2                    # Jump between tasks

# Need to leave?
Prefix + d                        # Detach (everything keeps running)

# Return
tmux attach                       # Back to work!

# End of day
# Just close terminal - tmux-resurrect saves everything!
# Next morning: tmux attach - exactly where you left off
```

## Cheatsheet Summary

```bash
# SESSIONS
tmux new -s name                  # Create
tmux ls                           # List
tmux attach -t name               # Attach
tmux kill-session -t name         # Kill
Prefix + s                        # Switch (interactive)
Prefix + d                        # Detach

# WINDOWS
Prefix + c                        # Create
Prefix + ,                        # Rename
Prefix + w                        # List
Prefix + n/p                      # Next/Previous
Prefix + [0-9]                    # Jump to number

# PANES
Prefix + %                        # Split vertical
Prefix + "                        # Split horizontal
Prefix + h/j/k/l                  # Navigate (your config)
Prefix + z                        # Zoom/unzoom
Prefix + x                        # Kill
Prefix + Space                    # Cycle layouts

# COPY MODE
Prefix + [                        # Enter
h/j/k/l                          # Navigate
Space                            # Start selection
Enter/y                          # Copy
Prefix + ]                        # Paste

# YOUR CUSTOM
Prefix + r                        # Reload config
Prefix + n                        # Quick note
Prefix + E                        # Quick note (split)
```

## Next Steps

1. **Practice session management**: Create/attach/detach sessions daily
2. **Build muscle memory**: Use Prefix + h/j/k/l for pane navigation
3. **Create project scripts**: Like the tmux-dev.sh example above
4. **Use tmux-resurrect**: Close terminal freely, tmux saves everything
5. **Explore plugins**: You have vim-tmux-navigator - seamless vim + tmux navigation

## Resources

- Your config: `~/dotfiles/tmux/.tmux.conf`
- Plugin manager: TPM (already installed)
- Reload config: `Prefix + r`
- This guide: `~/dotfiles/docs/tmux-best-practices-guide.md`

## Common Mistakes to Avoid

❌ Creating too many panes (>4 gets cluttered)
✅ Use windows for major tasks, panes for related views

❌ Not naming sessions/windows
✅ Always name for quick navigation

❌ Forgetting to detach (closing terminal kills tmux)
✅ Use `Prefix + d` to detach safely

❌ Working in one big session
✅ Separate projects into different sessions

❌ Not using copy mode effectively
✅ Practice `Prefix + [`, navigate, select, copy

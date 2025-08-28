# 🔧 tmux + zsh + nvim Troubleshooting Matrix

## Quick Reference Matrix

| Issue Category | Symptoms | Platform | Quick Fix | Detailed Section |
|----------------|----------|----------|-----------|------------------|
| **Navigation** | `C-h/j/k/l` not working | All | Check plugin loading | [Navigation Issues](#navigation-issues) |
| **Clipboard** | Copy/paste broken | macOS | Install Xcode tools | [Clipboard Issues](#clipboard-issues) |
| **Clipboard** | Copy/paste broken | Linux X11 | `sudo apt install xclip` | [Clipboard Issues](#clipboard-issues) |
| **Clipboard** | Copy/paste broken | Linux Wayland | `sudo apt install wl-clipboard` | [Clipboard Issues](#clipboard-issues) |
| **Colors** | Theme inconsistent | All | Set `COLORTERM=truecolor` | [Theme Issues](#theme-issues) |
| **Performance** | Slow pane switching | All | Optimize shell startup | [Performance Issues](#performance-issues) |
| **Sessions** | Restore fails | All | Check permissions | [Session Issues](#session-issues) |
| **SSH** | Agent broken after restore | All | Restart SSH agent | [SSH/GPG Issues](#sshgpg-issues) |

---

## Cross-Platform Compatibility Matrix

### Platform Differences

| Component | macOS | Linux (X11) | Linux (Wayland) | Notes |
|-----------|-------|-------------|-----------------|-------|
| **Clipboard** | `pbcopy/pbpaste` | `xclip/xsel` | `wl-copy/wl-paste` | Built-in vs packages |
| **Homebrew Path** | `/opt/homebrew/bin` | `/home/linuxbrew/.linuxbrew/bin` | Same as X11 | Apple Silicon vs Intel |
| **Terminal** | iTerm2/Terminal | GNOME Terminal/Konsole | Same as X11 | Built-in vs package |
| **Fonts** | Included | Manual install | Manual install | Nerd Fonts required |
| **SSH Agent** | Keychain | Manual/systemd | Manual/systemd | Auto-start differences |

### Required Packages by Platform

#### macOS (Homebrew)
```bash
brew install tmux neovim zsh
brew install --cask wezterm  # optional terminal
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install tmux neovim zsh

# For X11
sudo apt install xclip

# For Wayland
sudo apt install wl-clipboard

# Optional: WezTerm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm
```

#### Arch Linux
```bash
sudo pacman -S tmux neovim zsh

# Clipboard utilities
sudo pacman -S xclip         # For X11
sudo pacman -S wl-clipboard  # For Wayland

# Optional: WezTerm
sudo pacman -S wezterm
```

#### Fedora/RHEL
```bash
sudo dnf install tmux neovim zsh

# Clipboard utilities
sudo dnf install xclip         # For X11
sudo dnf install wl-clipboard  # For Wayland
```

---

## Detailed Troubleshooting Guide

### Navigation Issues

#### Problem: vim-tmux-navigator not switching panes

**Symptoms:**
- `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` don't work between tmux/nvim
- Only works in one direction
- Works in tmux but not nvim (or vice versa)

**Diagnostic Commands:**
```bash
# Check if navigator plugin is loaded in nvim
nvim -c ':lua print(vim.g.loaded_tmux_navigator)' -c ':q'

# Check tmux key bindings
tmux list-keys | grep -E "C-(h|j|k|l)"

# Test pane current command detection
tmux display-message -p '#{pane_current_command}'

# Check for conflicting nvim keymaps
nvim -c ':nmap <C-h>' -c ':q'
```

**Platform-Specific Solutions:**

**macOS:**
```bash
# Ensure vim-tmux-navigator is properly installed
# In nvim config, check plugin manager (lazy.nvim)
```

**Linux:**
```bash
# May need to compile nvim with clipboard support
nvim --version | grep clipboard
# Should show +clipboard, not -clipboard
```

**Universal Solutions:**
```bash
# 1. Use optimized tmux detection (faster than ps-based)
# Add to .tmux.conf:
bind -n C-h if -F '#{==:#{pane_current_command},nvim}' 'send-keys C-h' 'select-pane -L'
bind -n C-j if -F '#{==:#{pane_current_command},nvim}' 'send-keys C-j' 'select-pane -D'
bind -n C-k if -F '#{==:#{pane_current_command},nvim}' 'send-keys C-k' 'select-pane -U'
bind -n C-l if -F '#{==:#{pane_current_command},nvim}' 'send-keys C-l' 'select-pane -R'

# 2. Disable default mappings in nvim to avoid conflicts
# In nvim config:
vim.g.tmux_navigator_no_mappings = 1

# Then add explicit mappings:
vim.keymap.set('n', '<C-h>', '<Cmd>TmuxNavigateLeft<CR>')
vim.keymap.set('n', '<C-j>', '<Cmd>TmuxNavigateDown<CR>')
vim.keymap.set('n', '<C-k>', '<Cmd>TmuxNavigateUp<CR>')
vim.keymap.set('n', '<C-l>', '<Cmd>TmuxNavigateRight<CR>')
```

### Clipboard Issues

#### Problem: Copy/paste not working between applications

**Symptoms:**
- Copying in tmux doesn't reach system clipboard
- NeoVim yanked text not available system-wide
- System clipboard not accessible in tmux/nvim

**Platform-Specific Diagnostics:**

**macOS:**
```bash
# Test system clipboard
echo "test" | pbcopy
pbpaste  # Should output "test"

# Check if Xcode command line tools installed
xcode-select --install 2>/dev/null || echo "Already installed"
```

**Linux X11:**
```bash
# Test available clipboard utilities
command -v xclip && echo "xclip available"
command -v xsel && echo "xsel available"

# Test clipboard functionality
echo "test" | xclip -selection clipboard
xclip -selection clipboard -o  # Should output "test"

# Check X11 session
echo $DISPLAY  # Should show something like :0
```

**Linux Wayland:**
```bash
# Test Wayland clipboard
command -v wl-copy && echo "wl-clipboard available"

# Test functionality
echo "test" | wl-copy
wl-paste  # Should output "test"

# Check Wayland session
echo $WAYLAND_DISPLAY  # Should show wayland-0 or similar
```

**Solutions by Platform:**

**macOS:**
```bash
# Usually works out of box, but if issues:
# 1. Install/reinstall Xcode command line tools
sudo xcode-select --install

# 2. Check tmux-yank configuration in .tmux.conf
set -g @yank_selection_mouse 'clipboard'
set -g @yank_with_mouse on
```

**Linux X11:**
```bash
# 1. Install clipboard utilities
sudo apt install xclip  # Ubuntu/Debian
sudo dnf install xclip  # Fedora
sudo pacman -S xclip    # Arch

# 2. Configure aliases for consistency
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# 3. Set tmux to use xclip
# In .tmux.conf:
set -g @yank_selection 'clipboard'
```

**Linux Wayland:**
```bash
# 1. Install wl-clipboard
sudo apt install wl-clipboard  # Ubuntu/Debian
sudo dnf install wl-clipboard  # Fedora
sudo pacman -S wl-clipboard    # Arch

# 2. Configure aliases
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

# 3. Configure tmux for Wayland
# In .tmux.conf:
if-shell 'test -n "$WAYLAND_DISPLAY"' 'set -s copy-command "wl-copy"'
```

**NeoVim Clipboard Configuration:**
```lua
-- Universal clipboard configuration
-- In nvim lua config:

if vim.fn.has('macunix') == 1 then
    -- macOS
    vim.opt.clipboard = 'unnamed'
elseif vim.fn.has('unix') == 1 then
    -- Linux
    if os.getenv('WAYLAND_DISPLAY') then
        -- Wayland
        vim.g.clipboard = {
            name = 'wl-clipboard',
            copy = {
                ['+'] = 'wl-copy',
                ['*'] = 'wl-copy --primary',
            },
            paste = {
                ['+'] = 'wl-paste --no-newline',
                ['*'] = 'wl-paste --no-newline --primary',
            },
        }
    else
        -- X11
        vim.opt.clipboard = 'unnamedplus'
    end
end
```

### Theme Issues

#### Problem: Inconsistent colors between terminal, tmux, and nvim

**Symptoms:**
- Different color schemes in each application
- Syntax highlighting broken or wrong colors
- Status bars don't match terminal theme

**Platform-Specific Considerations:**

**macOS:**
```bash
# iTerm2: Enable true color in preferences
# Terminal.app: Limited color support, use iTerm2 or WezTerm

# Check color support
echo $TERM      # Should be xterm-256color or tmux-256color
echo $COLORTERM # Should be truecolor
```

**Linux:**
```bash
# Most modern terminals support true color
# Check your terminal documentation

# GNOME Terminal: True color enabled by default
# Konsole: Enable in settings
# Alacritty: True color by default
```

**Universal Solutions:**
```bash
# 1. Set environment variables
export TERM=xterm-256color
export COLORTERM=truecolor

# 2. Configure tmux for proper color handling
# In .tmux.conf:
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

# For specific terminals:
set -ga terminal-overrides ",alacritty:Tc"
set -ga terminal-overrides ",*xterm*:Tc"

# 3. Test color support
# Run this to test 256 colors:
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# 4. Synchronize themes
# Use consistent color schemes:
# - Terminal: Set to support chosen theme
# - tmux: Configure status bar colors
# - nvim: Use matching colorscheme
```

**Theme Debugging:**
```bash
# Check what tmux sees
tmux info | grep 'RGB\|Tc'

# Test nvim colors
nvim -c ':highlight' -c ':q'  # Shows all highlight groups

# Test terminal color capability
printf '\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n'
# Should display "TRUECOLOR" in orange
```

### Performance Issues

#### Problem: Slow navigation or terminal response

**Symptoms:**
- Delay when switching panes
- Slow tmux/nvim startup
- High CPU usage
- Laggy typing in terminal

**Diagnostic Commands:**
```bash
# Time shell startup
time zsh -i -c exit

# Time tmux startup
time tmux new-session -d -s test \; kill-session -t test

# Time nvim startup
nvim --startuptime /tmp/nvim-startup.log +q
cat /tmp/nvim-startup.log | sort -k2 -n | tail -10

# Check tmux performance
tmux list-sessions -F '#{session_name}: #{session_windows} windows'

# Monitor system resources
top -p $(pgrep -d, -f "tmux\|nvim\|zsh")
```

**Platform-Specific Performance Issues:**

**macOS:**
```bash
# Check if using Apple Silicon optimized builds
file $(which tmux)   # Should show arm64 for M1/M2
file $(which nvim)   # Should show arm64 for M1/M2

# If using Rosetta 2 (Intel) builds, reinstall with:
arch -arm64 brew reinstall tmux neovim
```

**Linux:**
```bash
# Check if packages are from repositories vs compiled
which tmux nvim

# For better performance, consider building from source:
# tmux: https://github.com/tmux/tmux
# neovim: https://github.com/neovim/neovim
```

**Universal Performance Optimizations:**

**Shell Optimization:**
```bash
# Profile shell startup
zsh -o sourcetrace -i -c exit 2>&1 | grep -E '^\+\+\+' | head -20

# Optimize .zshrc:
# 1. Use lazy loading for heavy tools
lazy_load_nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
alias nvm='lazy_load_nvm; nvm'

# 2. Cache expensive operations
if [[ ! -f ~/.zcompdump ]] || [[ ~/.zshrc -nt ~/.zcompdump ]]; then
    autoload -Uz compinit
    compinit
else
    autoload -Uz compinit
    compinit -C
fi
```

**tmux Optimization:**
```bash
# In .tmux.conf:
set -g escape-time 0           # Remove delay for escape sequences
set -g display-time 2000       # Message display time
set -g status-interval 5       # Status update interval (default 15)
set -g history-limit 5000      # Reduce if using lots of memory

# Use efficient navigator detection
bind -n C-h if -F '#{==:#{pane_current_command},nvim}' 'send-keys C-h' 'select-pane -L'
# (Faster than ps-based detection)
```

**NeoVim Optimization:**
```lua
-- In nvim config:
vim.opt.updatetime = 300       -- Faster completion
vim.opt.timeoutlen = 500       -- Faster key sequences
vim.opt.lazyredraw = true      -- Don't redraw during macros

-- Use performance guards for large files
require('custom.perf-guards')

-- Lazy load heavy plugins
vim.defer_fn(function()
    require('custom.heavy-plugin-config')
end, 100)
```

### Session Issues

#### Problem: tmux session restore fails or corrupts

**Symptoms:**
- `<prefix> + Ctrl-r` doesn't restore sessions
- Restored sessions have wrong content
- Session files are corrupted

**Diagnostic Commands:**
```bash
# Check resurrect plugin status
tmux show-options -g | grep resurrect

# Check session save directory
ls -la ~/.local/share/tmux/resurrect/

# Check permissions
ls -la ~/.local/share/tmux/

# Check continuum status
tmux show-options -g | grep continuum

# Manual save/restore test
tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
```

**Platform-Specific Issues:**

**macOS:**
```bash
# Check file system permissions
ls -la ~/.local/share/tmux/resurrect/
# Should be writable by user

# If using iCloud sync, disable for tmux directories:
# System Preferences > Apple ID > iCloud > iCloud Drive > Options
# Exclude .local directory
```

**Linux:**
```bash
# Check SELinux (if enabled)
getenforce  # Should be Permissive or Disabled for testing

# Check disk space
df -h ~/.local/share/tmux/

# Check systemd conflicts (if tmux started as service)
systemctl --user status tmux.service 2>/dev/null || echo "No systemd service"
```

**Universal Solutions:**
```bash
# 1. Reset resurrect configuration
rm -rf ~/.local/share/tmux/resurrect/
mkdir -p ~/.local/share/tmux/resurrect/

# 2. Configure safe resurrection in .tmux.conf
set -g @resurrect-capture-pane-contents 'off'  # Avoid large dumps
set -g @resurrect-save-shell-history 'off'     # Privacy
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'           # Save every 15 minutes

# 3. Exclude sensitive processes
set -g @resurrect-processes-to-ignore 'ssh gpg-agent ssh-agent'

# 4. Test manually
# Save:
tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
# Kill session:
tmux kill-server
# Start tmux and restore:
tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
```

### SSH/GPG Issues

#### Problem: SSH/GPG agents not working after session restore

**Symptoms:**
- SSH key authentication fails after tmux restore
- GPG signing/encryption fails
- Agent socket paths are stale

**Platform-Specific Configurations:**

**macOS:**
```bash
# Use macOS Keychain for SSH
# In ~/.ssh/config:
Host *
    UseKeychain yes
    AddKeysToAgent yes

# For GPG, ensure pinentry-mac is installed
brew install pinentry-mac

# In ~/.gnupg/gpg-agent.conf:
pinentry-program /opt/homebrew/bin/pinentry-mac
```

**Linux:**
```bash
# For SSH, use systemd user service
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service

# For GPG
systemctl --user enable gpg-agent.service
systemctl --user start gpg-agent.service

# Or add to shell startup:
if ! pgrep -x ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi
```

**Universal Solutions:**
```bash
# 1. Create post-restore hook
# Create ~/.local/bin/tmux-post-restore:
#!/bin/bash
echo "Restarting authentication agents..."

# Restart SSH agent
if [ -n "$SSH_AGENT_PID" ]; then
    kill $SSH_AGENT_PID
fi
eval "$(ssh-agent -s)"

# Add keys back
if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add ~/.ssh/id_ed25519
fi
if [ -f ~/.ssh/id_rsa ]; then
    ssh-add ~/.ssh/id_rsa
fi

# Restart GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

chmod +x ~/.local/bin/tmux-post-restore

# 2. Configure tmux-resurrect to exclude agent sockets
# In .tmux.conf:
set -g @resurrect-save-bash-history 'off'
set -g @resurrect-capture-pane-contents 'off'

# 3. Add hook to shell startup
# In .zshrc:
if [ -n "$TMUX" ] && [ -f ~/.tmux-restored ]; then
    ~/.local/bin/tmux-post-restore
    rm ~/.tmux-restored
fi

# 4. Test agent restart
~/.local/bin/tmux-post-restore
ssh-add -l  # Should list keys
gpg --list-secret-keys  # Should work without error
```

---

## Quick Fix Commands

### Emergency Recovery
```bash
# Reset all tmux sessions
tmux kill-server

# Clear nvim cache
rm -rf ~/.local/share/nvim/
rm -rf ~/.cache/nvim/

# Reset shell
exec zsh

# Restart all services
pkill -f "tmux\|nvim"
exec zsh
```

### Diagnostic One-Liners
```bash
# Check integration status
echo "TERM: $TERM, COLORTERM: $COLORTERM, TMUX: ${TMUX:+active}"

# Test clipboard
echo "test" | pbcopy 2>/dev/null || echo "test" | xclip -selection clipboard 2>/dev/null || echo "test" | wl-copy 2>/dev/null
echo "Clipboard test: $(pbpaste 2>/dev/null || xclip -selection clipboard -o 2>/dev/null || wl-paste 2>/dev/null)"

# Check performance
time (zsh -i -c exit && tmux new-session -d -s perftest \; kill-session -t perftest)
```

---

## Platform-Specific Gotchas

### macOS Specific
- **Homebrew paths**: Different for Intel vs Apple Silicon
- **pbcopy**: Requires Xcode command line tools
- **iTerm2**: Has better integration than Terminal.app
- **Keychain**: SSH keys stored in Keychain need special config

### Linux X11 Specific
- **Clipboard**: Requires `xclip` or `xsel` packages
- **Display**: Needs `$DISPLAY` environment variable
- **Fonts**: May need manual Nerd Font installation
- **Terminal**: Varies significantly between desktop environments

### Linux Wayland Specific
- **Clipboard**: Requires `wl-clipboard` package
- **Display**: Uses `$WAYLAND_DISPLAY` instead of `$DISPLAY`
- **Terminal**: Newer terminals have better Wayland support
- **X11 compatibility**: Some tools may need XWayland

### Universal
- **Terminal emulator**: Feature support varies significantly
- **Shell startup**: Order of rc files differs between login/non-login shells
- **tmux versions**: Plugin compatibility depends on version
- **NeoVim builds**: Compile flags affect clipboard and other features

This troubleshooting matrix should help quickly identify and resolve common integration issues across different platforms and configurations.
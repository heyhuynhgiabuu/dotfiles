# Brewfile Modernization Verification

## Recent Updates

### Core Tools Enhanced (Brewfile)
- **universal-ctags** ← replaces ctags (modern language support)
- **broot** ← interactive tree browser with previews  
- **dust** ← fast disk usage analyzer (modern du replacement)
- **starship** ← cross-shell prompt with git integration

### Development Tools Added (Brewfile.dev)
- **nushell** ← structured shell for data workflows (optional)
- **tree** ← kept for script/CI compatibility

## Cross-Platform Verification

### macOS (Intel/ARM)
```bash
# Verify installations
brew info universal-ctags git-delta broot dust starship nushell
brew list | grep -E "(universal-ctags|git-delta|broot|dust|starship|nushell)"

# Test functionality
universal-ctags --version
delta --version  
broot --version
dust --version
starship --version
nu --version  # nushell
```

### Linux (Homebrew on Linux)
```bash
# Same commands as macOS - Homebrew provides consistent experience
/home/linuxbrew/.linuxbrew/bin/brew info universal-ctags
```

### Ubuntu/Debian Alternative (if not using Homebrew)
```bash
# universal-ctags
sudo apt install universal-ctags
# starship  
curl -sS https://starship.rs/install.sh | sh
# dust (from GitHub releases)
wget https://github.com/bootandy/dust/releases/latest/download/dust-v0.x.x-x86_64-unknown-linux-gnu.tar.gz
```

## Functionality Tests

### 1. universal-ctags Integration
```bash
# Generate tags for a code project
cd ~/your-project
universal-ctags -R .
head tags

# Verify neovim integration
nvim some-file.py
# Press Ctrl+] on a function name - should jump to definition
```

### 2. delta Git Integration  
```bash
# Configure git to use delta
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false

# Test colored diff
git log -p --color=always | head -50
```

### 3. broot Interactive Navigation
```bash
# Launch interactive tree browser
broot

# In broot:
# - Use arrow keys to navigate
# - Press Enter to preview files  
# - Type to filter/search
# - Press ? for help
```

### 4. dust Disk Usage
```bash
# Compare with traditional du
time du -sh ~/Downloads
time dust ~/Downloads

# dust should be faster and show better visualization
```

### 5. starship Prompt
```bash
# Add to shell config (.zshrc/.bashrc)
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
# or for bash: echo 'eval "$(starship init bash)"' >> ~/.bashrc

# Restart shell - should see enhanced prompt with git status
cd /path/to/git/repo
# Prompt should show: git branch, status icons, etc.
```

### 6. nushell Structured Data (Optional)
```bash
# Start nushell
nu

# Test structured data commands
ls | where size > 1MB
sys | get host
```

## Editor Integration Updates

### Neovim + universal-ctags
```lua
-- In ~/.config/nvim/init.lua or init.vim
-- Ensure tagbar plugin works with universal-ctags
vim.g.tagbar_ctags_bin = '/opt/homebrew/bin/universal-ctags'  -- adjust path
```

### Git + delta Configuration
```bash
# Full delta configuration
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
```

## Security Verification

### Package Authenticity
```bash
# Verify Homebrew bottles are signed
brew info --json universal-ctags | jq '.[] | .bottle'
brew info --json broot | jq '.[] | .bottle'
```

### starship Configuration Security
```bash
# Check default starship config doesn't execute network calls
starship config get
# Review ~/.config/starship.toml for unsafe commands
```

## Troubleshooting

### universal-ctags Binary Path
```bash
# If editors can't find ctags
which universal-ctags  
which ctags
# May need to symlink or update PATH:
# ln -s /opt/homebrew/bin/universal-ctags /usr/local/bin/ctags
```

### delta Not Working
```bash
# Check git config
git config --list | grep delta
# Reset if needed:
git config --global --unset core.pager
```

### Missing Bottles (Linux)
```bash
# If package builds from source, ensure build dependencies
sudo apt install build-essential cmake pkg-config
# For Homebrew on Linux
/home/linuxbrew/.linuxbrew/bin/brew doctor
```

## Performance Benchmarks

### Expected Improvements
- **dust vs du**: 3-5x faster on large directories
- **broot vs tree + cd**: Interactive navigation saves 2-3 commands
- **universal-ctags vs ctags**: Better language coverage (TypeScript, modern JS, etc.)
- **starship**: Minimal shell startup impact (<50ms)

### Verification Commands
```bash
# Benchmark disk usage tools
time dust ~/
time du -sh ~/

# Test ctags language support 
universal-ctags --list-languages | grep -i typescript
universal-ctags --list-languages | wc -l  # Should be 150+ languages
```

## Rollback Plan

If issues occur:
```bash
# Remove modern tools
brew uninstall universal-ctags broot dust starship nushell

# Restore original tools
brew install ctags

# Reset git config
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
git config --global --unset delta.navigate
```
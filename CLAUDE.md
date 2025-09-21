# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Cross-platform dotfiles repository for macOS and Linux development environments. Built around a "Hybrid AI" workflow combining Neovim (NvChad), OpenCode terminal-based AI agents, GitHub Copilot, AugmentCode, WezTerm/Tmux, and enhanced Zsh.

## Development Commands

### Initial Setup
```bash
# Bootstrap entire environment (recommended)
./scripts/bootstrap.sh

# Or minimal setup with stow only
./scripts/setup.sh
```

### Homebrew Package Management
```bash
# Install layered packages (in order)
brew bundle --file=homebrew/Brewfile.min    # Core tools
brew bundle --file=homebrew/Brewfile.dev    # Development stack
brew bundle --file=homebrew/Brewfile.extra  # Optional extras
brew bundle --file=homebrew/Brewfile.gui    # GUI applications

# Or use helper script
./scripts/brew-apply-layer.sh --dry-run min dev gui
./scripts/brew-apply-layer.sh min dev gui

# Regenerate snapshot after changes
./scripts/brew-dump-snapshot.sh
```

### Development Workflows
```bash
# Java development session
./scripts/tmux-java-layout.sh

# Go development session
./scripts/tmux-go-layout.sh

# Review automation (CI/analysis)
./scripts/ci/review-scope.sh --base main
```

### Verification & Maintenance
```bash
# Verify environment
./scripts/bootstrap.sh verify

# Update configurations
./scripts/bootstrap.sh update

# Rollback changes
./scripts/bootstrap.sh rollback
```

## Architecture

### Configuration Management
- **GNU Stow**: Symlink management for configurations
- **Layered Brewfiles**: Progressive package installation (min → dev → extra → gui)
- **Cross-platform compatibility**: Bash 3.2+ scripts, macOS/Linux tested

### Directory Structure
```
nvim/           # Neovim configuration (NvChad-based)
tmux/           # Tmux configuration with custom layouts
zsh/            # Enhanced Zsh with aliases, functions, completions
wezterm/        # Modern terminal emulator settings
aerospace/      # AeroSpace window manager (macOS)
opencode/       # OpenCode AI agent configurations and prompts
scripts/        # Setup, verification, and utility scripts
homebrew/       # Layered Brewfiles for package management
```

### AI Integration
- **OpenCode**: Terminal-based AI with specialized agents (security, devops, reviewer)
- **Base Prompt**: Shared across all OpenCode agents in `opencode/base-prompt.md`
- **Agent Guidelines**: Plugin development standards in `AGENTS.md`
- **Configuration**: `opencode/opencode.jsonc` with MCP integrations (Serena, Context7, etc.)

## Key Files

### Essential Configurations
- `zsh/.zshrc` → `~/.zshrc` (Enhanced shell with completions)
- `tmux/.tmux.conf` → `~/.tmux.conf` (Session management with TPM)
- `nvim/.config/nvim/` → `~/.config/nvim/` (NvChad-based editor)
- `wezterm/.config/wezterm/` → `~/.config/wezterm/` (Terminal configuration)

### Development Scripts
- `scripts/bootstrap.sh` - Unified setup pipeline with rollback
- `scripts/setup.sh` - Basic stow configuration setup
- `scripts/common.sh` - Shared utilities and platform detection
- `scripts/verify.sh` - Environment validation

### AI Configuration
- `opencode/base-prompt.md` - Core OpenCode system prompt
- `opencode/opencode.jsonc` - OpenCode configuration with agents/tools
- `AGENTS.md` - Plugin development standards and guidelines

## Development Guidelines

### Code Standards
- **NO AUTO-COMMENTS**: Never add auto-generated comments
- **SELF-DOCUMENTING CODE**: Clear naming over documentation
- **KISS PRINCIPLE**: Brutal simplicity over complexity
- **Cross-platform**: Test on both macOS and Linux
- **POSIX shell**: Scripts must work with Bash 3.2+

### Stow Configuration Patterns
- Each tool has its own directory (nvim/, tmux/, zsh/, etc.)
- Directory structure mirrors target filesystem
- Use `stow -R` to restow configurations when conflicts occur

### Homebrew Layer Management
- Apply layers progressively: min → dev → extra → gui
- Test layer combinations with `--dry-run` flag
- Regenerate snapshot after significant changes
- Use `FFMPEG_CONFLICTS` env var for conflict handling

### OpenCode Plugin Development
- Place plugins in `opencode/plugin/` directory
- Export async function with `{ project, client, directory }` params
- Use built-in Node.js APIs, avoid external dependencies
- Implement LRU caching (max 50 items, 30s TTL)
- Apply rate limiting and graceful error handling

## Security Notes

- Never commit secrets or API keys
- Use path validation in OpenCode plugins
- Scripts include root safety checks
- OpenCode permissions are restrictive by default

## Troubleshooting

### Neovim Treesitter Issues
```bash
# Automated fix
./scripts/verify/fix-treesitter.sh

# Manual cleanup
rm -rf ~/.local/share/nvim/treesitter
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/queries/vimdoc/highlights.scm
nvim -c 'TSUpdate' -c 'quit'
```

### Homebrew Conflicts
```bash
# Use helper script for diagnosis
./scripts/dev/ffmpeg-helper.sh --diagnose --brew-fix

# Manual cleanup
brew doctor
brew cleanup -s
brew autoremove
```

### Stow Conflicts
```bash
# Restow with conflict resolution
stow -D <config> && stow <config>

# Or use restow flag
stow -R <config>
```
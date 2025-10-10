# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Cross-platform dotfiles repository for macOS and Linux development environments. Built around a "Hybrid AI" workflow combining Neovim (NvChad), OpenCode terminal-based AI agents, GitHub Copilot, AugmentCode, WezTerm/Tmux, and enhanced Zsh.

## Development Commands

### Initial Setup
```bash
# Bootstrap entire environment (recommended)
./scripts/bootstrap.sh

# Or specific operations
./scripts/bootstrap.sh init      # Initial setup
./scripts/bootstrap.sh verify    # Verify environment
./scripts/bootstrap.sh update    # Update configurations
./scripts/bootstrap.sh rollback  # Rollback changes

# Basic stow-only setup
./scripts/setup.sh
```

### Homebrew Package Management
```bash
# Install layered packages (in order)
brew bundle --file=homebrew/Brewfile.min    # Core tools
brew bundle --file=homebrew/Brewfile.dev    # Development stack
brew bundle --file=homebrew/Brewfile.extra  # Optional extras
brew bundle --file=homebrew/Brewfile.gui    # GUI applications

# Or use helper script with dry-run
./scripts/setup/brew-apply-layer.sh --dry-run min dev gui
./scripts/setup/brew-apply-layer.sh min dev gui

# Regenerate snapshot after changes
./scripts/setup/brew-dump-snapshot.sh
./scripts/setup/brew-dump-snapshot.sh --force  # Override uncommitted check
```

### Development Workflows
```bash
# Java development session (5-panel UI, F-key hotkeys)
./scripts/tmux/tmux-java-layout.sh

# Go development session
./scripts/tmux/tmux-go-layout.sh

# Review automation (CI/analysis)
./scripts/ci/review-scope.sh --base main
./scripts/ci/review-scope.sh --base main --no-md  # JSON only
```

### Verification & Troubleshooting
```bash
# Verify Homebrew layers
./scripts/verify/verify-brew-layers.sh --layers "min dev gui" --show-overlaps

# Fix Neovim Treesitter issues
./scripts/verify/fix-treesitter.sh

# ffmpeg diagnostics and installation
./scripts/dev/ffmpeg-helper.sh --diagnose
./scripts/dev/ffmpeg-helper.sh --auto-install
./scripts/dev/ffmpeg-helper.sh --auto-install --force-conflicts
```

## Architecture

### Configuration Management
- **GNU Stow**: Symlink management for configurations
- **Layered Brewfiles**: Progressive package installation (min → dev → extra → gui)
- **Bootstrap Pipeline**: Unified setup with rollback capability (`bootstrap.sh`)
- **Cross-platform compatibility**: Bash 3.2+ scripts, macOS/Linux tested

### Directory Structure
```
nvim/           # Neovim configuration (NvChad-based, Lua)
tmux/           # Tmux configuration with custom layouts
zsh/            # Enhanced Zsh with aliases, functions, completions
wezterm/        # Modern terminal emulator settings
aerospace/      # AeroSpace window manager (macOS)
claude/         # Claude Code settings (MCP servers, permissions)
opencode/       # OpenCode AI agent configurations and prompts
scripts/        # Setup, verification, and utility scripts
homebrew/       # Layered Brewfiles for package management
docs/           # Documentation and guides
```

### AI Integration
- **OpenCode**: Terminal-based AI with specialized agents (security, devops, reviewer)
- **Claude Code**: MCP servers (Context7, Sequential Thinking)
- **Base Prompt**: Shared across all OpenCode agents in `opencode/base-prompt.md`
- **Agent Guidelines**: Plugin development standards in `opencode/AGENTS.md`
- **Configuration**: `opencode/opencode.json` with MCP integrations

### Review Automation Suite
Cross-platform (Bash 3.2+) review automation for risk classification, test coverage deltas, and legacy hotspot detection:

```bash
./scripts/ci/review-scope.sh --base main        # Generate artifacts
./scripts/ci/review-scope.sh --base main --no-md # JSON only
```

**Generated artifacts** (in `review_artifacts/`, git-ignored):
- `manifest.json/md` - Diff manifest
- `risk.json/md` - Risk classification tags
- `coverage.json/md` - Test coverage delta
- `hotspots.json/md` - Legacy/refactor hotspots
- `all.json` - Combined schema (requires jq)
- `index.md` - Consolidated report

**Risk tags**: `large_change`, `missing_test_delta`, `performance`, `security`, `high_churn`, `high_concentration`

**CI Integration**: GitHub Actions workflow (`.github/workflows/review-scope.yml`) runs on PRs, uploads artifacts, fails on gating risks (security/large_change/missing_test_delta/hotspot).

## Key Files

### Essential Configurations
- `zsh/.zshrc` → `~/.zshrc` (Enhanced shell with completions)
- `tmux/.tmux.conf` → `~/.tmux.conf` (Session management with TPM)
- `nvim/.config/nvim/` → `~/.config/nvim/` (NvChad-based editor)
- `wezterm/.config/wezterm/` → `~/.config/wezterm/` (Terminal configuration)
- `claude/.claude/settings.json` → `~/.claude/settings.json` (Claude Code settings)
- `claude/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md` (This file for OpenCode Protocol)

### Development Scripts
- `scripts/bootstrap.sh` - Unified setup pipeline with rollback
- `scripts/setup.sh` - Basic stow configuration setup
- `scripts/common.sh` - Shared utilities and platform detection
- `scripts/setup/brew-apply-layer.sh` - Apply Homebrew layers with dry-run
- `scripts/setup/brew-dump-snapshot.sh` - Regenerate Brewfile snapshot
- `scripts/verify/verify-brew-layers.sh` - Validate layer installations
- `scripts/verify/fix-treesitter.sh` - Fix Neovim Treesitter issues
- `scripts/dev/ffmpeg-helper.sh` - ffmpeg detection, install, diagnostics

### AI Configuration
- `opencode/base-prompt.md` - Core OpenCode system prompt
- `opencode/opencode.json` - OpenCode configuration with agents/tools
- `opencode/AGENTS.md` - Plugin development standards and guidelines
- `claude/.claude/settings.json` - Claude Code MCP servers and permissions

## Development Guidelines

### Code Standards
- **NO AUTO-COMMENTS**: Never add auto-generated comments
- **SELF-DOCUMENTING CODE**: Clear naming over documentation
- **KISS PRINCIPLE**: Brutal simplicity over complexity
- **Cross-platform**: Test on both macOS and Linux
- **POSIX shell**: Scripts must work with Bash 3.2+
- **No Bash 4+ features**: No associative arrays, mapfile, or readarray

### Stow Configuration Patterns
- Each tool has its own directory (nvim/, tmux/, zsh/, etc.)
- Directory structure mirrors target filesystem
- Use `stow -R` to restow configurations when conflicts occur
- Use `stow --adopt` to adopt existing files and create symlinks

### Homebrew Layer Management
- Apply layers progressively: min → dev → extra → gui
- Test layer combinations with `--dry-run` flag
- Regenerate snapshot after significant changes
- Use `FFMPEG_CONFLICTS` env var for conflict handling
- Validate with `verify-brew-layers.sh --show-overlaps`

### OpenCode Plugin Development
- Place plugins in `opencode/plugin/` directory
- Export async function with `{ project, client, directory }` params
- Use built-in Node.js APIs, avoid external dependencies
- Implement LRU caching (max 50 items, 30s TTL)
- Apply rate limiting and graceful error handling

### Neovim Performance
- Large files (>200KB): Auto-disables Treesitter highlight/indent
- Extreme files (>1MB): Aggressive simplifications applied
- See `nvim/.config/nvim/lua/custom/perf-guards.lua`

### Agent Guidelines
- **Clean commits**: No "Generated with opencode" messages in this repo
- **Respect structure**: Follow existing directory organization
- **Match conventions**: Use Lua for Neovim, shell for scripts
- **Self-contained configs**: No external dependencies

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

# Fix dirty repos
(cd "$(brew --repo)" && git fetch origin && git reset --hard origin/HEAD)
```

### Stow Conflicts
```bash
# Restow with conflict resolution
stow -D <config> && stow <config>

# Or use restow flag
stow -R <config>

# Adopt existing files
stow --adopt <config>
```

### Bootstrap Rollback
```bash
# Rollback to previous state
./scripts/bootstrap.sh rollback
```

## Security Notes

- Never commit secrets or API keys
- Use path validation in OpenCode plugins
- Scripts include root safety checks
- OpenCode permissions are restrictive by default
- Claude Code denies .env and secrets/* by default

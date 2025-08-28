# Dotfiles Project Guidelines

This file provides essential, supplementary context for the `dotfiles` repository. These guidelines work in conjunction with the global rules found in `opencode/AGENTS.md`.

## Project Context
- **Project Type:** Personal configuration files (dotfiles). There are no build, lint, or automated test commands.
- **Primary Requirement:** All configurations MUST be cross-platform (macOS & Linux).
- **Commit Message Rule:** Do NOT include "Generated with opencode" or any AI attribution in commit messages.
- **Verification:** All changes require simple, manual verification steps to be provided to the user.
- **Dependencies:** Do not add new software dependencies without explicit permission.

## Development Commands
```bash
# No build/lint commands - this is a dotfiles repository
# Testing: Manual verification only
./scripts/verify.sh                     # Run all verification checks
./scripts/verify.sh --nvim-only         # Check only NvChad configuration

# Setup and maintenance
./scripts/setup.sh                      # Initial setup
./scripts/brew-apply-layer.sh min       # Apply minimal packages
./scripts/brew-apply-layer.sh dev       # Apply development packages
```

## Code Style Guidelines
- **Shell Scripts:** POSIX sh compatible, use `#!/usr/bin/env sh`
- **Cross-Platform:** Always test commands on both macOS and Linux
- **Error Handling:** Use `set -e` for exit on error
- **Colors:** Use standardized color definitions from `scripts/common.sh`
- **File Structure:** Source `scripts/common.sh` for shared utilities
- **Permissions:** All scripts should be executable (`chmod +x`)

## Configuration Standards
- **Modularity:** Keep configurations in dedicated directories (zsh/, nvim/, tmux/)
- **Symlinks:** Use relative paths for cross-platform compatibility
- **Documentation:** Each major component should have a README.md
- **Brewfiles:** Use layered approach (min, dev, gui, fonts)
- **OpenCode Integration:** Commands in `opencode/command/` use simple prose format

## Manual Verification Requirements
All changes must include verification steps:
1. Test configuration loads without errors
2. Verify cross-platform compatibility 
3. Check symlinks are correctly created
4. Confirm no hardcoded paths or dependencies
5. Validate script execution permissions

## Agent Guidelines for Dotfiles

This repository contains personal dotfiles for cross-platform development environments. Please adhere to the following guidelines:

- **Purpose:** This is a collection of configuration files for tools like Neovim, tmux, and zsh. There are no build, lint, or test commands.
- **Cross-platform:** All configurations must work on both macOS and Linux systems.
- **Structure:** Maintain the existing directory structure. New configurations should be placed in the appropriate tool's directory.
- **Style:** Match the existing style and conventions of the file you are editing. For example, use Lua for Neovim configs and shell script for shell configs.
- **Modification:** When modifying an existing configuration, understand its purpose within the larger setup and ensure cross-platform compatibility.
- **New Configs:** When adding a new configuration, ensure it is self-contained, cross-platform, and does not interfere with other tools.
- **OpenCode Integration:** The `opencode/` directory contains global OpenCode configuration that gets symlinked to `~/.config/opencode`.
- **Commits:** Write clear and concise commit messages explaining the change.
    - Do not include "Generated with opencode" or any agent attribution in commit messages for this repository.
- **Dependencies:** Do not add any new dependencies without explicit permission.
- **Testing:** Manually test any changes to ensure they work as expected on both macOS and Linux when possible.

## Global Development Rules

For comprehensive development guidelines, see `opencode/AGENTS.md` which contains the global rules that apply across all projects when using OpenCode.

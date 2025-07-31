# 🏠 Cross-Platform Development Dotfiles

Modern, efficient dotfiles for cross-platform development environments. Optimized for **macOS** and **Linux** with a focus on simplicity, functionality, and developer productivity.

## ✨ Core Philosophy

This repository contains a comprehensive, cross-platform development environment optimized for **macOS and Linux**. The setup is built around a "Hybrid AI" model, leveraging the unique strengths of different tools to create a powerful and efficient workflow:

-   **Neovim (NvChad):** The core editor, providing a fast, extensible, and keyboard-centric experience.
-   **OpenCode & Serena:** A powerful terminal-based AI duo for complex, multi-step tasks, code analysis, and automated modifications.
-   **GitHub Copilot:** Integrated into Neovim for real-time, inline code completions.
-   **AugmentCode:** Provides deep workspace-aware chat and context for in-editor assistance.
-   **WezTerm & Tmux:** A modern terminal emulator combined with a robust session manager for organized, persistent workspaces.
-   **Zsh:** An enhanced shell with advanced completions, aliases, and functions to streamline command-line operations.

## 🚀 Getting Started

Setting up the environment is designed to be simple and idempotent.

```bash
# 1. Clone the repository
git clone https://github.com/heyhuynhgiabuu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run the installation script
# This will set up symlinks and install necessary dependencies.
./scripts/install.sh
```

## 🛠️ Key Features

-   **Unified Development Environment:** Consistent tools, shortcuts, and configurations across macOS and Linux.
-   **Advanced Debugging:** An IntelliJ-like debugging experience for Java and Go, featuring a 5-panel UI, standard F-key hotkeys, and a clear separation between the debug console and application logs.
-   **AI-Powered Workflow:** A multi-layered AI setup that combines the strengths of OpenCode, Serena, GitHub Copilot, and AugmentCode.
-   **Optimized Shell:** A rich set of Zsh aliases and functions to accelerate common tasks for Git, Docker, Kubernetes, and more.
-   **Pre-configured Sessions:** Tmux layouts for specific languages (Java, Go) that can be launched with a single command.

## 📁 Repository Structure

The repository is organized by tool, making it easy to navigate and manage configurations.

```
.
├── nvim/          # Neovim configuration (Lua)
├── tmux/          # Tmux configuration and layouts
├── zsh/           # Zsh configuration, aliases, and functions
├── wezterm/       # WezTerm terminal emulator settings
├── aerospace/     # AeroSpace window manager configuration (macOS)
├── opencode/      # OpenCode AI agent configuration and prompts
├── augment/       # AugmentCode AI tool configuration
├── scripts/       # Installation, setup, and utility scripts
└── docs/          # Documentation and guides
```

## 💻 Development Workflows

### Java Development
```bash
# Start a pre-configured Tmux session for Java development
./scripts/tmux-java-layout.sh

# Use F9 to toggle breakpoints and F12 to start debugging.
```

### Go Development
```bash
# Start a pre--configured Tmux session for Go development
./scripts/tmux-go-layout.sh

# Use F9 to toggle breakpoints and F12 to start debugging.
```



### Development Guidelines
1. **Test thoroughly** - Verify changes on both macOS and Linux
2. **Follow KISS principle** - Keep configurations simple and maintainable
3. **Update documentation** - Reflect changes in relevant docs
4. **Maintain cross-platform compatibility** - Ensure configs work everywhere
5. **Test F-key hotkeys** - Verify debugging and development workflows
6. **Preserve existing functionality** - Don't break working configurations

### Agent Guidelines
- **Clean commits** - No "Generated with opencode" messages in this repo
- **Respect structure** - Follow existing directory organization
- **Match conventions** - Use Lua for Neovim, shell for scripts
- **Self-contained configs** - New configurations shouldn't require external dependencies

## 📄 License

Personal dotfiles collection - use at your own discretion.

**Note**: This repository follows the KISS (Keep It Simple, Stupid) principle for maintainable, cross-platform development environments.
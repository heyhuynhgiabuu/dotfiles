# 🏠 Dotfiles

A personal dotfiles collection for a modern macOS
development environment. Features:

- Neovim (NvChad v2.0): Custom Lua configs, plugin
management, and productivity enhancements.
- Zsh: Advanced completions, aliases, environment
variables, and plugin management with Zinit.
- Tmux: Vi-style navigation, session management,
Copilot integration, and custom layouts for Go/Java.
- WezTerm: Themed terminal with macOS keybindings,
workspace switching, and performance tweaks.
- Aerospace: Window manager configuration for efficient
workspace and app launching.
- Scripts: Bootstrap, install, update, and workspace
automation for development workflows.
- Docs: Guides for enhanced setup, Copilot, Go/Java,
and troubleshooting.

Easy to install, stow-based symlinking, and designed
for maintainability and rapid onboarding.

## 📁 Structure

```
dotfiles/
├── nvim/                        # Neovim with NvChad v2.0 integration
│   └── .config/nvim/lua/custom/ # Custom configurations (symlinked)
│   └── .config/nvim/            # Full Neovim config (NvChad base)
├── zsh/                         # Zsh configuration
│   ├── .zshrc
│   └── .zsh/
│       ├── advanced-completions.zsh
│       ├── aliases.zsh
│       ├── envs.zsh
│       ├── functions.zsh
│       └── starship.zsh
├── tmux/                        # Tmux configuration
│   ├── .tmux.conf
│   ├── copilot-integration.conf
│   └── tmux-autocompletion.conf
├── aerospace/                   # Aerospace window manager
│   └── .config/aerospace/aerospace.toml
├── wezterm/                     # WezTerm terminal configuration
│   └── .config/wezterm/wezterm.lua
├── docs/                        # Documentation and guides
│   ├── enhanced-development-setup.md
│   ├── github-copilot-integration.md
│   ├── go-backend-vietnamese-reference.md
│   └── go-learning-roadmap.md
├── scripts/                     # Installation and maintenance scripts
│   ├── bootstrap.sh
│   ├── dev-layout.sh
│   ├── devops-layout.sh
│   ├── go-new-project.sh
│   ├── install.sh
│   ├── note.sh
│   ├── nvchad-quick-reference.md
│   ├── setup-copilot.sh
│   ├── setup-enhanced-dev.sh
│   ├── setup-go.sh
│   ├── tmux-go-layout.sh
│   ├── tmux-java-layout.sh
│   └── update-nvchad.sh
├── AGENTS.md                    # Agent guidelines for dotfiles
└── README.md                    # This file
```

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the installation script**:
   ```bash
   ./scripts/install.sh
   ```

3. **Source your shell configuration**:
   ```bash
   source ~/.zshrc
   ```

## 🛠️ What Gets Installed

### Neovim with NvChad v2.0
- **Base**: NvChad v2.0 installed in `~/.config/nvim`
- **Custom Configs**: Your configurations symlinked from dotfiles
- **Plugins**: LSP, formatters, and custom plugins
- **Maintenance**: Update and health check scripts

### Shell Configuration
- **Zsh**: Custom `.zshrc` and `.zsh/` directory
- **Zinit**: Plugin manager setup

### Terminal Multiplexer
- **Tmux**: Custom configuration with key bindings

### Window Management
- **Aerospace**: macOS window manager configuration

### Terminal Emulator
- **WezTerm**: Custom configuration for macOS, including keybindings and workspace switching

### Agent Guidelines
- **AGENTS.md**: Contributing and commit message policy for dotfiles agents

### Scripts
- All scripts symlinked to `~/.bin` and added to PATH

## 📋 Available Scripts

| Script                | Description                                 |
|-----------------------|---------------------------------------------|
| `install.sh`          | Main installation script                    |
| `bootstrap.sh`        | Stow-based symlink setup for configs        |
| `update-nvchad.sh`    | Update NvChad while preserving customizations|
| `dev-layout.sh`       | Tmux layout for development                 |
| `devops-layout.sh`    | WezTerm layout for DevOps projects          |
| `go-new-project.sh`   | Bootstrap a new Go project                  |
| `note.sh`             | Note-taking utility (fzf + nvim + tmux)     |
| `setup-copilot.sh`    | GitHub Copilot setup for Neovim             |
| `setup-enhanced-dev.sh`| Enhanced Go/Java dev environment setup      |
| `setup-go.sh`         | Go development environment setup            |
| `tmux-go-layout.sh`   | Tmux layout for Go projects                 |
| `tmux-java-layout.sh` | Tmux layout for Java projects               |
| `nvchad-quick-reference.md` | NvChad quick reference guide           |

## 🔧 Customization

### Neovim
- Edit files in `nvim/.config/nvim/lua/custom/`
- See [nvim/README.md](nvim/README.md) for detailed instructions
- Use `./scripts/nvchad-health.sh` to verify changes

### Zsh
- Edit `zsh/.zshrc` for shell configuration
- Add custom functions to `zsh/.zsh/`

### Tmux
- Edit `tmux/.tmux.conf` for tmux settings
- Customize additional tmux configs in `tmux/copilot-integration.conf` and `tmux/tmux-autocompletion.conf`

### WezTerm
- Edit `wezterm/.config/wezterm/wezterm.lua` for theme, font, keybindings, and workspace switching

### Aerospace
- Edit `aerospace/.config/aerospace/aerospace.toml` for window manager shortcuts, workspace assignments, and app launching

## 🔄 Maintenance

### Regular Updates
```bash
# Update NvChad
./scripts/update-nvchad.sh

# Check system health
./scripts/nvchad-health.sh

# Update plugins (in Neovim)
:Lazy sync
```

### Adding New Configurations
1. Create new files in the appropriate directory
2. Update `scripts/install.sh` if needed
3. Test with a fresh installation

## 📚 Documentation

- [NvChad Integration Guide](nvim/README.md)
- [Quick Reference](scripts/nvchad-quick-reference.md)
- [Agent Guidelines](AGENTS.md)
- [Enhanced Development Setup](docs/enhanced-development-setup.md)
- [WezTerm Configuration](wezterm/.config/wezterm/wezterm.lua)
- [Aerospace Configuration](aerospace/.config/aerospace/aerospace.toml)

## 🐛 Troubleshooting

### Broken Symlinks
```bash
./scripts/install.sh  # Re-run installation
```

### NvChad Issues
```bash
./scripts/nvchad-health.sh  # Check health
./scripts/update-nvchad.sh  # Update NvChad
```

### General Issues
1. Check script permissions: `chmod +x scripts/*.sh`
2. Verify paths in scripts match your setup
3. Check for conflicting configurations

## 🤝 Contributing

1. Test changes thoroughly
2. Update documentation
3. Ensure scripts remain idempotent
4. Follow the existing structure

## 📄 License

Personal dotfiles - use at your own discretion.

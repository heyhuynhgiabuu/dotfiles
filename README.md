# 🏠 Dotfiles

Personal dotfiles repository with stow-like organization and NvChad v2.0 integration.

## 📁 Structure

```
dotfiles/
├── nvim/                    # Neovim with NvChad v2.0 integration
│   └── .config/nvim/lua/custom/  # Custom configurations (symlinked)
├── zsh/                     # Zsh configuration
│   ├── .zshrc
│   └── .zsh/
├── tmux/                    # Tmux configuration
│   └── .tmux.conf
├── aerospace/               # Aerospace window manager
├── scripts/                 # Installation and maintenance scripts
│   ├── install.sh           # Main installation script
│   ├── update-nvchad.sh     # NvChad update script
│   ├── nvchad-health.sh     # Health check script
│   └── nvchad-quick-reference.md
└── README.md               # This file
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

### Scripts
- All scripts symlinked to `~/.bin` and added to PATH

## 📋 Available Scripts

| Script | Description |
|--------|-------------|
| `install.sh` | Main installation script |
| `update-nvchad.sh` | Update NvChad while preserving customizations |
| `nvchad-health.sh` | Check NvChad integration health |
| `bootstrap.sh` | System bootstrap script |
| `note.sh` | Note-taking utility |
| `start-dev.sh` | Development environment setup |

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

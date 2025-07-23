# NvChad v2.0 Integration with Dotfiles

This directory contains the integration of NvChad v2.0 with your dotfiles repository, maintaining the stow-like structure while preserving custom configurations.

## 📁 Structure

```
nvim/
└── .config/
    └── nvim/
        └── lua/
            └── custom/          # Your custom configurations (version controlled)
                ├── chadrc.lua   # Main NvChad configuration
                ├── init.lua     # Custom initialization
                ├── mappings.lua # Custom key mappings
                ├── highlights.lua # Custom highlights
                ├── plugins.lua  # Custom plugins
                ├── options.lua  # Vim options
                ├── keymaps.lua  # Additional keymaps
                ├── lsp-config.lua # LSP configurations
                ├── configs/     # Plugin configurations
                │   ├── overrides.lua
                │   ├── lspconfig.lua
                │   ├── conform.lua
                │   └── null-ls.lua
                └── plugins/     # Custom plugin definitions
```

## 🔗 How It Works

1. **NvChad Base**: NvChad v2.0 is installed in `~/.config/nvim`
2. **Custom Configs**: Your customizations are stored in this dotfiles directory
3. **Symlinks**: The install script creates symlinks from `~/.config/nvim/lua/custom/` to your dotfiles
4. **Version Control**: Only your custom configurations are tracked in git, not NvChad itself

## 🚀 Installation

Run the main install script:
```bash
./scripts/install.sh
```

This will:
- Install NvChad v2.0 if not present
- Create symlinks for your custom configurations
- Backup any existing configurations

## 🔄 Updating NvChad

To update NvChad while preserving your customizations:
```bash
./scripts/update-nvchad.sh
```

This script:
- Backs up current custom configurations
- Updates NvChad to the latest v2.0 commit
- Restores your custom configuration symlinks

## 🔍 Health Check

Check the integration status:
```bash
./scripts/nvchad-health.sh
```

This will verify:
- NvChad installation
- Symlink integrity
- Custom configuration files

## 📝 Adding Custom Configurations

### Adding New Plugins

1. Edit `nvim/.config/nvim/lua/custom/plugins.lua`
2. Add your plugin configuration
3. Restart Neovim and run `:Lazy sync`

### Adding Custom Keymaps

1. Edit `nvim/.config/nvim/lua/custom/mappings.lua` for NvChad-style mappings
2. Or edit `nvim/.config/nvim/lua/custom/keymaps.lua` for direct vim.keymap.set calls

### Modifying LSP Settings

1. Edit `nvim/.config/nvim/lua/custom/lsp-config.lua`
2. Or modify `nvim/.config/nvim/lua/custom/configs/lspconfig.lua`

## 🛠️ Troubleshooting

### Broken Symlinks
If symlinks are broken, run:
```bash
./scripts/install.sh
```

### NvChad Not Loading Custom Configs
1. Check symlinks with `./scripts/nvchad-health.sh`
2. Ensure `chadrc.lua` is properly configured
3. Restart Neovim

### Plugin Issues
1. Run `:Lazy clean` to remove unused plugins
2. Run `:Lazy sync` to update plugins
3. Check `:checkhealth` for issues

## 📋 Maintenance Tips

1. **Regular Updates**: Update NvChad monthly using the update script
2. **Backup Before Changes**: The scripts automatically create backups
3. **Test Changes**: Use the health check script after modifications
4. **Version Control**: Commit your custom configuration changes regularly

## 🔄 Migration from Previous Setup

If you had a previous Neovim configuration:
1. Your old configs are backed up in `nvim-backup-*` directories
2. Extract useful configurations and add them to the custom directory
3. Remove old backup directories once you're satisfied with the new setup

## 📚 Resources

- [NvChad Documentation](https://nvchad.com/)
- [NvChad v2.0 GitHub](https://github.com/NvChad/NvChad/tree/v2.0)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)

# NvChad Quick Reference

## 🚀 Essential Commands

### Installation & Setup
```bash
./scripts/setup/install.sh        # Initial setup
./scripts/nvchad-health.sh        # Check integration health
./scripts/setup/update-nvchad.sh  # Update NvChad safely
```

### NvChad Commands (in Neovim)
```vim
:Lazy                             # Plugin manager
:Lazy sync                        # Update plugins
:Lazy clean                       # Remove unused plugins
:Mason                            # LSP/formatter installer
:NvChadUpdate                     # Update NvChad (use script instead)
:Telescope themes                 # Change theme
:checkhealth                      # Check Neovim health
```

## 📁 Key File Locations

### Your Custom Configs (version controlled)
```
~/dotfiles/nvim/.config/nvim/lua/custom/
├── chadrc.lua          # Main NvChad config
├── init.lua            # Custom initialization
├── mappings.lua        # NvChad-style keymaps
├── keymaps.lua         # Direct vim keymaps
├── plugins.lua         # Plugin definitions
├── options.lua         # Vim options
└── configs/            # Plugin configurations
```

### NvChad Installation
```
~/.config/nvim/         # NvChad base (not version controlled)
└── lua/custom/         # Symlinks to your dotfiles
```

## ⌨️ Default NvChad Keybindings

### File Navigation
- `<Space>ff` - Find files
- `<Space>fo` - Recent files
- `<Space>fw` - Find word
- `<Space>fb` - Find buffers
- `<Space>fh` - Help tags

### Window Management
- `<Space>h/j/k/l` - Navigate windows
- `<Space>v` - Vertical split
- `<Space>h` - Horizontal split

### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<Space>ca` - Code actions
- `<Space>rn` - Rename

### Terminal
- `<Alt>i` - Toggle floating terminal
- `<Alt>h` - Horizontal terminal
- `<Alt>v` - Vertical terminal

## 🔧 Common Customizations

### Adding a New Plugin
1. Edit `~/dotfiles/nvim/.config/nvim/lua/custom/plugins.lua`
2. Add plugin spec:
```lua
{
  "plugin/name",
  config = function()
    -- plugin config
  end,
}
```
3. Restart Neovim and run `:Lazy sync`

### Adding Custom Keymaps
Edit `~/dotfiles/nvim/.config/nvim/lua/custom/mappings.lua`:
```lua
M.general = {
  n = {
    ["<leader>w"] = { ":w<CR>", "Save file" },
  },
}
```

### Changing Theme
1. Edit `~/dotfiles/nvim/.config/nvim/lua/custom/chadrc.lua`
2. Change `theme = "theme_name"`
3. Or use `:Telescope themes` to preview

## 🐛 Troubleshooting

### Issue: Symlinks broken
**Solution**: Run `./scripts/setup/install.sh`

### Issue: Plugins not loading
**Solution**: 
1. `:Lazy clean`
2. `:Lazy sync`
3. Restart Neovim

### Issue: LSP not working
**Solution**:
1. `:Mason` - install language servers
2. `:checkhealth lsp`
3. Check `~/dotfiles/nvim/.config/nvim/lua/custom/lsp-config.lua`

### Issue: Custom configs not loading
**Solution**:
1. `./scripts/nvchad-health.sh`
2. Check `~/dotfiles/nvim/.config/nvim/lua/custom/chadrc.lua`
3. Restart Neovim

## 📋 Maintenance Checklist

### Weekly
- [ ] Update plugins: `:Lazy sync`
- [ ] Check health: `:checkhealth`

### Monthly
- [ ] Update NvChad: `./scripts/setup/update-nvchad.sh`
- [ ] Review and commit custom config changes
- [ ] Clean unused plugins: `:Lazy clean`

### Before Major Changes
- [ ] Run health check: `./scripts/nvchad-health.sh`
- [ ] Backup current setup (automatic with scripts)
- [ ] Test changes in a separate branch

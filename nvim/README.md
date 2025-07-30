# NvChad v2.0 Integration with Dotfiles

This directory contains the integration of NvChad v2.0 with your dotfiles repository, maintaining the stow-like structure while preserving custom configurations.

## 📁 Structure

```
nvim/
└── .config/
    └── nvim/
        ├── ftplugin/
        │   └── java.lua         # Clean nvim-jdtls configuration
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

## ☕ Java Development Setup

### 🚀 Enhanced F-key Hotkeys

| Key | Action | Description |
|-----|--------|-------------|
| **F3** | Toggle NvimTree | Simple file explorer (right side) |
| **F4** | Toggle Debug UI | IntelliJ-like debugging interface |
| **F5** | Start/Continue Debug | Begin or resume debugging session |
| **F6** | Pause Debug | Pause active debugging session |
| **F7** | Run Test Class | Execute all tests in current Java class |
| **F8** | Run Test Method | Execute test method under cursor |
| **F9** | Toggle Breakpoint | Add/remove breakpoint at current line |
| **F10** | Step Over | Debug: step over current line |
| **F11** | Step Into | Debug: step into function calls |
| **F12** | Debug Java/Spring Boot | Start debugging with full Spring Boot support |

### 🎯 IntelliJ-like Debug Features

#### Debug UI Layout
```
[Debug UI]     [Code Editor]     [NvimTree]
[------------- Console/REPL -------------]
```

#### Debug Variable Inspection
- **`<leader>dv`**: View variable under cursor
- **`<leader>di`**: Inspect variable in detail  
- **`<leader>dE`**: Evaluate expression
- **Hover inspection**: Mouse over variables to see values
- **Watch expressions**: Add expressions to watch panel

#### Breakpoint Management
- **F9**: Toggle breakpoint at current line
- **Visual indicators**: Breakpoints shown in gutter
- **Conditional breakpoints**: Right-click for conditions
- **Log points**: Non-breaking debug points

### 🔧 Dynamic Project Detection

The Java configuration automatically detects and supports:

#### Maven Projects
- **Spring Boot**: `mvn spring-boot:run` with debugging support
- **Regular Java**: `mvn exec:java` with main class detection

#### Gradle Projects  
- **Spring Boot**: `./gradlew bootRun` with debug arguments
- **Regular Java**: `./gradlew run` with automatic main class

### 🌱 Spring Boot Development

When F12 debugging detects a Spring Boot project:
- **Automatic profile detection**: Reads application.properties
- **Hot reload support**: Integrated with Spring Boot DevTools
- **Environment variable injection**: Debug with different profiles
- **Port management**: Automatic debug port assignment

### 🏃‍♂️ Quick Test

1. **Open Java project**: `nvim java-sample/src/main/java/Main.java`
2. **Set breakpoint**: Press **F9** on any line
3. **Start debugging**: Press **F12** → Should start debug session
4. **Toggle debug UI**: Press **F4** → Should show debug panels
5. **Toggle file explorer**: Press **F3** → Should show NvimTree on right
6. **Step through code**: Use **F10** (step over) or **F11** (step into)

### 📋 KISS Principle Implementation

Following "Keep It Simple, Stupid" philosophy:
- **Removed Neo-tree**: Complex file manager replaced with simple NvimTree
- **Essential features only**: Focus on debugging and core development
- **Consistent F-keys**: Logical progression F3→F4→F5...F12
- **Visual clarity**: Clean debug UI without overwhelming complexity

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

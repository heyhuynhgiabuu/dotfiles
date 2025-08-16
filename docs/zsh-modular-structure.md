# Modular ZSH Configuration Structure

This document explains the modular zsh configuration structure implemented in the dotfiles.

## Directory Structure

```
zsh/
├── .zshrc                     # Main configuration file
└── .zsh/                      # Modular configuration directory
    ├── aliases.zsh            # Command aliases and shortcuts
    ├── envs.zsh              # Environment variables
    ├── functions.zsh         # Custom shell functions
    ├── performance-opts.zsh  # Performance optimizations
    ├── fzf.zsh              # FZF fuzzy finder configuration
    ├── starship.zsh         # Starship prompt configuration
    ├── starship.toml        # Starship prompt theme
    └── advanced-completions.zsh  # Advanced completion settings
```

## Configuration Loading Order

The `.zshrc` loads modules in this order to prevent conflicts:

1. **Performance optimizations** (early load)
2. **Path setup** and core environment
3. **Starship prompt** (before oh-my-zsh)
4. **Oh-my-zsh** core
5. **Zinit** plugin manager
6. **Completion system** initialization
7. **Conditional integrations** (NVM, SDKMAN, etc.)
8. **Modular configurations**:
   - `envs.zsh` - Environment variables
   - `aliases.zsh` - Command aliases
   - `functions.zsh` - Custom functions
   - `advanced-completions.zsh` - Completion enhancements
9. **FZF integration** (loaded last to avoid key binding conflicts)

## Module Descriptions

### Core Modules

#### `performance-opts.zsh`
- **Purpose**: Shell startup and command performance optimizations
- **Features**: 
  - Command caching with secure cache directories
  - Lazy loading optimizations
  - Automatic cache cleanup
- **Security**: Uses `~/.cache/zsh/` with mode 700 permissions

#### `aliases.zsh`
- **Purpose**: Command aliases and shortcuts
- **Features**:
  - Git performance aliases (`gs`, `ghealth`, `gopt`)
  - Homebrew performance aliases (`bp`, `bs`, `bu`)
  - Cross-platform compatibility
- **Organization**: Grouped by tool/purpose with clear comments

#### `fzf.zsh`
- **Purpose**: FZF fuzzy finder integration
- **Features**:
  - Ctrl+R history search popup
  - File and directory fuzzy finding
  - Preview integration with `bat` and `eza`
  - Custom theme (Kanagawa-inspired)
- **Key Bindings**:
  - `Ctrl+R`: Fuzzy history search
  - `Ctrl+T`: Fuzzy file finder
  - `Alt+C`: Fuzzy directory finder

### Optional Modules

#### `envs.zsh`
- **Purpose**: Environment variable definitions
- **Content**: Project-specific environment variables
- **Usage**: Sourced conditionally if file exists

#### `functions.zsh`
- **Purpose**: Custom shell functions
- **Content**: Utility functions and shell helpers
- **Usage**: Sourced conditionally if file exists

#### `advanced-completions.zsh`
- **Purpose**: Enhanced completion configurations
- **Content**: Complex completion rules and customizations
- **Usage**: Sourced conditionally if file exists

## Configuration Philosophy

### Modular Design Principles

1. **Separation of Concerns**: Each module handles a specific aspect
2. **Conditional Loading**: Modules only load if they exist
3. **Performance First**: Optimizations loaded early
4. **Conflict Prevention**: Load order prevents key binding conflicts
5. **Security**: Secure cache handling and permissions

### Loading Strategy

```bash
# Pattern used throughout .zshrc
[[ -f "$ZSH_CONFIG_DIR/module.zsh" ]] && source "$ZSH_CONFIG_DIR/module.zsh"
```

This pattern ensures:
- No errors if modules don't exist
- Easy enabling/disabling by renaming files
- Clear dependency management

## Customization Guide

### Adding New Modules

1. Create new file in `zsh/.zsh/`:
   ```bash
   touch zsh/.zsh/my-module.zsh
   ```

2. Add loading line to `.zshrc`:
   ```bash
   [[ -f "$ZSH_CONFIG_DIR/my-module.zsh" ]] && source "$ZSH_CONFIG_DIR/my-module.zsh"
   ```

3. Place the loading line in appropriate position based on dependencies

### Disabling Modules

Temporarily disable by renaming:
```bash
mv zsh/.zsh/module.zsh zsh/.zsh/module.zsh.disabled
```

### Module Dependencies

Some modules have dependencies:
- `performance-opts.zsh` → Must load early
- `fzf.zsh` → Must load after completion system
- `aliases.zsh` → Should load after performance tools

## Security Considerations

### Cache Security
- All modules use secure cache directories (`~/.cache/*/`)
- Cache directories created with mode 700
- Atomic file operations to prevent corruption

### Environment Variables
- No sensitive data in version-controlled modules
- Use `envs.zsh` for project-specific secrets (add to .gitignore if needed)

### File Permissions
- Configuration files should be readable only by user
- Executable scripts should have appropriate permissions

## Troubleshooting

### Module Loading Issues

Check if module exists:
```bash
ls -la ~/.zsh/
```

Test individual module loading:
```bash
source ~/.zsh/module.zsh
```

### Performance Issues

Profile zsh startup:
```bash
time zsh -i -c "exit"
```

Disable modules one by one to identify issues.

### Key Binding Conflicts

If key bindings don't work:
1. Check loading order in `.zshrc`
2. Ensure fzf loads last
3. Test in clean shell: `zsh --no-rcs`

## Migration from Monolithic Configuration

To migrate from a single `.zshrc`:

1. **Backup current configuration**:
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. **Create modular structure**:
   ```bash
   mkdir -p ~/.zsh
   ```

3. **Split configuration by function**:
   - Aliases → `aliases.zsh`
   - Functions → `functions.zsh`
   - Environment → `envs.zsh`
   - Performance → `performance-opts.zsh`

4. **Update loading logic** in main `.zshrc`

5. **Test and refine** module loading order

## Benefits of Modular Structure

- **Maintainability**: Easy to modify specific functionality
- **Performance**: Conditional loading reduces startup time
- **Organization**: Clear separation of concerns
- **Debugging**: Easy to isolate issues
- **Portability**: Modules can be shared across systems
- **Security**: Secure cache handling and permissions

---

**Last Updated**: January 2025  
**ZSH Configuration Version**: 2.0 (Modular + Security Hardened)
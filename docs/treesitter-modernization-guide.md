# Neovim Treesitter Modernization Guide

## Overview

This guide documents the migration from nvim-treesitter `master` branch to the new `main` branch, resolving common issues like "Impossible pattern" errors and parser installation failures.

## Problem Background

The nvim-treesitter plugin underwent a major rewrite, moving from the `master` branch to a new `main` branch with:
- Simplified configuration API
- Removal of legacy features
- Better error handling
- Cleaner query system

Common issues with the old setup:
- `query: invalid structure` errors  
- `Impossible pattern: "~" @conceal` errors
- Parser download failures
- Query conflicts between versions

## Migration Strategy

### 1. Configuration Changes

**Before (master branch):**
```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  highlight = { enable = true },
  textobjects = { enable = true },
  incremental_selection = { enable = true },
  -- Many other options...
})
```

**After (main branch):**
```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "vim", "vimdoc", "query",
    "javascript", "typescript", "tsx",
    -- Specific parsers only
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
  -- Simplified configuration
})
```

### 2. Feature Replacements

| Master Branch Feature | Main Branch Replacement |
|----------------------|-------------------------|
| `textobjects` module | `nvim-treesitter-textobjects` plugin |
| `incremental_selection` | Separate plugin or built-in vim features |
| `ensure_installed = "all"` | Specific parser list + `auto_install = true` |
| Complex `disable` functions | Simplified language-specific disabling |

### 3. Removed Features

These features have no direct replacement in main branch:
- Context-aware commenting
- Automatic language detection for mixed files
- Advanced incremental selection with custom keymaps
- Complex query predicates

## Automated Fix Process

Our dotfiles include an automated fix script that:

1. **Backs up existing data** to timestamped directory
2. **Removes problematic queries** that cause "Impossible pattern" errors
3. **Clears parser cache** to force clean reinstallation
4. **Updates plugin configuration** to use main branch
5. **Verifies environment** variables and permissions

### Running the Fix

```bash
# Close all Neovim instances first
./scripts/fix-treesitter.sh
```

The script will:
- Prompt for confirmation
- Create backup in `~/.nvim-treesitter-backup-TIMESTAMP`
- Clean problematic files safely
- Update configuration automatically

## Manual Recovery Steps

If the automated script fails:

### Step 1: Clean Cache
```bash
rm -rf ~/.local/share/nvim/treesitter
rm -rf ~/.local/share/nvim/parser-info
```

### Step 2: Remove Problematic Queries
```bash
# Remove the specific file causing "Impossible pattern" error
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/queries/vimdoc/highlights.scm

# Search for other problematic files
find ~/.local/share/nvim/lazy/nvim-treesitter/queries -name "*.scm" -exec grep -l "~.*@conceal" {} \;
```

### Step 3: Update Plugin Branch
In your plugin manager configuration:
```lua
{
  "nvim-treesitter/nvim-treesitter",
  branch = "main",  -- Specify main branch
  build = ":TSUpdate",
}
```

### Step 4: Install Parsers
```bash
nvim -c 'TSUpdate' -c 'quit'
```

## Configuration Best Practices

### 1. Error Handling
```lua
config = function()
  -- Disable temporarily to avoid errors during setup
  vim.cmd("TSDisable highlight")
  
  require("nvim-treesitter.configs").setup({
    -- Your configuration
  })
  
  -- Re-enable after setup
  vim.cmd("TSEnable highlight")
  
  -- Clear any error messages
  vim.cmd("messages clear")
end
```

### 2. Performance Optimization
```lua
highlight = {
  enable = true,
  disable = function(lang, buf)
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      return true
    end
    return false
  end,
}
```

### 3. Essential Parsers Only
```lua
ensure_installed = {
  -- Core Neovim
  "lua", "vim", "vimdoc", "query",
  
  -- Web development
  "html", "css", "javascript", "typescript", "tsx",
  
  -- Data formats
  "json", "jsonc", "yaml", "toml",
  
  -- Documentation
  "markdown", "markdown_inline",
  
  -- Systems
  "bash", "c",
}
```

## Verification Steps

After migration, verify the setup:

### 1. Check Health
```vim
:checkhealth nvim-treesitter
```

### 2. Test Highlighting
Open files in different languages and verify syntax highlighting works.

### 3. Check Parser Installation
```vim
:TSInstallInfo
```

### 4. Test Manual Commands
```vim
:TSUpdate
:TSEnable highlight
:TSDisable highlight
```

## Rollback Plan

If issues persist, you can rollback:

### 1. Restore Backup
```bash
# Find your backup directory
ls ~/.nvim-treesitter-backup-*

# Restore specific components
cp -r ~/.nvim-treesitter-backup-TIMESTAMP/treesitter ~/.local/share/nvim/
```

### 2. Revert Configuration
Change back to master branch in your plugin configuration:
```lua
{
  "nvim-treesitter/nvim-treesitter",
  branch = "master",  -- Revert to master
}
```

### 3. Force Plugin Update
```bash
nvim -c 'Lazy clear nvim-treesitter' -c 'Lazy install nvim-treesitter' -c 'quit'
```

## Common Issues and Solutions

### "Parser not found" errors
- Run `:TSUpdate` to install missing parsers
- Check `:TSInstallInfo` for available parsers
- Ensure parser names match exactly (e.g., "tsx" not "typescriptreact")

### Slow startup with highlighting
- Add file size limits to disable function
- Disable for specific problematic languages
- Consider using `additional_vim_regex_highlighting = false`

### Query errors for custom languages
- Update custom queries to match new query format
- Check official queries in main branch for examples
- Remove deprecated query predicates

## Future Maintenance

### Keeping Up with Changes
- Monitor [nvim-treesitter discussions](https://github.com/nvim-treesitter/nvim-treesitter/discussions)
- Check [migration guides](https://github.com/nvim-treesitter/nvim-treesitter/discussions/7927)
- Test changes in isolated environment first

### Parser Updates
- Run `:TSUpdate` regularly to get latest parsers
- Monitor for breaking changes in parser repositories
- Keep parser list minimal to reduce maintenance overhead

## References

- [nvim-treesitter main branch](https://github.com/nvim-treesitter/nvim-treesitter/tree/main)
- [Migration discussion](https://github.com/nvim-treesitter/nvim-treesitter/discussions/7927)
- [Treesitter documentation](https://tree-sitter.github.io/tree-sitter/)

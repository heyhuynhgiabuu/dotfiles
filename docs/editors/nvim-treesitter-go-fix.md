# Fix Neovim Treesitter Go Error

**Error:** `Query error at 7:2. Invalid node type "function_expression"`

## Root Cause

The `go.nvim` plugin uses outdated treesitter queries that reference `function_expression`, which no longer exists in the newer Go treesitter grammar.

## Solution Applied

**File:** `nvim/.config/nvim/lua/custom/plugins/go.lua`

Added `textobjects = false` to disable the problematic treesitter textobjects feature.

## Steps to Fix

### 1. Restart Neovim

```bash
# Close all Neovim instances
pkill nvim

# Open Neovim
nvim
```

### 2. Update Plugins

```vim
:Lazy update go.nvim
:Lazy update nvim-treesitter
```

Wait for updates to complete.

### 3. Update Treesitter Parsers

```vim
:TSUpdate go
:TSUpdate
```

### 4. Restart Neovim Again

```vim
:qa!
```

Then open Neovim normally.

## Verify Fix

1. Open a Go file:

```bash
nvim test.go
```

2. Should see NO errors in `:messages`

3. Treesitter highlighting should work

## If Error Persists

### Option 1: Clean Install

```vim
:Lazy clean
:Lazy sync
:qa!
```

Then restart Neovim.

### Option 2: Manually Update go.nvim

```bash
cd ~/.local/share/nvim/lazy/go.nvim
git pull origin master
```

Then in Neovim:

```vim
:Lazy build go.nvim
:qa!
```

### Option 3: Remove Conflicting Queries

```bash
# Backup first
cp -r ~/.local/share/nvim/lazy/go.nvim ~/.local/share/nvim/lazy/go.nvim.backup

# Remove problematic query files
rm -rf ~/.local/share/nvim/lazy/go.nvim/queries/go/textobjects.scm
```

Then restart Neovim.

## Alternative: Use nvim-treesitter-textobjects Directly

If you need textobjects for Go, use `nvim-treesitter-textobjects` instead of `go.nvim`'s built-in version.

**Add to plugins:**

```lua
-- nvim/.config/nvim/lua/custom/plugins/treesitter-textobjects.lua
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
      },
    })
  end,
}
```

This uses the official, up-to-date textobjects queries.

## Understanding the Error

**What happened:**

- Go's treesitter grammar was updated
- `function_expression` was renamed/removed
- `go.nvim` still references the old node type
- Neovim treesitter parser can't find the node type → error

**What `textobjects = false` does:**

- Disables go.nvim's textobjects feature
- Prevents outdated queries from loading
- Go highlighting and LSP still work perfectly
- You lose some navigation features (can be replaced with nvim-treesitter-textobjects)

## Current Status

✅ **Fixed:** Error should no longer appear  
✅ **Go LSP:** Still works (gopls)  
✅ **Syntax Highlighting:** Still works (treesitter)  
✅ **Formatting:** Still works (gofumpt)  
⚠️ **Textobjects:** Disabled (can re-enable with nvim-treesitter-textobjects)

## What Still Works

Everything except go.nvim's textobjects:

- ✅ Go syntax highlighting
- ✅ Code completion (gopls)
- ✅ Go to definition
- ✅ Auto-formatting (gofumpt)
- ✅ Imports management
- ✅ Code actions
- ✅ Debugging (DAP)

## What's Disabled

- ❌ go.nvim textobjects (e.g., `vaf` to select function)
- ❌ go.nvim textobject motions

**Workaround:** Use `nvim-treesitter-textobjects` plugin instead (see above).

## Prevention

To avoid similar errors in the future:

1. **Keep plugins updated:**

```vim
:Lazy update
```

2. **Keep treesitter parsers updated:**

```vim
:TSUpdate
```

3. **Monitor plugin compatibility:**
   - Check if plugins are actively maintained
   - Look for treesitter-related breaking changes

## Related Files Modified

1. `nvim/.config/nvim/lua/custom/plugins/go.lua` - Added `textobjects = false`

## Summary

**Problem:** Outdated treesitter query in go.nvim  
**Solution:** Disabled go.nvim textobjects feature  
**Impact:** Minimal - all core Go features still work  
**Alternative:** Use nvim-treesitter-textobjects for better textobject support

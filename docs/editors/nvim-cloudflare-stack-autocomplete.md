# Neovim Autocomplete Setup for Cloudflare Stack

**Tech Stack:** Bun + Hono + TanStack Start + Drizzle ORM + Tailwind CSS + React + Cloudflare

---

## Current Status

✅ **Already Configured:**

- TypeScript/JavaScript (typescript-tools.nvim)
- React/JSX/TSX (treesitter)
- CSS (css-lsp)
- HTML (html-lsp)
- JSON (json-lsp in Mason)
- Treesitter parsers (typescript, tsx, javascript, json)

❌ **Missing (Need to Add):**

- Tailwind CSS LSP (CRITICAL for shadcn/ui)
- TOML LSP (for wrangler.toml)
- SQL completion (for Drizzle schema files)
- JSON schema validation (package.json, tsconfig.json)

---

## Setup Instructions

### Step 1: Restart Neovim to Load New Plugin

```bash
# Open Neovim
nvim

# The new plugin file will auto-load
# You created: nvim/.config/nvim/lua/custom/plugins/cloudflare-stack.lua
```

### Step 2: Install LSP Servers

```vim
:Mason
```

**Install these manually if not auto-installed:**

- `tailwindcss-language-server` (CRITICAL)
- `json-lsp` (for package.json)
- `taplo` (for wrangler.toml)
- `eslint_d` (for linting)
- `prettierd` (faster Prettier)
- `rustywind` (Tailwind class sorter)

Press `i` to install, wait for completion.

### Step 3: Verify Treesitter Parsers

```vim
:TSInstall typescript tsx javascript json jsonc toml css html sql
```

### Step 4: Test Autocomplete

**TypeScript/React:**

```typescript
// apps/web/src/routes/index.tsx
import { Button } from "~/components/ui/button"; // Should autocomplete
```

**Tailwind CSS:**

```typescript
<div className="bg-blue-500 text-white p-4">
  {/* Tailwind classes should autocomplete with color previews */}
</div>
```

**Hono API:**

```typescript
// apps/api/src/index.ts
import { Hono } from "hono"; // Should autocomplete

const app = new Hono();
app.get("/"); // Methods should autocomplete
```

**Drizzle ORM:**

```typescript
// apps/api/src/db/schema.ts
import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const tasks = sqliteTable("tasks", {
  id: text("id"), // Should autocomplete Drizzle functions
});
```

---

## Expected Autocomplete Features

### 1. TypeScript/JavaScript

- ✅ Import autocomplete
- ✅ Function signatures
- ✅ Type checking
- ✅ Inlay hints (parameter names, types)
- ✅ Auto-import missing imports

**Keymaps (from typescript-tools.lua):**

- `<leader>tso` - Organize imports
- `<leader>tsr` - Remove unused imports
- `<leader>tsa` - Add missing imports
- `<leader>tsf` - Fix all issues

### 2. Tailwind CSS

- ✅ Class name autocomplete
- ✅ Color previews inline
- ✅ Variant suggestions
- ✅ Works in:
  - `className="..."`
  - `class="..."`
  - `cn("...")` (shadcn/ui helper)
  - `clsx("...")`

### 3. React/JSX/TSX

- ✅ Component props autocomplete
- ✅ React hooks autocomplete
- ✅ Event handlers
- ✅ JSX tag closing

### 4. JSON (package.json, tsconfig.json)

- ✅ Schema validation
- ✅ Autocomplete for known fields
- ✅ Error checking

### 5. TOML (wrangler.toml)

- ✅ Syntax highlighting
- ✅ Key autocomplete
- ✅ Error checking

### 6. SQL (Drizzle schemas)

- ✅ SQL keyword autocomplete
- ✅ Basic SQL completion in TypeScript files

---

## Troubleshooting

### Tailwind Autocomplete Not Working

**Problem:** Tailwind classes don't autocomplete

**Solution:**

1. Check if `tailwindcss-language-server` is installed:

```vim
:Mason
# Look for "tailwindcss-language-server" with green checkmark
```

2. Verify `tailwind.config.ts` exists in project root:

```bash
ls apps/web/tailwind.config.ts
```

3. Restart LSP:

```vim
:LspRestart
```

4. Check LSP is attached:

```vim
:LspInfo
# Should show "tailwindcss" attached
```

### TypeScript Autocomplete Slow

**Problem:** Autocomplete takes too long

**Solution:**

```vim
# Check TypeScript server status
:TSToolsClientStatus

# Restart TypeScript server
:TSToolsRestart
```

### Hono API Types Not Working

**Problem:** Hono imports don't autocomplete

**Solution:**

1. Ensure `typescript-language-server` is running:

```vim
:LspInfo
```

2. Check `package.json` has Hono installed:

```bash
cd apps/api
bun install hono
```

3. Restart Neovim to reload types

### Drizzle ORM No Autocomplete

**Problem:** Drizzle imports don't work

**Solution:**

1. Install Drizzle:

```bash
cd apps/api
bun add drizzle-orm
bun add -D drizzle-kit
```

2. Restart LSP:

```vim
:LspRestart
```

### ESLint Errors Not Showing

**Problem:** No linting errors displayed

**Solution:**

1. Verify `eslint_d` is installed:

```vim
:Mason
```

2. Check `.eslintrc.js` or `eslint.config.js` exists in project:

```bash
ls apps/web/.eslintrc.js
# or
ls apps/web/eslint.config.js
```

3. Restart ESLint:

```vim
:EslintFixAll
```

---

## Performance Tips

### Faster Autocomplete

1. **Use `prettierd` instead of `prettier`:**

```vim
:Mason
# Install "prettierd"
```

2. **Limit completion items:**

```lua
-- Already configured in cmp.lua
performance = {
  debounce = 60,
  throttle = 30,
  fetching_timeout = 200,
}
```

3. **Disable unused LSP servers:**

```vim
# If you don't need copilot:
:LspStop copilot
```

### Reduce Memory Usage

1. **Disable TypeScript separate diagnostic server** (if slow):

```lua
-- Edit: nvim/.config/nvim/lua/custom/plugins/typescript-tools.lua
settings = {
  separate_diagnostic_server = false, -- Change to false
}
```

2. **Limit Mason concurrent installers:**

```lua
-- Already set to 15 in mason.lua
max_concurrent_installers = 10, -- Reduce to 10 if slow
```

---

## Keymaps Reference

### LSP (General)

- `gD` - Go to declaration
- `gd` - Go to definition
- `K` - Show hover documentation
- `gi` - Go to implementation
- `<C-k>` - Show signature help
- `<space>D` - Go to type definition
- `<space>ra` - Rename symbol
- `<space>ca` - Code action
- `gr` - Show references

### TypeScript Specific

- `<leader>tso` - Organize imports
- `<leader>tss` - Sort imports
- `<leader>tsr` - Remove unused imports
- `<leader>tsu` - Remove all unused
- `<leader>tsa` - Add missing imports
- `<leader>tsf` - Fix all
- `<leader>tsg` - Go to source definition
- `<leader>tsR` - Rename file
- `<leader>tsF` - File references

### Completion

- `<C-Space>` - Trigger completion
- `<C-n>` / `<C-p>` - Next/previous item
- `<Tab>` - Select next item / expand snippet
- `<S-Tab>` - Select previous item / jump back in snippet
- `<CR>` - Confirm selection
- `<C-e>` - Close completion menu

---

## File-Specific Configuration

### For React Files (`.tsx`, `.jsx`)

Auto-configured when you open React files:

- React hooks autocomplete
- JSX prop autocomplete
- Event handler suggestions
- Component import suggestions

### For Hono Files (`apps/api/src/**/*.ts`)

Auto-configured when you open TypeScript files in API:

- Hono method autocomplete
- Cloudflare Workers types
- Request/Response types
- Context autocomplete

### For Drizzle Files (`apps/api/src/db/*.ts`)

Auto-configured when you open DB schema files:

- Drizzle ORM autocomplete
- SQL type suggestions
- Table definition helpers

---

## Verification Checklist

After setup, verify each item works:

- [ ] Open `apps/web/src/routes/index.tsx` → TypeScript autocomplete works
- [ ] Type `className="bg-` → Tailwind classes appear
- [ ] Import `Button` from `~/components/ui/button` → Auto-imports
- [ ] Open `apps/api/src/index.ts` → Hono methods autocomplete
- [ ] Open `apps/api/wrangler.toml` → TOML syntax highlighting
- [ ] Open `apps/web/package.json` → JSON schema validation
- [ ] Type `app.get("/")` → Hono method signature shows
- [ ] Import Drizzle types → Autocomplete works
- [ ] ESLint errors show in React files
- [ ] `:LspInfo` shows all servers attached

---

## Common Issues

### "LSP client not attached"

**Cause:** LSP server not running for file type

**Fix:**

```vim
:LspInfo
# Check which servers should be attached

# Restart LSP
:LspRestart

# Or restart Neovim
:qa!
```

### "Autocomplete menu doesn't show"

**Cause:** `nvim-cmp` not loaded

**Fix:**

```vim
# Check if cmp is loaded
:lua print(vim.inspect(require("cmp")))

# Reload completion
:source ~/.config/nvim/lua/plugins/completions.lua
```

### "Tailwind colors not showing"

**Cause:** `nvim-colorizer` or `tailwind-tools` not loaded

**Fix:**

```vim
# Verify tailwind-tools is loaded
:Lazy
# Search for "tailwind-tools" → should show "loaded"

# Restart Neovim
```

### "Too many completion items"

**Cause:** Multiple completion sources active

**Fix:** Check completion sources:

```vim
:CmpSourcesDebug
# Should show: nvim_lsp, luasnip, buffer, path
```

---

## Additional Enhancements

### Optional: Add React Snippets

```bash
cd ~/.config/nvim/lua/custom/plugins
```

Create `react-snippets.lua`:

```lua
return {
  "rafamadriz/friendly-snippets",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
}
```

### Optional: Add Emmet for JSX

```lua
-- In cloudflare-stack.lua, add to lspconfig setup:
lspconfig.emmet_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "html",
    "typescriptreact",
    "javascriptreact",
    "css",
    "sass",
    "scss",
  },
}
```

Then install:

```vim
:Mason
# Install "emmet-ls"
```

### Optional: Add Bun Runtime Types

```bash
# In your project
bun add -D @types/bun
```

Neovim will automatically pick up Bun types.

---

## Summary

**What you now have:**

✅ TypeScript/JavaScript autocomplete (typescript-tools.nvim)  
✅ React/JSX/TSX autocomplete  
✅ Tailwind CSS autocomplete with color previews  
✅ Hono API autocomplete  
✅ Drizzle ORM autocomplete  
✅ JSON schema validation (package.json, tsconfig.json)  
✅ TOML support (wrangler.toml)  
✅ SQL completion  
✅ ESLint integration  
✅ Auto-formatting on save

**Performance:**

- Fast completion (debounced)
- Minimal memory usage
- Works with large monorepos

**Next steps:**

1. Run `:Mason` and install missing LSP servers
2. Open a React file and test Tailwind autocomplete
3. Open a Hono file and test API autocomplete
4. Enjoy coding! 🚀

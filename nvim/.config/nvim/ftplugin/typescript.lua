-- TypeScript specific settings
-- Enhanced settings for TypeScript development

-- Set TypeScript specific options
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Enable semantic highlighting if available

-- TypeScript specific keymaps (additional to typescript-tools plugin)
local opts = { buffer = 0, silent = true }

-- Quick fix for TypeScript errors
vim.keymap.set("n", "<leader>tf", function()
  vim.cmd("TSToolsFixAll")
  vim.cmd("write")
end, vim.tbl_extend("force", opts, { desc = "Fix all TS errors and save" }))

-- Quick organize imports and format
vim.keymap.set("n", "<leader>to", function()
  vim.cmd("TSToolsOrganizeImports")
  require("conform").format({ bufnr = 0 })
end, vim.tbl_extend("force", opts, { desc = "Organize imports and format" }))

-- Enable inlay hints if supported
if vim.lsp.inlay_hint then
  vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
end

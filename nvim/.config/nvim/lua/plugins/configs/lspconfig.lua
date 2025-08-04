-- Default LSP configuration
local lspconfig = require "lspconfig"

-- Default on_attach function
local on_attach = function(client, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts "Hover")
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts "Show signature")
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  vim.keymap.set("n", "<space>ra", vim.lsp.buf.rename, opts "NvRenamer")
  vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts "Code action")
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts "Show references")
end

-- Default capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "clangd" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
-- Đã loại bỏ ts_ls để tránh xung đột với typescript-tools.nvim

-- Enhanced Go language server configuration
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  settings = {
    gopls = {
      -- Enhanced postfix completions for better suggestions
      experimentalPostfixCompletions = true,
      -- Enable all available completions
      completeUnimported = true,
      usePlaceholders = true,
      deepCompletion = true,
      -- Analysis settings
      analyses = {
        unusedparams = true,
        shadow = true,
        fieldalignment = true,
        nilness = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      -- Better import organization
      ["local"] = "github.com/yourname",
      goimports = true,
      -- Enhanced hints
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

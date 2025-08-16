-- Unified LSP Configuration - Performance Optimized
-- Consolidates all LSP setup into a single, efficient configuration
-- Eliminates conflicts and improves startup time

local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
  vim.notify("LSPConfig not available", vim.log.levels.WARN)
  return {}
end

local M = {}

-- Performance: Single capabilities object shared across all servers
local function create_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Enhanced completion support
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
  
  return capabilities
end

-- Performance: Optimized on_attach with lazy keymap loading
local function create_on_attach(client, bufnr)
  -- Defer non-critical keymaps for faster attach
  vim.schedule(function()
    local function opts(desc)
      return { buffer = bufnr, desc = "LSP " .. desc, silent = true }
    end

    -- Core navigation (immediate)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts "Go to definition") 
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts "Hover")
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, opts "Go to implementation")
    
    -- Enhanced shortcuts (deferred)
    vim.keymap.set("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts "Ctrl+Click definition")
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts "Signature help")
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts "Rename")
    vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action, opts "Code action")
    vim.keymap.set("n", "grr", vim.lsp.buf.references, opts "References")
    
    -- Type navigation
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts "Type definition")
    
    -- Workspace management (rarely used - lowest priority)
    vim.defer_fn(function()
      vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
      vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
      vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts "List workspace folders")
    end, 100)
  end)

  -- Enable omnifunc immediately
  vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
end

-- Server configurations with performance optimizations
M.server_configs = {
  -- Lua Language Server (optimized for Neovim)
  lua_ls = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        telemetry = { enable = false },
        completion = { 
          callSnippet = "Replace",
          keywordSnippet = "Replace"
        },
        format = { enable = false }, -- Use stylua via conform.nvim
      },
    },
  },

  -- Go Language Server (performance tuned)
  gopls = {
    cmd = { "gopls" },
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        completeUnimported = true,
        usePlaceholders = true,
        deepCompletion = true,
        analyses = {
          unusedparams = true,
          shadow = true,
          fieldalignment = false, -- Disable for performance
          nilness = true,
          useany = true,
        },
        staticcheck = true,
        gofumpt = true,
        ["local"] = "github.com/yourname",
        goimports = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        -- Performance optimization
        memoryMode = "DegradeClosed",
        symbolMatcher = "FastFuzzy",
      },
    },
  },

  -- Python (Pyright) - streamlined
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic", -- Faster than "strict"
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },

  -- Basic servers (minimal config for speed)
  html = {},
  cssls = {},
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
  },
  
  -- Java handled by nvim-jdtls plugin
  jdtls = {}, -- Minimal setup, actual config in plugin
}

-- Performance: Setup all servers efficiently
function M.setup()
  local capabilities = create_capabilities()
  
  -- Batch setup to minimize overhead
  for server, config in pairs(M.server_configs) do
    local server_config = vim.tbl_deep_extend("force", {
      on_attach = create_on_attach,
      capabilities = capabilities,
    }, config)
    
    -- Only setup if server is available (avoid startup errors)
    pcall(function()
      lspconfig[server].setup(server_config)
    end)
  end
end

return M
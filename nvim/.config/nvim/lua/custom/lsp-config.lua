-- Enhanced LSP configuration with Go and Java optimizations
local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
  return
end

-- Enhanced on_attach function with Go/Java specific keymaps
local on_attach = function(client, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  -- Basic LSP keymaps
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

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- Enhanced capabilities for better completion
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

-- Lua language server specific configuration
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "lua-language-server" }, -- Explicitly specify the command
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Go language server configuration with enhanced autocompletion
lspconfig.gopls.setup {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    
    -- Manual format only (disabled auto-format to avoid errors with incomplete code)
    -- Use <space>fm to format manually when needed
    -- if client.supports_method("textDocument/formatting") then
    --   vim.api.nvim_create_autocmd("BufWritePre", {
    --     group = vim.api.nvim_create_augroup("GoFormat", {}),
    --     buffer = bufnr,
    --     callback = function()
    --       vim.lsp.buf.format({ bufnr = bufnr })
    --     end,
    --   })
    -- end
  end,
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

-- Java language server configuration with enhanced autocompletion
lspconfig.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "jdtls" },
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern("pom.xml", "build.gradle", ".git")(fname) or vim.fn.getcwd()
  end,
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = "interactive",
      },
      -- Enhanced completion settings
      completion = {
        -- Better completions for common patterns
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
          "java.util.Collections.*",
          "java.util.Arrays.*",
          "java.lang.String.*",
          "java.util.stream.Collectors.*",
        },
        -- Enable automatic imports
        importOrder = {
          "java",
          "javax",
          "com",
          "org"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*", 
          "sun.*",
        },
      },
      -- Better import management
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      -- Enhanced inlay hints
      inlayHints = {
        parameterNames = {
          enabled = "all",
        },
      },
      -- Code generation preferences  
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },
}

-- 
-- lspconfig.pyright.setup { blabla}

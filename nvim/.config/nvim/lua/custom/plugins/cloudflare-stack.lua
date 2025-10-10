-- Cloudflare Stack Autocomplete Support
-- Optimized for: Hono + TanStack Start + Drizzle + Tailwind + React

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require "lspconfig"
      local on_attach = function(client, bufnr)
        local function map(desc)
          return { buffer = bufnr, desc = "LSP " .. desc }
        end
        
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map "Go to declaration")
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map "Go to definition")
        vim.keymap.set("n", "K", vim.lsp.buf.hover, map "Hover")
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, map "Go to implementation")
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, map "Show signature")
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, map "Go to type definition")
        vim.keymap.set("n", "<space>ra", vim.lsp.buf.rename, map "Rename")
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, map "Code action")
        vim.keymap.set("n", "gr", vim.lsp.buf.references, map "Show references")
      end

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

      -- Tailwind CSS LSP (CRITICAL for shadcn/ui)
      lspconfig.tailwindcss.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
        },
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "classList", "ngClass" },
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning",
            },
            experimental = {
              classRegex = {
                "tw`([^`]*)",
                "tw=\"([^\"]*)",
                "tw={\"([^\"}]*)",
                "tw\\.\\w+`([^`]*)",
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^'\"`]*)(?:'|\"|`)" },
                { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^'\"`]*)(?:'|\"|`)" },
              },
            },
            validate = true,
          },
        },
      }

      -- JSON LSP (for package.json, tsconfig.json, wrangler.toml)
      lspconfig.jsonls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      }

      -- TOML LSP (for wrangler.toml, Cargo.toml)
      lspconfig.taplo.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }

      -- ESLint (for TanStack Start + React)
      lspconfig.eslint.setup {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
        capabilities = capabilities,
        settings = {
          workingDirectories = { mode = "auto" },
        },
      }

      return opts
    end,
  },

  -- SchemaStore for JSON schemas (package.json, tsconfig.json, etc.)
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Enhanced Tailwind support
  {
    "luckasRanarison/tailwind-tools.nvim",
    ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      document_color = {
        enabled = true,
        kind = "inline",
        inline_symbol = "󰝤 ",
        debounce = 200,
      },
      conceal = {
        enabled = false,
      },
      custom_filetypes = {},
    },
  },

  -- SQL completion for Drizzle schema files
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = function(_, opts)
      local cmp = require "cmp"
      
      -- Add SQL completion for .sql and TypeScript files (Drizzle schemas)
      cmp.setup.filetype({ "sql", "mysql", "plsql", "typescript", "typescriptreact" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vim-dadbod-completion" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      return opts
    end,
  },

  -- Drizzle ORM syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "tsx",
        "javascript",
        "json",
        "jsonc",
        "toml",
        "css",
        "html",
        "sql",
      })
      return opts
    end,
  },

  -- Mason package installer
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- TypeScript/JavaScript
        "typescript-language-server",
        "eslint_d",
        "prettier",
        
        -- Tailwind CSS
        "tailwindcss-language-server",
        
        -- JSON/TOML
        "json-lsp",
        "taplo",
        
        -- Formatters
        "prettierd",
        "rustywind", -- Tailwind class sorter
      })
      return opts
    end,
  },
}

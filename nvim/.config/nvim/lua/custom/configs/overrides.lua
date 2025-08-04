local M = {}

-- DEPRECATED: Treesitter config moved to main branch setup
-- This configuration is no longer used with main branch
M.treesitter_legacy = {
  -- This configuration has been replaced by the main branch setup
  -- in nvim-treesitter.lua plugin file
  deprecated = true,
}

M.mason = {
  -- nvim-java registry configuration moved to dependency setup
  ensure_installed = {
    -- LSP servers
    "lua-language-server",    -- Lua LSP
    "stylua",                 -- Lua formatter
    "html-lsp",               -- HTML LSP
    "css-lsp",                -- CSS LSP
    "prettier",               -- Multi-format formatter
    "eslint_d",               -- JS/TS linter
    "emmet-ls",               -- Emmet LSP

    -- JavaScript/TypeScript
    "typescript-language-server", -- TS LSP (fallback for typescript-tools)
    "js-debug-adapter",       -- JS/TS debugger
    "prettier",               -- Multi-format formatter
    "eslint_d",               -- Fast ESLint daemon

    -- Shell scripting
    "bash-language-server",   -- Bash LSP
    "shellcheck",             -- Shell script linter
    "shfmt",                  -- Shell formatter

    -- Go development
    "gopls",                  -- Go language server
    "goimports",              -- Go imports formatter
    "gofumpt",                -- Go formatter (stricter than gofmt)
    "golangci-lint",          -- Go linter
    "gotests",                -- Go test generator
    "impl",                   -- Go interface implementation generator
    "gomodifytags",           -- Go struct tag modifier
    "delve",                  -- Go debugger (Delve)

    -- Java development - let nvim-java handle Java-specific tools
    "jdtls",                  -- Java Language Server
    "java-debug-adapter",     -- Java debugger
    "java-test",              -- Java test runner
    "google-java-format",     -- Java formatter
    "checkstyle",             -- Java style checker
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },

  -- Position NvimTree on the right side
  view = {
    side = "right",
    width = 30,
  },
}

return M

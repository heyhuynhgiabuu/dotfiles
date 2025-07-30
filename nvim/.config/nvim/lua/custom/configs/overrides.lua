local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    -- Temporarily remove Go/Java until query_predicates issues are resolved
    -- "java",
    -- "go", 
    -- "gomod",
    -- "gosum",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = false,
    -- Disable problematic languages
    disable = function(lang, buf)
      local max_filesize = 50 * 1024 -- 50 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      
      -- Disable Go and Java highlighting to prevent query_predicates errors
      if lang == "go" or lang == "java" or lang == "gomod" or lang == "gosum" then
        return true
      end
      
      return false
    end,
  },
  indent = {
    enable = true,
    disable = { "python", "go", "java" }
  },
  -- Sync install to avoid async issues
  sync_install = false,
  auto_install = false,
  -- Ignore problematic parsers
  ignore_install = { "printf", "go", "java", "gomod", "gosum" },
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
    "typescript-language-server", -- TS LSP
    "js-debug-adapter",       -- JS/TS debugger

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

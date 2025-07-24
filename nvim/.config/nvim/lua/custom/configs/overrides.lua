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
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "ts_ls",              -- Updated from typescript-language-server
    "deno",
    "prettier",

    -- c/cpp stuff
    "clangd",
    "clang-format",

    -- Go development - enhanced toolchain
    "gopls",              -- Go language server
    "goimports",          -- Go imports formatter
    "gofumpt",            -- Go formatter (stricter than gofmt)
    "golangci-lint",      -- Go linter
    "gotests",            -- Go test generator
    "impl",               -- Go interface implementation generator
    "gomodifytags",       -- Go struct tag modifier
    "dlv",                -- Go debugger (Delve)

    -- Java development - enhanced toolchain
    "jdtls",              -- Java language server
    "google-java-format", -- Java formatter
    "checkstyle",         -- Java style checker
    "java-debug-adapter", -- Java debug adapter
    "java-test",          -- Java test runner
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
}

return M

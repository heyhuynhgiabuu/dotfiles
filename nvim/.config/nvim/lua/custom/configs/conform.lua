--type conform.options
local options = {
  lsp_fallback = true,

  formatters_by_ft = {
    lua = { "stylua" },

    -- Go
    go = { "goimports", "gofumpt" },

    -- Java
    java = { "google-java-format" },

    -- JavaScript/TypeScript with enhanced formatting
     javascript = { "prettier", "eslint_d" },
     typescript = { "prettier", "eslint_d" },
     javascriptreact = { "prettier", "eslint_d" },
     typescriptreact = { "prettier", "eslint_d" },
     tsx = { "prettier", "eslint_d" },    json = { "prettier" },
    jsonc = { "prettier" },

    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },

    cpp = { "clang_format" },
    c = { "clang_format" },

    sh = { "shfmt" },
  },

  -- adding same formatter for multiple filetypes can look too much work for some
  -- instead of the above code you could just use a loop! the config is just a table after all!

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)

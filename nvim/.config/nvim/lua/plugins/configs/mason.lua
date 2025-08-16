-- Performance optimized Mason configuration with comprehensive tooling
local options = {
  -- Expanded ensure_installed for your development stack
  ensure_installed = {
    -- Language Servers
    "lua-language-server",
    "gopls", 
    "pyright",
    "html-lsp",
    "css-lsp", 
    "clangd",
    "typescript-language-server",
    "json-lsp",
    "yaml-language-server",
    
    -- Formatters
    "stylua",
    "prettier", 
    "gofumpt",
    "goimports",
    "black",
    "isort",
    "clang-format",
    
    -- Linters
    "eslint_d",
    "golangci-lint",
    "flake8",
    "cpplint",
    
    -- Debug Adapters
    "delve",          -- Go debugger
    "debugpy",        -- Python debugger
    "codelldb",       -- C/C++/Rust debugger
  },

  PATH = "skip",

  ui = {
    icons = {
      package_pending = " ",
      package_installed = "󰄳 ",
      package_uninstalled = " 󰚌",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  -- Performance: Increase concurrent installers for faster setup
  max_concurrent_installers = 15,
  
  -- Performance: Install missing tools automatically
  automatic_installation = true,
  
  -- Performance: Check for updates in background
  check_outdated_servers_on_open = false, -- Disable for faster startup
}

return options

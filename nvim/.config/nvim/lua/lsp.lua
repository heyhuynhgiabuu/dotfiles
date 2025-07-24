-- LSP Configurations
local lspconfig = require("lspconfig")

-- Helper: root dir finder
local util = require("lspconfig.util")

-- JAVA LSP (JDTLS)
-- Yêu cầu: brew install jdtls (Java 21+)
local home = os.getenv("HOME")
local jdtls_root = util.root_pattern(".git", "mvnw", "gradlew", "pom.xml")
local java_root = jdtls_root(vim.fn.getcwd())
if java_root then
  local workspace_dir = home .. "/.local/share/jdtls/workspace/" .. vim.fn.fnamemodify(java_root, ":p:h:t")

  require("jdtls").start_or_attach({
    cmd = { "jdtls" },
    root_dir = java_root,
    workspace_folder = workspace_dir,
  })
end

-- LUA LSP (for Neovim config) - DISABLED: Using NvChad LSP setup instead
--[[
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
--]]


-- Custom NvChad configuration theo cách cũ
-- This file integrates your existing configs with NvChad

-- Load filetype detection first (must come before other configs)
require "custom.filetype"

-- Load custom configurations
require "custom.options"
require "custom.mappings"

-- Load DAP (Debug Adapter Protocol) configuration with breakpoint hotkeys
pcall(require, "custom.dap-config")

-- LSP config is now handled in plugins/configs/lspconfig.lua
-- Custom configs can be added there if needed

-- Load optional custom modules with error handling
local optional_modules = {
  "custom.floating-term",
  "custom.help-floating",
  "custom.snipets",
  "custom.vim-helpers",
  "custom.browser-preview",
  "custom.perf-guards", -- performance safeguards for large / long-line files
}

for _, module in ipairs(optional_modules) do
  pcall(require, module)
end

-- Auto resize panes when resizing nvim window
local autocmd = vim.api.nvim_create_autocmd
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

-- Load Vietnamese input method helper if available
local script_path = debug.getinfo(1).source:match("@?(.*/)") or ""
local im_select_helper_path = script_path .. "im_select_helper.lua"
if vim.fn.filereadable(im_select_helper_path) == 1 then
    dofile(im_select_helper_path)
end

-- Add LualineReload command for hot reload
vim.api.nvim_create_user_command("LualineReload", function()
  require("lualine").setup(require("lualine").get_config())
end, {})

-- Custom NvChad configuration theo cách cũ
-- This file integrates your existing configs with NvChad

-- Load custom configurations
require "custom.options"
require "custom.mappings"

-- Load LSP config after plugins are ready
vim.defer_fn(function()
  pcall(require, "custom.lsp-config")
end, 100)

-- Load optional custom modules with error handling
local optional_modules = {
  "custom.floating-term",
  "custom.help-floating",
  "custom.snipets",
  "custom.vim-helpers",
  "custom.browser-preview"
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


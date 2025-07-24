-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- Load custom options
require "custom.options"

-- Load custom keymaps
require "custom.keymaps"

-- Load custom vim helpers
require "custom.vim-helpers"

-- Load floating terminal
require "custom.floating-term"

-- Load help floating
require "custom.help-floating"

-- Load browser preview
require "custom.browser-preview"

-- Load snippets
require "custom.snipets"

-- Load Vietnamese input method helper
local script_path = debug.getinfo(1).source:match("@?(.*/)") or ""
local im_select_helper_path = script_path .. "im_select_helper.lua"
if vim.fn.filereadable(im_select_helper_path) == 1 then
    dofile(im_select_helper_path)
end


-- NvChad core options (minimal)
-- Custom options are handled in custom/options.lua

local opt = vim.opt
local g = vim.g

-- Leader key (set early)
g.mapleader = " "
g.maplocalleader = " "

-- Basic NvChad requirements
opt.laststatus = 3 -- Global statusline
opt.showmode = false

-- Clipboard integration
opt.clipboard = "unnamedplus"

-- Line numbers (minimal, custom/options.lua will override if needed)
opt.number = true
opt.numberwidth = 2
opt.ruler = false

-- Disable nvim intro
opt.shortmess:append "sI"

-- Go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

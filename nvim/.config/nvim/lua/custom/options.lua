-- Custom options that extend/override NvChad core options
-- This file is loaded after lua/options.lua via custom/init.lua

local opt = vim.opt
local o = vim.o
local g = vim.g

-- Leader keys (ensure they're set early)
g.mapleader = ' '
g.maplocalleader = ' '

-------------------------------------- options ------------------------------------------
-- UI enhancements (extends core options)
o.laststatus = 3          -- Global statusline (confirm core setting)
o.showmode = false        -- Don't show mode in command line (confirm core setting)
o.splitkeep = "screen"    -- Keep screen stable when splitting

-- Clipboard and cursor
o.clipboard = "unnamedplus" -- Confirm core setting
o.cursorline = true       -- Highlight current line
o.cursorlineopt = "number" -- Only highlight line number

-- Indenting (keep your preference of 4 spaces)
o.expandtab = true
o.shiftwidth = 4          -- Your preference
o.smartindent = true
o.tabstop = 4             -- Your preference  
o.softtabstop = 4         -- Your preference

-- UI enhancements
opt.fillchars = { eob = " " } -- Remove ~ from empty lines
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
opt.colorcolumn = "80"    -- Keep your column guide

-- Numbers
o.number = true
o.relativenumber = true   -- Keep your relative numbers
o.numberwidth = 2
o.ruler = false

-- Disable nvim intro
opt.shortmess:append "sI"

-- Window behavior
o.signcolumn = "yes"      -- Always show sign column
o.splitbelow = true       -- Horizontal splits go below
o.splitright = true       -- Vertical splits go right
o.timeoutlen = 1000       -- Timeout for which-key (increased from 400)
o.undofile = true         -- Persistent undo

-- Performance
o.updatetime = 250        -- Faster completion and gitsigns

-- Navigation
-- Go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- Disable default providers for better performance
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Add mason binaries to PATH
local is_windows = vim.fn.has "win32" ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- Enable fallback syntax highlighting for languages without treesitter
vim.cmd([[
  augroup FallbackSyntax
    autocmd!
    " Enable vim syntax highlighting for Go files (fallback when treesitter is disabled)
    autocmd FileType go syntax on
    autocmd FileType java syntax on
    " Ensure basic syntax highlighting is available
    autocmd BufRead,BufNewFile *.go setlocal syntax=go
    autocmd BufRead,BufNewFile *.java setlocal syntax=java
  augroup END
]])

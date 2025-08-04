-- 🎓 DAP Help Panel System
-- Comprehensive debugging help and layout information

local M = {}

-- Function to show debug help
local function show_debug_help()
  local config = require("custom.dap.config")
  local help_text = [[
🔛 NVIM-DAP DEBUGGING QUICK REFERENCE (Enhanced Layout)
... (giữ nguyên nội dung help_text) ...
]]
  -- Create a new buffer for help
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(help_text, '\n'))
  vim.api.nvim_set_option_value('filetype', 'help', { buf = buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  
  -- Open in a centered floating window
  local width = config.help_panel.width
  local height = config.help_panel.height
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' 🐛 IntelliJ-like Debug Help ',
    title_pos = 'center'
  })
  
  -- Close with q or Escape
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
end

local function show_layout_info()
  local config = require("custom.dap.config")
  local layout_info = [[
🎨 CURRENT DEBUG UI LAYOUT:
... (giữ nguyên nội dung layout_info) ...
]]
  
  -- Create a new buffer for layout info
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(layout_info, '\n'))
  vim.api.nvim_set_option_value('filetype', 'help', { buf = buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  
  -- Open in a floating window
  local width = config.help_panel.layout_width
  local height = config.help_panel.layout_height
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' 🎨 Enhanced Debug Layout ',
    title_pos = 'center'
  })
  
  -- Close with q or Escape
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
end

function M.setup()
  -- Only define commands (no keymaps, keymaps sẽ lazy load từ keymaps.lua)
  vim.api.nvim_create_user_command('DebugHelp', show_debug_help, { desc = 'Show debugging help for beginners' })
  vim.api.nvim_create_user_command('DebugLayout', show_layout_info, { desc = 'Show current debug layout information' })
  vim.notify("🎓 DAP help panel system configured!", vim.log.levels.INFO)
end

return M
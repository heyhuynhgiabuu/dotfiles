-- 🎨 DAP UI Configuration
-- Enhanced debug interface with IntelliJ-like layout

local M = {}

function M.setup(_dap)
  -- Set up DAP UI if available
  local dapui_ok, dapui = pcall(require, "dapui")
  if not dapui_ok then
    vim.notify("⚠️  DAP UI not available", vim.log.levels.WARN)
    return
  end

  -- Configure DAP UI with enhanced layout and visible labels
local config = require("custom.dap.config")
dapui.setup({
    icons = config.dapui_icons,
    mappings = {
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    -- Expand lines larger than the window
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    layouts = config.dapui_layouts,
    controls = {
      enabled = true,
      element = "console",
      icons = config.dapui_control_icons,
    },
    -- floating, windows, render giữ nguyên

    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = "rounded", -- Rounded border like modern IDEs
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { 
      indent = 1 
    },
    render = {
      max_type_length = nil, -- Don't truncate types
      max_value_lines = 100, -- Show more value lines
      indent = 1,
    }
  })

  -- Add keymaps for DAP UI
  vim.keymap.set("n", "<Leader>du", function()
    dapui.toggle()
    vim.notify("🎨 Enhanced Debug UI toggled (5-panel sidebar + full console)", vim.log.levels.INFO)
  end, { desc = "Toggle Debug UI" })

  -- F4 for quick Debug UI toggle (like IDE panels)
  vim.keymap.set("n", "<F4>", function()
    dapui.toggle()
    vim.notify("🎨 Enhanced Debug UI toggled (F4)", vim.log.levels.INFO)
  end, { desc = "Toggle Debug UI (F4)" })

  vim.keymap.set("n", "<Leader>dE", function()
    dapui.eval()
    vim.notify("🔍 Evaluating expression under cursor", vim.log.levels.INFO)
  end, { desc = "Evaluate expression (DAP UI)" })

  vim.keymap.set("v", "<Leader>dE", function()
    dapui.eval()
    vim.notify("🔍 Evaluating selected text", vim.log.levels.INFO)
  end, { desc = "Evaluate selection (DAP UI)" })

  -- Set up DAP Virtual Text if available (shows variable values inline)
  local virtual_text_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
  if virtual_text_ok then
    virtual_text.setup({
      enabled = true,                     -- enable this plugin (the default)
      enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true,            -- show stop reason when stopped for exceptions
      commented = false,                  -- prefix virtual text with comment string
      only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
      all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
      clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
      -- Position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
      virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
      -- Experimental features:
      all_frames = false,                 -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false,                 -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil             -- position the virtual text at a fixed window column (starting from the first text column) ,
                                          -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    })
    vim.notify("✨ DAP Virtual Text configured - variable values will show inline!", vim.log.levels.INFO)
  end

  -- Enhanced panel identification system
  local config = require("custom.dap.config")
  local function get_panel_description(buffer_name)
    return config.panel_map[buffer_name] or buffer_name
  end

  -- Enhanced panel identification command
  vim.api.nvim_create_user_command('DapIdentifyPanel', function()
    local current_buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    local buf_type = vim.api.nvim_buf_get_option(current_buf, 'filetype')
    
    -- Extract just the buffer name
    local clean_name = vim.fn.fnamemodify(buf_name, ':t')
    if clean_name == '' then
      clean_name = vim.api.nvim_buf_get_option(current_buf, 'buftype')
    end
    
    local description = get_panel_description(clean_name)
    vim.notify("Current panel: " .. description, vim.log.levels.INFO)
  end, { desc = 'Identify current DAP panel' })

  -- Keymap to identify current panel
  vim.keymap.set("n", "<Leader>dI", function()
    vim.cmd("DapIdentifyPanel")
  end, { desc = "Identify current DAP panel" })

  vim.notify("🎨 DAP UI configured with enhanced layout!", vim.log.levels.INFO)
end

return M
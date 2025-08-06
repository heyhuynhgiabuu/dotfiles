-- 🎯 DAP Keymaps Configuration
-- Complete debugging keybindings with error handling

local M = {}

function M.setup()
  -- ========================
  -- 🎯 BREAKPOINT HOTKEYS (Main debugging controls)
  -- ========================

  -- These are the most important hotkeys for debugging - memorize these first!

  -- 🔴 BREAKPOINTS (Toggle breakpoints = pause points in your code)
  vim.keymap.set("n", "<Leader>db", function() 
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      -- [REMOVED] vim.notify(..., vim.log.levels.INFO)
    end
  end, { desc = "Evaluate Expression" })

  -- Lazy load help panel on demand
  vim.keymap.set("n", "<Leader>d?", function()
    local ok, help_panel = pcall(require, "custom.dap.help_panel")
    if ok and help_panel.setup then
      help_panel.setup()
    else
      vim.notify("❌ Debug Help Panel module not available", vim.log.levels.ERROR)
    end
  end, { desc = "Show Debug Help (lazy load)" })

  vim.keymap.set("n", "<Leader>dL", function()
    local ok, help_panel = pcall(require, "custom.dap.help_panel")
    if ok and help_panel.setup then
      vim.cmd("DebugLayout")
    else
      vim.notify("❌ Debug Layout Info module not available", vim.log.levels.ERROR)
    end
  end, { desc = "Show Debug Layout Info (lazy load)" })

end

return M
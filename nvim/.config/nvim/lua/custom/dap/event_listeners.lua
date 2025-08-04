-- 🔧 DAP Event Listeners
-- Automatic UI management during debugging sessions

local M = {}

function M.setup(dap)
  if not dap then
    vim.notify("❌ DAP not available for event listeners", vim.log.levels.ERROR)
    return
  end

  local dapui_ok, dapui = pcall(require, "dapui")
  if not dapui_ok then
    vim.notify("⚠️  DAP UI not available for event listeners", vim.log.levels.WARN)
    return
  end

  -- Automatically open DAP UI when debugging starts
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
    vim.notify("🐛 Debug session started - Enhanced UI opened! (5-panel sidebar + full console)", vim.log.levels.INFO)
  end

  -- Automatically close DAP UI when debugging ends
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
    vim.notify("🏁 Debug session ended - Enhanced UI closed", vim.log.levels.INFO)
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
    vim.notify("🚪 Debug session exited - Enhanced UI closed", vim.log.levels.INFO)
  end

  vim.notify("🔧 DAP event listeners configured!", vim.log.levels.INFO)
end

return M
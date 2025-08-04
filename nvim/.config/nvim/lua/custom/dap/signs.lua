-- 🎨 DAP Signs Configuration
-- Visual indicators for breakpoints and debug states

local M = {}

function M.setup()
  -- Configure breakpoint signs (visual indicators in the gutter)
  local config = require("custom.dap.config")
  vim.fn.sign_define('DapBreakpoint', config.signs.breakpoint)
  vim.fn.sign_define('DapBreakpointCondition', config.signs.breakpoint_condition)
  vim.fn.sign_define('DapStopped', config.signs.stopped)
  vim.fn.sign_define('DapLogPoint', config.signs.logpoint)

  vim.notify("🎨 DAP signs configured successfully!", vim.log.levels.INFO)
end

return M
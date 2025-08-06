-- 🎨 DAP UI Configuration
-- Enhanced debug interface with IntelliJ-like layout

local M = {}

function M.setup(_dap)
  -- Set up DAP UI if available
  local dapui_ok = pcall(require, "dapui")
if not dapui_ok then
  -- [REMOVED] vim.notify(..., vim.log.levels.INFO)
  return
end
  -- Keymap to identify current panel
  vim.keymap.set("n", "<Leader>dI", function()
    vim.cmd("DapIdentifyPanel")
  end, { desc = "Identify current DAP panel" })

end

return M
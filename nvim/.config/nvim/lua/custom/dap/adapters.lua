-- 🚀 DAP Adapters Configuration
-- Load and setup debug adapters for various languages

local M = {}

function M.setup()
  -- Load comprehensive debug adapters (Java, Go, Node.js, Python)
  local adapters_ok, debug_adapters = pcall(require, "custom.debug-adapters")
  if adapters_ok then
    debug_adapters.setup()
    vim.notify("🚀 All debug adapters loaded successfully!", vim.log.levels.INFO)
  else
    vim.notify("⚠️  Debug adapters module not found - using basic configuration", vim.log.levels.WARN)
  end
end

return M
-- 🐛 nvim-dap (Debug Adapter Protocol) Configuration - REFACTORED
-- Modular debugging setup with clean separation of concerns
-- This file now acts as a loader for all DAP modules

-- Try to load DAP and configure
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  -- DAP is available, set up everything in modular fashion
  local modules = {
    "custom.dap.keymaps",      -- Keybindings must be loaded first
    "custom.dap.signs",        -- Visual indicators  
    "custom.dap.adapters",     -- Debug adapters for languages
    "custom.dap.ui",           -- Enhanced UI configuration
    "custom.dap.event_listeners", -- Auto UI management
    "custom.dap.helpers"      -- Helper commands (help panel sẽ lazy load)
    -- "custom.dap.help_panel" -- Help system (đã chuyển sang lazy load)
  }

  for _, module_name in ipairs(modules) do
    local ok, module = pcall(require, module_name)
    if ok then
      module.setup(dap) -- Pass dap instance to modules that need it
    end
  end
  return dap
else
  -- DAP chưa sẵn sàng, setup keymaps tối thiểu
  local keymaps_ok, keymaps = pcall(require, "custom.dap.keymaps")
  if keymaps_ok then
    keymaps.setup()
  end

  -- Deferred setup khi DAP đã sẵn sàng
  vim.defer_fn(function()
    local deferred_ok = pcall(require, "dap")
    if deferred_ok then
      dofile(debug.getinfo(1).source:match("@?(.*)"))
    end
  end, 500)
end

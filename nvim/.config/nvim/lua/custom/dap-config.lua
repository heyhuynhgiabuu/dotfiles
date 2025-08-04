-- 🐛 nvim-dap (Debug Adapter Protocol) Configuration - REFACTORED
-- Modular debugging setup with clean separation of concerns
-- This file now acts as a loader for all DAP modules

-- Try to load DAP and configure
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  -- DAP is available, set up everything in modular fashion
  
  -- Load and setup all DAP modules in proper order
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
      vim.notify("✅ Loaded: " .. module_name, vim.log.levels.DEBUG)
    else
      vim.notify("❌ Failed to load: " .. module_name .. " - " .. module, vim.log.levels.ERROR)
    end
  end

  vim.notify("🐛 Enhanced debugging configured! Use <Leader>d? for help, <Leader>dL for layout info", vim.log.levels.INFO)

  -- Return the dap module for other configurations to use
  return dap
else
  -- DAP not available yet, set up minimal keymaps that will work when it loads
  local keymaps_ok, keymaps = pcall(require, "custom.dap.keymaps")
  if keymaps_ok then
    keymaps.setup()
  end
  
  -- Defer full setup
  vim.defer_fn(function()
    local deferred_ok, deferred_dap = pcall(require, "dap")
    if deferred_ok then
      vim.notify("🐛 nvim-dap loaded (deferred) - full setup complete", vim.log.levels.INFO)
      -- Re-source this file to get full setup
      dofile(debug.getinfo(1).source:match("@?(.*)"))
    else
      vim.notify("❌ nvim-dap still not available after deferring", vim.log.levels.WARN)
    end
  end, 500)
  
  vim.notify("🐛 DAP keymaps set up, waiting for nvim-dap to load...", vim.log.levels.INFO)
end
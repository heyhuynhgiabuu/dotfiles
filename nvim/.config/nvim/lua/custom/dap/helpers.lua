-- 📚 DAP Helper Commands and Functions
-- Utility commands for easier debugging access

local M = {}

function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    vim.notify("⚠️  DAP not available for helper commands", vim.log.levels.WARN)
    return
  end

  -- Create user commands for easier access
  vim.api.nvim_create_user_command('DapToggleBreakpoint', function()
    dap.toggle_breakpoint()
  end, { desc = 'Toggle breakpoint at current line' })

  vim.api.nvim_create_user_command('DapContinue', function()
    dap.continue()
  end, { desc = 'Start or continue debugging' })

  vim.api.nvim_create_user_command('DapStepOver', function()
    dap.step_over()
  end, { desc = 'Step over current line' })

  vim.api.nvim_create_user_command('DapStepInto', function()
    dap.step_into()
  end, { desc = 'Step into function call' })

  vim.api.nvim_create_user_command('DapStepOut', function()
    dap.step_out()
  end, { desc = 'Step out of current function' })

  vim.api.nvim_create_user_command('DapTerminate', function()
    dap.terminate()
  end, { desc = 'Terminate debug session' })

  vim.api.nvim_create_user_command('DapRepl', function()
    dap.repl.open()
  end, { desc = 'Open debug REPL' })

end

return M
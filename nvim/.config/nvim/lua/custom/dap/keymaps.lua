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
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.toggle_breakpoint()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.notify("🔴 Breakpoint toggled on line " .. line, vim.log.levels.INFO)
  end, { desc = "Toggle Breakpoint (Primary)" })

  -- Alternative breakpoint key (F9 is common in many IDEs)
  vim.keymap.set("n", "<F9>", function() 
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.toggle_breakpoint()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.notify("🔴 Breakpoint toggled on line " .. line, vim.log.levels.INFO)
  end, { desc = "Toggle Breakpoint (F9)" })

  -- 🟡 CONDITIONAL BREAKPOINTS (Advanced: break only when condition is true)
  vim.keymap.set("n", "<Leader>dB", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    local condition = vim.fn.input("Breakpoint condition: ")
    if condition ~= "" then
      dap.set_breakpoint(condition)
      vim.notify("🟡 Conditional breakpoint set: " .. condition, vim.log.levels.INFO)
    end
  end, { desc = "Set Conditional Breakpoint" })

  -- 🧹 CLEAR ALL BREAKPOINTS
  vim.keymap.set("n", "<Leader>dC", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.clear_breakpoints()
    vim.notify("🧹 All breakpoints cleared", vim.log.levels.INFO)
  end, { desc = "Clear All Breakpoints" })

  -- ========================
  -- 🎮 DEBUGGING CONTROLS (Step through your code)
  -- ========================

  -- ▶️  START/CONTINUE DEBUGGING (Most important - starts or continues debugging)
  vim.keymap.set("n", "<F5>", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.continue()
    vim.notify("▶️  Starting/Continuing debugger...", vim.log.levels.INFO)
  end, { desc = "Start/Continue Debug (F5)" })

  vim.keymap.set("n", "<Leader>dc", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.continue()
    vim.notify("▶️  Starting/Continuing debugger...", vim.log.levels.INFO)
  end, { desc = "Start/Continue Debug" })

  -- ⏹️  STOP DEBUGGING
  vim.keymap.set("n", "<F17>", function() -- Shift+F5
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.terminate()
    vim.notify("⏹️  Debug session terminated", vim.log.levels.INFO)
  end, { desc = "Stop Debug (Shift+F5)" })

  vim.keymap.set("n", "<Leader>dt", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.terminate()
    vim.notify("⏹️  Debug session terminated", vim.log.levels.INFO)
  end, { desc = "Terminate Debug Session" })

  -- 🔄 RESTART DEBUGGING
  vim.keymap.set("n", "<F29>", function() -- Ctrl+F5  
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.restart()
    vim.notify("🔄 Restarting debugger...", vim.log.levels.INFO)
  end, { desc = "Restart Debug (Ctrl+F5)" })

  vim.keymap.set("n", "<Leader>dr", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.restart()
    vim.notify("🔄 Restarting debugger...", vim.log.levels.INFO)
  end, { desc = "Restart Debug Session" })

  -- ========================
  -- 👣 STEPPING CONTROLS (Navigate through code line by line)
  -- ========================

  -- ⬇️  STEP OVER (Execute current line, don't go into functions)
  vim.keymap.set("n", "<F10>", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_over()
    vim.notify("⬇️  Step Over", vim.log.levels.INFO)
  end, { desc = "Step Over (F10)" })

  vim.keymap.set("n", "<Leader>so", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_over()
    vim.notify("⬇️  Step Over", vim.log.levels.INFO)
  end, { desc = "Step Over" })

  -- ➡️  STEP INTO (Go inside function calls)
  vim.keymap.set("n", "<F11>", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_into()
    vim.notify("➡️  Step Into", vim.log.levels.INFO)
  end, { desc = "Step Into (F11)" })

  vim.keymap.set("n", "<Leader>si", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_into()
    vim.notify("➡️  Step Into", vim.log.levels.INFO)
  end, { desc = "Step Into" })

  -- ⬅️  STEP OUT (Exit current function and return to caller)
  vim.keymap.set("n", "<F23>", function() -- Shift+F11
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_out()
    vim.notify("⬅️  Step Out", vim.log.levels.INFO)
  end, { desc = "Step Out (Shift+F11)" })

  vim.keymap.set("n", "<Leader>su", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.step_out()
    vim.notify("⬅️  Step Out", vim.log.levels.INFO)
  end, { desc = "Step Out" })

  -- ⏸️  PAUSE (Pause execution)
  vim.keymap.set("n", "<F6>", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.pause()
    vim.notify("⏸️  Execution paused", vim.log.levels.INFO)
  end, { desc = "Pause Debug (F6)" })

  -- ========================
  -- 🔍 INSPECTION TOOLS (Look at variables and data)
  -- ========================

  -- 💬 OPEN DEBUG REPL (Interactive console to evaluate expressions)
  vim.keymap.set("n", "<Leader>dR", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    dap.repl.open()
    vim.notify("💬 Debug REPL opened - type expressions to evaluate them", vim.log.levels.INFO)
  end, { desc = "Open Debug REPL" })

  -- 📋 SHOW SCOPES (View all variables in current scope)
  vim.keymap.set("n", "<Leader>ds", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    local widgets_ok, widgets = pcall(require, 'dap.ui.widgets')
    if not widgets_ok then
      vim.notify("❌ dap.ui.widgets not available", vim.log.levels.ERROR)
      return
    end
    widgets.centered_float(widgets.scopes)
    vim.notify("📋 Showing current scopes", vim.log.levels.INFO)
  end, { desc = "Show Scopes" })

  -- 📊 SHOW FRAMES (View call stack)
  vim.keymap.set("n", "<Leader>df", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    local widgets_ok, widgets = pcall(require, 'dap.ui.widgets')
    if not widgets_ok then
      vim.notify("❌ dap.ui.widgets not available", vim.log.levels.ERROR)
      return
    end
    widgets.centered_float(widgets.frames)
    vim.notify("📊 Showing call frames", vim.log.levels.INFO)
  end, { desc = "Show Frames" })

  -- 🧵 SHOW THREADS (View all execution threads)
  vim.keymap.set("n", "<Leader>dh", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    local widgets_ok, widgets = pcall(require, 'dap.ui.widgets')
    if not widgets_ok then
      vim.notify("❌ dap.ui.widgets not available", vim.log.levels.ERROR)
      return
    end
    widgets.centered_float(widgets.threads)
    vim.notify("🧵 Showing threads", vim.log.levels.INFO)
  end, { desc = "Show Threads" })

  -- 🔍 HOVER EVALUATION (Evaluate expression under cursor - IntelliJ style)
  vim.keymap.set("n", "<Leader>dv", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    
    -- Try DAP UI first (better interface)
    local dapui_ok, dapui = pcall(require, "dapui")
    if dapui_ok then
      dapui.eval()
      vim.notify("🔍 Evaluating with DAP UI", vim.log.levels.INFO)
    else
      -- Fallback to basic widgets
      local widgets_ok, widgets = pcall(require, 'dap.ui.widgets')
      if not widgets_ok then
        vim.notify("❌ dap.ui.widgets not available", vim.log.levels.ERROR)
        return
      end
      widgets.hover()
      vim.notify("🔍 Hover evaluation", vim.log.levels.INFO)
    end
  end, { desc = "Debug Hover/Evaluate" })

  -- Visual mode evaluation (select text and evaluate - like IntelliJ)
  vim.keymap.set("v", "<Leader>dv", function()
    local dapui_ok, dapui = pcall(require, "dapui")
    if dapui_ok then
      dapui.eval()
      vim.notify("🔍 Evaluating selected expression", vim.log.levels.INFO)
    else
      vim.notify("❌ DAP UI not available for selection evaluation", vim.log.levels.ERROR)
    end
  end, { desc = "Debug Evaluate Selection" })

  -- Quick variable inspection (like IntelliJ's Alt+F8)
  vim.keymap.set("n", "<Leader>di", function()
    local dapui_ok, dapui = pcall(require, "dapui")
    if dapui_ok then
      dapui.eval(vim.fn.input("Quick evaluate: "))
    else
      local dap_ok, dap = pcall(require, "dap")
      if dap_ok then
        local expr = vim.fn.input("Evaluate expression: ")
        if expr ~= "" then
          dap.eval(expr)
          vim.notify("📝 Evaluating: " .. expr, vim.log.levels.INFO)
        end
      end
    end
  end, { desc = "Quick Inspect (like IntelliJ Alt+F8)" })

  -- 📝 EVALUATE EXPRESSION (Manually evaluate any expression)
  vim.keymap.set("n", "<Leader>de", function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    local expr = vim.fn.input("Evaluate expression: ")
    if expr ~= "" then
      dap.eval(expr)
      vim.notify("📝 Evaluating: " .. expr, vim.log.levels.INFO)
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

  vim.notify("🐛 DAP keymaps configured successfully!", vim.log.levels.INFO)
end

return M
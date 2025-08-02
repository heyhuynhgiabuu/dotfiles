-- 🐛 nvim-dap (Debug Adapter Protocol) Configuration
-- Complete debugging setup with breakpoint hotkeys for beginners
-- This file configures debugging for Java and other languages

-- Function to set up DAP keymaps
local function setup_dap_keymaps()
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

  vim.notify("🐛 DAP keymaps configured successfully!", vim.log.levels.INFO)
end

-- Try to load DAP and configure
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  -- DAP is available, set up everything
  setup_dap_keymaps()
  
  -- ========================
  -- 🚀 LOAD DEBUG ADAPTERS
  -- ========================
  
  -- Load comprehensive debug adapters (Java, Go, Node.js, Python)
  local adapters_ok, debug_adapters = pcall(require, "custom.debug-adapters")
  if adapters_ok then
    debug_adapters.setup()
    vim.notify("🚀 All debug adapters loaded successfully!", vim.log.levels.INFO)
  else
    vim.notify("⚠️  Debug adapters module not found - using basic configuration", vim.log.levels.WARN)
  end
  
  -- ========================
  -- 🎨 DEBUGGING SIGNS AND UI
  -- ========================

  -- Configure breakpoint signs (visual indicators in the gutter)
  vim.fn.sign_define('DapBreakpoint', {
    text = '🔴',  -- Red circle for breakpoints
    texthl = 'DiagnosticSignError',
    linehl = '',
    numhl = ''
  })

  vim.fn.sign_define('DapBreakpointCondition', {
    text = '🟡',  -- Yellow circle for conditional breakpoints
    texthl = 'DiagnosticSignWarn',
    linehl = '',
    numhl = ''
  })

  vim.fn.sign_define('DapStopped', {
    text = '▶️',  -- Arrow for current execution line
    texthl = 'DiagnosticSignInfo',
    linehl = 'Visual',
    numhl = 'DiagnosticSignInfo'
  })

  vim.fn.sign_define('DapLogPoint', {
    text = '📝',  -- Note for log points
    texthl = 'DiagnosticSignInfo',
    linehl = '',
    numhl = ''
  })

  -- ========================
  -- 🎨 DAP UI INTEGRATION (IntelliJ-like debug interface)
  -- ========================

  -- Set up DAP UI if available
  local dapui_ok, dapui = pcall(require, "dapui")
  if dapui_ok then
    -- Configure DAP UI with enhanced layout and visible labels
    dapui.setup({
      icons = { 
        expanded = "▾", 
        collapsed = "▸", 
        current_frame = "▸" 
      },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      -- Expand lines larger than the window
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      layouts = {
        {
          -- 📋 Left sidebar - All debug panels with clear organization
          elements = {
            -- 🔍 Variables/Scopes at top (most important for debugging)
            { id = "scopes", size = 0.25 },
            -- 📊 Call stack next (shows execution flow)  
            { id = "stacks", size = 0.25 },
            -- 🔴 Breakpoints (manage pause points)
            { id = "breakpoints", size = 0.20 },
            -- 👁️  Watches (custom expressions to monitor)
            { id = "watches", size = 0.15 },
            -- 🎮 Console (with debug controls in sidebar)
            { id = "console", size = 0.15 },
          },
          size = 55, -- Wider sidebar to accommodate 5 panels
          position = "left",
        },
        {
          -- 📺 Bottom - Full REPL area (logs and output with maximum space)
          elements = {
            -- 📋 REPL gets the entire bottom area for logs and output
            { id = "repl", size = 1.0 },
          },
          size = 15, -- Taller REPL for better log visibility
          position = "bottom",
        },
      },
      controls = {
        -- Enable the controls (play, pause, step buttons) like in video
        enabled = true,
        -- Display controls in console area
        element = "console",
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
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
  end

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

  -- ========================
  -- 🏷️  ENHANCED PANEL IDENTIFICATION
  -- ========================

  -- Since DAP-UI hardcodes panel titles, we'll enhance the help system
  -- and create a mapping function to help users identify panels
  local function get_panel_description(buffer_name)
    local panel_map = {
      ["DAP Scopes"] = "🔍 Variables/Scopes - Current variable values and scope information",
      ["DAP Stacks"] = "📊 Call Stack - Function call hierarchy and execution flow",
      ["DAP Breakpoints"] = "🔴 Breakpoints - Manage pause points in your code",
      ["DAP Watches"] = "👁️  Watches - Custom expressions to monitor during debugging", 
      ["DAP Console"] = "🎮 Console - Debug controls and command interface (in sidebar)",
      ["dap-repl"] = "📋 REPL - Logs, output, and interactive debugging (full bottom)"
    }
    return panel_map[buffer_name] or buffer_name
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

  -- ========================
  -- 🔧 DAP EVENT LISTENERS (Automatic UI management)
  -- ========================

  -- Automatically open DAP UI when debugging starts
  dap.listeners.after.event_initialized["dapui_config"] = function()
    if dapui_ok then
      dapui.open()
    end
    vim.notify("🐛 Debug session started - Enhanced UI opened! (5-panel sidebar + full console)", vim.log.levels.INFO)
  end

  -- Automatically close DAP UI when debugging ends
  dap.listeners.before.event_terminated["dapui_config"] = function()
    if dapui_ok then
      dapui.close()
    end
    vim.notify("🏁 Debug session ended - Enhanced UI closed", vim.log.levels.INFO)
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    if dapui_ok then
      dapui.close()
    end
    vim.notify("🚪 Debug session exited - Enhanced UI closed", vim.log.levels.INFO)
  end

  -- ========================
  -- 📚 HELPFUL COMMANDS AND FUNCTIONS
  -- ========================

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

  -- ========================
  -- 🎓 BEGINNER HELPER FUNCTION
  -- ========================

  -- Function to show debug help
  local function show_debug_help()
    local help_text = [[
🐛 NVIM-DAP DEBUGGING QUICK REFERENCE (Enhanced Layout)

🎨 ENHANCED DEBUG UI LAYOUT:
  📋 LEFT SIDEBAR (5 Panels):
    DAP Scopes      → 🔍 Variables/Scopes (current variable values)
    DAP Stacks      → 📊 Call Stack (function call hierarchy)  
    DAP Breakpoints → 🔴 Breakpoints (manage pause points)
    DAP Watches     → 👁️  Watches (custom expressions)
    DAP Console     → 🎮 Console (debug controls interface)

  📺 BOTTOM AREA:
    [dap-repl]      → 📋 REPL (logs, output, interactive debugging)

📝 CONSOLE vs REPL EXPLAINED:
  🎮 Console (sidebar)  → Debug controls & command interface  
  📋 REPL (bottom)      → Logs, output & interactive debugging

🔴 BREAKPOINTS (Pause execution):
  <Leader>db or  F9      → Toggle breakpoint on current line
  <Leader>dB             → Set conditional breakpoint
  <Leader>dC             → Clear all breakpoints

▶️  DEBUGGING CONTROLS:
  F5                     → Start/Continue debugging
  Shift+F5               → Stop debugging  
  Ctrl+F5                → Restart debugging

👣 STEPPING (Navigate through code):
  F10                    → Step Over (don't enter functions)
  F11                    → Step Into (enter functions)
  Shift+F11              → Step Out (exit current function)
  F6                     → Pause execution

🎨 DEBUG UI (Enhanced Layout):
  <Leader>du or F4       → Toggle Debug UI panels
  Auto-opens when debugging starts!
  - Left panel: 5 stacked debug windows with labels
  - Bottom: Full-width console for maximum output space

🔍 INSPECTION (View data - Enhanced workflow):
  <Leader>dv             → Evaluate expression under cursor (hover)
  <Leader>dv (visual)    → Evaluate selected text
  <Leader>di             → Quick inspect expression (like Alt+F8)
  <Leader>dI             → Identify current DAP panel (NEW!)
  <Leader>dE             → DAP UI evaluate under cursor
  <Leader>dR             → Open REPL for logs and interactive debugging
  <Leader>ds             → Show variables in current scope
  <Leader>df             → Show call stack (frames)
  <Leader>de             → Evaluate custom expression

✨ ENHANCED FEATURES:
  • Variable values shown inline (next to code)
  • Debug UI opens/closes automatically
  • Visual breakpoint indicators  
  • REPL moved to sidebar for better workflow
  • Console gets full bottom space for output
  • 5-panel left sidebar for complete debug info

🎯 ENHANCED WORKFLOW:
1. Set breakpoints with <Leader>db on lines you want to pause
2. Start debugging with F5 (enhanced UI opens automatically)
3. Use the 5-panel sidebar:
   - DAP Scopes: See current variable values
   - DAP Stacks: Navigate call hierarchy
   - DAP Breakpoints: Manage pause points
   - DAP Watches: Monitor custom expressions
   - DAP Console: Debug controls (play/pause/step buttons)
4. Full-width REPL at bottom shows logs, output, and interactive debugging
5. Use <Leader>dv to inspect variables under cursor
6. Use F10 to step through line by line
7. Use F5 to continue to next breakpoint
8. Use Shift+F5 to stop (UI closes automatically)

💡 TIP: Use <Leader>dI to identify the current panel you're in!
       Console (sidebar) = Debug controls with buttons
       REPL (bottom) = Logs, output & interactive debugging
]]    
    -- Create a new buffer for help
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(help_text, '\n'))
    vim.api.nvim_set_option_value('filetype', 'help', { buf = buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    
    -- Open in a centered floating window
    local width = 90
    local height = 45
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = 'minimal',
      border = 'rounded',
      title = ' 🐛 IntelliJ-like Debug Help ',
      title_pos = 'center'
    })
    
    -- Close with q or Escape
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
  end

  -- Command to show debug help
  vim.api.nvim_create_user_command('DebugHelp', show_debug_help, { desc = 'Show debugging help for beginners' })

  -- Enhanced user command to show current layout info
  vim.api.nvim_create_user_command('DebugLayout', function()
    local layout_info = [[
🎨 CURRENT DEBUG UI LAYOUT:

📋 LEFT SIDEBAR (Width: 55 columns):
  DAP Scopes      (25%) → 🔍 Current variable values and scope
  DAP Stacks      (25%) → 📊 Function call hierarchy  
  DAP Breakpoints (20%) → 🔴 Manage pause points
  DAP Watches     (15%) → 👁️  Custom expressions to monitor
  DAP Console     (15%) → 🎮 Debug controls & interface

📺 BOTTOM AREA (Height: 15 lines):
  [dap-repl]     (100%) → 📋 Logs, output & interactive debugging

🎯 KEY DIFFERENCES:
• Console (sidebar): Debug controls with play/pause/step buttons
• REPL (bottom): Full-width logs, output, and interactive debugging

🎯 KEY IMPROVEMENTS:
• REPL moved to sidebar for easier access
• Console gets full bottom width for maximum output space
• 5-panel sidebar provides complete debug information
• Wider sidebar (55 vs 50 cols) for better readability
• Taller console (15 vs 12 lines) for more output

Toggle with F4 or <Leader>du
]]
    
    -- Create a new buffer for layout info
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(layout_info, '\n'))
    vim.api.nvim_set_option_value('filetype', 'help', { buf = buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    
    -- Open in a floating window
    local width = 70
    local height = 25
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = 'minimal',
      border = 'rounded',
      title = ' 🎨 Enhanced Debug Layout ',
      title_pos = 'center'
    })
    
    -- Close with q or Escape
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
  end, { desc = 'Show current debug layout information' })

  -- Command to show debug help
  vim.api.nvim_create_user_command('DebugHelp', show_debug_help, { desc = 'Show debugging help for beginners' })

  -- Keymap to show debug help (use different key to avoid conflict with threads)
  vim.keymap.set("n", "<Leader>d?", show_debug_help, { desc = "Show Debug Help" })

  -- Keymap to show current layout info
  vim.keymap.set("n", "<Leader>dL", function()
    vim.cmd("DebugLayout")
  end, { desc = "Show Enhanced Debug Layout Info" })

  vim.notify("🐛 Enhanced debugging configured! Use <Leader>d? for help, <Leader>dL for layout info", vim.log.levels.INFO)

  -- Return the dap module for other configurations to use
  return dap
else
  -- DAP not available yet, just set up the keymaps that will work when it loads
  setup_dap_keymaps()
  
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
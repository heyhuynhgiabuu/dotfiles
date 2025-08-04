-- 🛠️ DAP Shared Config & Constants
-- Tất cả các hằng số/cấu hình dùng chung cho các module DAP

local M = {}

-- DAP UI Layout
M.dapui_layouts = {
  {
    elements = {
      { id = "scopes", size = 0.25 },
      { id = "stacks", size = 0.25 },
      { id = "breakpoints", size = 0.20 },
      { id = "watches", size = 0.15 },
      { id = "console", size = 0.15 },
    },
    size = 55,
    position = "left",
  },
  {
    elements = {
      { id = "repl", size = 1.0 },
    },
    size = 15,
    position = "bottom",
  },
}

-- DAP UI Icons
M.dapui_icons = {
  expanded = "▼",
  collapsed = "▷",
  current_frame = "▷"
}

-- DAP UI Controls Icons
M.dapui_control_icons = {
  pause = "⏸",
  play = "▶",
  step_into = "⏎",
  step_over = "⏭",
  step_out = "⏮",
  step_back = "b",
  run_last = "▶▶",
  terminate = "⏹",
  disconnect = "⏏",
}

-- DAP Signs
M.signs = {
  breakpoint = { text = '🔴', texthl = 'DiagnosticSignError' },
  breakpoint_condition = { text = '🟡', texthl = 'DiagnosticSignWarn' },
  stopped = { text = '▶️', texthl = 'DiagnosticSignInfo', linehl = 'Visual', numhl = 'DiagnosticSignInfo' },
  logpoint = { text = '📝', texthl = 'DiagnosticSignInfo' },
}

-- Help panel window size
M.help_panel = {
  width = 90,
  height = 45,
  layout_width = 70,
  layout_height = 25,
}

-- Panel description map
M.panel_map = {
  ["DAP Scopes"] = "🔍 Variables/Scopes - Current variable values and scope information",
  ["DAP Stacks"] = "📊 Call Stack - Function call hierarchy and execution flow",
  ["DAP Breakpoints"] = "🔴 Breakpoints - Manage pause points in your code",
  ["DAP Watches"] = "👁️  Watches - Custom expressions to monitor during debugging", 
  ["DAP Console"] = "🎮 Console - Debug controls and command interface (in sidebar)",
  ["dap-repl"] = "📋 REPL - Logs, output, and interactive debugging (full bottom)"
}

return M

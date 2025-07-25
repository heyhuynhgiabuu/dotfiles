local wezterm = require 'wezterm'
local config = {}

-- Sử dụng config builder cho compatibility
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- === THEME & APPEARANCE ===
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 15.0
config.window_background_opacity = 0.85
config.macos_window_background_blur = 25

-- === WINDOW SETTINGS ===
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'
config.quit_when_all_windows_are_closed = true

-- === PERFORMANCE ===
config.max_fps = 120
config.scrollback_lines = 5000  -- Lower for memory usage

-- === KEYBINDINGS ESSENTIALS ===
config.keys = {
  -- === DELETE KEYBINDINGS (Best Practice, all Backspace-based) ===
  -- Shift+Backspace: delete to beginning of line (send Ctrl+U)
  {
    key = 'Backspace',
    mods = 'SHIFT',
    action = wezterm.action.SendKey { key = 'u', mods = 'CTRL' },
  },
  -- Cmd+Backspace: delete to end of line (send Ctrl+K)
  {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action.SendKey { key = 'k', mods = 'CTRL' },
  },
  -- Alt+Backspace: delete previous word (send Ctrl+W)
  {
    key = 'Backspace',
    mods = 'ALT',
    action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' },
  },
  -- Cmd+Alt+Backspace: delete next word (send Alt+D)
  {
    key = 'Backspace',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SendKey { key = 'd', mods = 'ALT' },
  },

  -- Split panes
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Navigate panes
  { key = 'LeftArrow', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Down' },

  -- Close pane
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },

  -- New tab/window
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'CMD', action = wezterm.action.SpawnWindow },

  -- Clear scrollback
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },

  -- Custom: Delete to beginning of line with Cmd+U (sends 50 Backspaces)
  {
    key = 'u',
    mods = 'CMD',
    action = wezterm.action.Multiple {
      wezterm.action.SendString(string.rep('\x08', 50)), -- Send 50 Backspaces
    },
  },
  -- Delete to end of line (Cmd+Shift+K sends Ctrl+K)
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendKey { key = 'k', mods = 'CTRL' },
  },
  -- Delete previous word (Cmd+Shift+W sends Ctrl+W)
  {
    key = 'w',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' },
  },
  -- Delete next word (Cmd+Alt+D sends Alt+D)
  {
    key = 'd',
    mods = 'CMD|ALT',
    action = wezterm.action.SendKey { key = 'd', mods = 'ALT' },
  },
}

-- === PERFORMANCE TWEAKS ===
config.enable_wayland = false  -- macOS không cần
config.front_end = "OpenGL"    -- Tốt cho macOS
config.webgpu_power_preference = "HighPerformance"

-- === SSH CONNECTIONS ===
config.ssh_backend = "Ssh2"

-- === WORKSPACE MANAGEMENT ===
config.default_workspace = "main"

-- Quick workspace switching
table.insert(config.keys, {
  key = '1', mods = 'CMD',
  action = wezterm.action.SwitchToWorkspace { name = 'dev' }
})
table.insert(config.keys, {
  key = '2', mods = 'CMD',
  action = wezterm.action.SwitchToWorkspace { name = 'ops' }
})

-- === SSH DOMAINS (Optional) ===
-- Uncomment nếu thường xuyên SSH vào servers
-- config.ssh_domains = {
--   {
--     name = 'production',
--     remote_address = 'your-server.com',
--     username = 'your-username',
--   },
-- }

return config

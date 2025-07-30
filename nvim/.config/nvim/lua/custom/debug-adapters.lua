-- 🚀 Enhanced Debug Adapters Configuration
-- Comprehensive debugging setup for Java, Go, and other languages
-- Based on video tutorial best practices for optimal DAP-UI experience

local M = {}

-- ===============================================
-- 🔧 UTILITY FUNCTIONS
-- ===============================================
local function notify_debug(message, level)
  vim.notify("🐛 " .. message, level or vim.log.levels.INFO)
end

local function ensure_executable(cmd, install_msg)
  if vim.fn.executable(cmd) ~= 1 then
    notify_debug(install_msg, vim.log.levels.WARN)
    return false
  end
  return true
end

-- ===============================================
-- 🐹 GO (DELVE) DEBUG ADAPTER
-- ===============================================
function M.setup_go_adapter()
  local dap = require("dap")
  
  if not ensure_executable("dlv", "Delve not found! Install: go install github.com/go-delve/delve/cmd/dlv@latest") then
    return false
  end
  
  -- Enhanced delve adapter with better error handling
  dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
      stdio = {nil, stdout},
      args = {"dap", "-l", "127.0.0.1:" .. port},
      detached = true
    }
    
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        notify_debug("Delve exited with code " .. code, vim.log.levels.ERROR)
      end
    end)
    
    if not handle then
      notify_debug("Error running dlv: " .. tostring(pid_or_err), vim.log.levels.ERROR)
      return
    end
    
    stdout:read_start(function(err, chunk)
      if err then
        notify_debug("Delve stdout error: " .. err, vim.log.levels.ERROR)
        return
      end
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    
    -- Wait for delve to start
    vim.defer_fn(function()
      callback({type = "server", host = "127.0.0.1", port = port})
    end, 100)
  end
  
  -- Go debugging configurations (enhanced)
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug Package",
      request = "launch",
      program = "${workspaceFolder}",
      console = "internalConsole",
    },
    {
      type = "go",
      name = "Debug File",
      request = "launch", 
      program = "${file}",
      console = "internalConsole",
    },
    {
      type = "go",
      name = "Debug Package (with args)",
      request = "launch",
      program = "${workspaceFolder}",
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " ")
      end,
      console = "internalConsole",
    },
    {
      type = "go",
      name = "Debug Test Package",
      request = "launch",
      mode = "test",
      program = "${workspaceFolder}",
      console = "internalConsole",
    },
    {
      type = "go", 
      name = "Debug Test File",
      request = "launch",
      mode = "test",
      program = "${file}",
      console = "internalConsole",
    },
    {
      type = "go",
      name = "Debug Test Function",
      request = "launch",
      mode = "test",
      program = "${file}",
      args = function()
        local test_name = vim.fn.input("Test function name: ")
        if test_name == "" then
          return {}
        end
        return {"-test.run", "^" .. test_name .. "$"}
      end,
      console = "internalConsole",
    },
    {
      type = "go",
      name = "Attach to Process",
      mode = "attach",
      request = "attach",
      processId = function()
        return require('dap.utils').pick_process()
      end,
    },
  }
  
  notify_debug("Go debugging with delve configured!")
  return true
end

-- ===============================================
-- ☕ JAVA DEBUG ADAPTER ENHANCEMENT  
-- ===============================================
function M.setup_java_adapter()
  local dap = require("dap")
  
  -- Java debug adapter is handled by nvim-jdtls
  -- We just need to ensure proper configurations exist
  dap.configurations.java = dap.configurations.java or {}
  
  -- Add enhanced Java configurations
  local java_configs = {
    {
      type = "java",
      request = "launch",
      name = "Debug Java Application",
      mainClass = function()
        return vim.fn.input("Main class: ")
      end,
      console = "internalConsole",
      internalConsoleOptions = "openOnSessionStart"
    },
    {
      type = "java",
      request = "launch", 
      name = "Debug Java Application (current file)",
      mainClass = "${file}",
      console = "internalConsole",
      internalConsoleOptions = "openOnSessionStart"
    },
    {
      type = "java",
      request = "launch",
      name = "Debug Spring Boot Application",
      mainClass = "org.springframework.boot.loader.JarLauncher",
      args = function()
        local profile = vim.fn.input("Spring profile (default: dev): ")
        if profile == "" then profile = "dev" end
        return {"--spring.profiles.active=" .. profile}
      end,
      console = "internalConsole",
      internalConsoleOptions = "openOnSessionStart"
    },
    {
      type = "java",
      request = "launch",
      name = "Debug Test",
      mainClass = "",
      vmArgs = "-ea",
      console = "internalConsole",
      internalConsoleOptions = "openOnSessionStart"
    },
  }
  
  -- Merge with existing configurations
  for _, config in ipairs(java_configs) do
    table.insert(dap.configurations.java, config)
  end
  
  notify_debug("Java debugging configurations enhanced!")
  return true
end

-- ===============================================
-- 🚀 NODE.JS DEBUG ADAPTER (BONUS)
-- ===============================================
function M.setup_node_adapter()
  local dap = require("dap")
  
  if not ensure_executable("node", "Node.js not found! Install Node.js first") then
    return false
  end
  
  -- Node.js debug adapter
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"},
  }
  
  dap.configurations.javascript = {
    {
      name = 'Launch Node.js Program',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'internalConsole',
    },
    {
      name = 'Launch Node.js Program (with args)',
      type = 'node2', 
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'internalConsole',
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " ")
      end,
    }
  }
  
  notify_debug("Node.js debugging configured!")
  return true
end

-- ===============================================
-- 🐍 PYTHON DEBUG ADAPTER (BONUS)
-- ===============================================
function M.setup_python_adapter()
  local dap = require("dap")
  
  if not ensure_executable("python", "Python not found! Install Python first") then
    return false
  end
  
  -- Python debug adapter
  dap.adapters.python = {
    type = 'executable',
    command = 'python',
    args = { '-m', 'debugpy.adapter' },
  }
  
  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = "Launch Python File",
      program = "${file}",
      pythonPath = function()
        return '/usr/bin/python'
      end,
      console = "internalConsole",
    },
    {
      type = 'python',
      request = 'launch',
      name = "Launch Python File (with args)",
      program = "${file}",
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " ")
      end,
      pythonPath = function()
        return '/usr/bin/python'
      end,
      console = "internalConsole",
    }
  }
  
  notify_debug("Python debugging configured!")
  return true
end

-- ===============================================
-- 🎯 MAIN SETUP FUNCTION
-- ===============================================
function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    notify_debug("nvim-dap not available! Install it first", vim.log.levels.ERROR)
    return false
  end
  
  -- Set up all debug adapters
  local adapters_setup = {
    go = M.setup_go_adapter,
    java = M.setup_java_adapter,
    node = M.setup_node_adapter,
    python = M.setup_python_adapter,
  }
  
  local success_count = 0
  local total_count = 0
  
  for name, setup_func in pairs(adapters_setup) do
    total_count = total_count + 1
    if setup_func() then
      success_count = success_count + 1
    end
  end
  
  notify_debug(string.format("Debug adapters setup complete: %d/%d configured", success_count, total_count))
  
  -- Create useful commands
  vim.api.nvim_create_user_command('DebugAdapters', function()
    local message = [[
🐛 Available Debug Adapters:
  
  • Go (delve): F12 to debug Go applications
  • Java (jdtls): F12 to debug Java/Spring Boot apps  
  • Node.js: :lua require('dap').continue() for JavaScript
  • Python: :lua require('dap').continue() for Python
  
🎯 Quick Start:
  1. Set breakpoints with F9
  2. Press F12 to start debugging
  3. Use F4 to toggle debug UI
  4. Use F10 (step over), F11 (step into)
  
💡 Debug UI Layout (like video):
  • Left: Variables, Call Stack, Breakpoints, Watches
  • Bottom: Console, REPL
    ]]
    vim.notify(message, vim.log.levels.INFO)
  end, { desc = 'Show available debug adapters' })
  
  return true
end

-- ===============================================
-- 🔧 AUTO-SETUP ON LOAD
-- ===============================================
-- Automatically set up when this module is loaded
vim.defer_fn(function()
  M.setup()
end, 100)

return M
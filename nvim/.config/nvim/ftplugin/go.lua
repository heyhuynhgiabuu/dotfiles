-- Go Development Configuration with Delve Debugging
-- Provides clean Go debugging with delve integration
-- Based on the video tutorial for optimal DAP-UI experience

-- ===============================================
-- 🔧 GO ENVIRONMENT DETECTION
-- ===============================================
local function ensure_go_available()
  if vim.fn.executable("go") ~= 1 then
    vim.notify("❌ Go not found in PATH! Install Go first", vim.log.levels.ERROR)
    return false
  end
  
  if vim.fn.executable("dlv") ~= 1 then
    vim.notify("⚠️  Delve debugger not found! Install with: go install github.com/go-delve/delve/cmd/dlv@latest", vim.log.levels.WARN)
    return false
  end
  
  return true
end

-- ===============================================
-- 🐛 DELVE (DLV) DEBUG ADAPTER CONFIGURATION
-- ===============================================
local function setup_go_debugging()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    vim.notify("❌ nvim-dap not available for Go debugging", vim.log.levels.ERROR)
    return
  end

  -- Configure Go debug adapter (delve)
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
        print('dlv exited with code', code)
      end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(
      function()
        callback({type = "server", host = "127.0.0.1", port = port})
      end,
      100)
  end

  -- Go debugging configurations
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug",
      request = "launch",
      program = "${file}",
    },
    {
      type = "go",
      name = "Debug go mod (go.mod directory)", 
      request = "launch",
      program = "${workspaceFolder}",
    },
    {
      type = "go",
      name = "Debug Package",
      request = "launch",
      program = "${fileDirname}",
    },
    {
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
    {
      type = "go",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- Debug single test function
    {
      type = "go",
      name = "Debug test function",
      request = "launch",
      mode = "test", 
      program = "${file}",
      args = function()
        local test_name = vim.fn.input("Test name (regex): ")
        return {"-test.run", test_name}
      end,
    },
  }

  vim.notify("🐹 Go debugging with delve configured successfully!", vim.log.levels.INFO)
end

-- ===============================================
-- 🚀 GO DEVELOPMENT KEYMAPS
-- ===============================================
local function setup_go_keymaps()
  local opts = { buffer = true, silent = true }
  
  -- Go-specific run/debug commands
  vim.keymap.set("n", "<leader>gr", function()
    local file = vim.fn.expand("%")
    vim.cmd("split | terminal go run " .. file)
  end, vim.tbl_extend("force", opts, { desc = "Run current Go file" }))
  
  vim.keymap.set("n", "<leader>gt", function()
    vim.cmd("split | terminal go test -v")
  end, vim.tbl_extend("force", opts, { desc = "Run Go tests" }))
  
  vim.keymap.set("n", "<leader>gb", function()
    vim.cmd("split | terminal go build")
  end, vim.tbl_extend("force", opts, { desc = "Build Go project" }))
  
  -- Go-specific debug keymaps
  vim.keymap.set("n", "<F12>", function()
    if not ensure_go_available() then
      return
    end
    
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    
    -- Set up debug configurations if not already done
    if not dap.configurations.go or #dap.configurations.go == 0 then
      setup_go_debugging()
    end
    
    -- Start debugging
    dap.continue()
    vim.notify("🐹 Starting Go debug session with delve", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Debug Go application (F12)" }))
  
  vim.keymap.set("n", "<F7>", function()
    if not ensure_go_available() then
      return
    end
    
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    
    -- Set debug configuration for tests
    dap.run({
      type = "go",
      name = "Debug Package Tests",
      request = "launch",
      mode = "test",
      program = "${fileDirname}"
    })
    vim.notify("🧪 Starting Go test debug session", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Debug Go tests (F7)" }))
  
  vim.keymap.set("n", "<F8>", function()
    if not ensure_go_available() then
      return
    end
    
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      return
    end
    
    -- Debug current test function
    dap.run({
      type = "go",
      name = "Debug current test",
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
    })
    vim.notify("🎯 Starting Go test function debug", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Debug Go test function (F8)" }))

  vim.notify("🐹 Go development keymaps configured!", vim.log.levels.INFO)
end

-- ===============================================
-- 🔧 GO LSP CONFIGURATION
-- ===============================================
local function setup_go_lsp()
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    vim.notify("❌ nvim-lspconfig not available", vim.log.levels.ERROR)
    return
  end

  -- Configure gopls (Go language server)
  lspconfig.gopls.setup({
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      
      -- Go-specific LSP keymaps
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
      
      vim.notify("🐹 Go LSP (gopls) attached successfully!", vim.log.levels.INFO)
    end,
  })
end

-- ===============================================
-- 🎯 MAIN SETUP
-- ===============================================
if ensure_go_available() then
  setup_go_debugging()
  setup_go_keymaps()
  setup_go_lsp()
  
  -- Auto-format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
      vim.lsp.buf.format()
    end,
  })
  
  vim.notify("🐹 Go development environment with debugging ready!", vim.log.levels.INFO)
else
  vim.notify("⚠️  Go environment incomplete. Install Go and delve first.", vim.log.levels.WARN)
end
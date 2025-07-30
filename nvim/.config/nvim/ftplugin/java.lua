-- Simple nvim-jdtls configuration
-- Auto-detects dependencies and provides clean Spring Boot integration

local status_ok, jdtls = pcall(require, "jdtls")
if not status_ok then
  vim.notify("nvim-jdtls not found! Install with :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

-- Prevent multiple servers per buffer
if vim.b.jdtls_attached then
  return
end
vim.b.jdtls_attached = true

-- ===============================================
-- 🔧 JAVA EXECUTABLE DETECTION
-- ===============================================
local function get_java_executable()
  -- Try JAVA_HOME first
  local java_home = vim.env.JAVA_HOME
  if java_home and java_home ~= "" then
    local java_bin = java_home .. "/bin/java"
    if vim.fn.executable(java_bin) == 1 then
      return java_bin
    end
  end
  
  -- Fallback to system java
  if vim.fn.executable("java") == 1 then
    return "java"
  end
  
  -- macOS specific paths
  local macos_paths = {
    "/opt/homebrew/opt/openjdk/bin/java",
    "/usr/local/opt/openjdk/bin/java",
    "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java",
  }
  
  for _, path in ipairs(macos_paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  
  return "java" -- fallback
end

-- ===============================================
-- 📦 JDTLS INSTALLATION DETECTION
-- ===============================================
local function get_jdtls_path()
  -- Try Mason installation first
  local mason_status, mason_registry = pcall(require, "mason-registry")
  if mason_status and mason_registry.is_installed("jdtls") then
    local jdtls_pkg = mason_registry.get_package("jdtls")
    if type(jdtls_pkg.get_install_path) == "function" then
      return jdtls_pkg.get_install_path()
    else
      return vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    end
  end
  
  -- Fallback paths
  local manual_paths = {
    vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls"),
    "/opt/jdtls",
    "/usr/local/jdtls",
  }
  
  for _, path in ipairs(manual_paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end
  
  vim.notify("JDTLS not found! Install via :MasonInstall jdtls", vim.log.levels.ERROR)
  return nil
end

-- ===============================================
-- 🏗️ PROJECT DETECTION
-- ===============================================
local jdtls_path = get_jdtls_path()
if not jdtls_path then
  return
end

-- Find launcher jar
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher_jar == "" then
  vim.notify("JDTLS launcher jar not found!", vim.log.levels.ERROR)
  return
end

-- OS-specific configuration
local config_dir
if vim.fn.has("mac") == 1 then
  config_dir = jdtls_path .. "/config_mac"
elseif vim.fn.has("unix") == 1 then
  config_dir = jdtls_path .. "/config_linux"
else
  config_dir = jdtls_path .. "/config_linux"
end

-- Project root detection
local root_markers = {'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  root_dir = vim.fn.getcwd()
end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name
vim.fn.mkdir(workspace_dir, "p")

-- ===============================================
-- 🔌 DEBUG EXTENSIONS
-- ===============================================
local bundles = {}
local mason_packages = vim.fn.expand("~/.local/share/nvim/mason/packages")

-- Java debug adapter
local java_debug_path = mason_packages .. "/java-debug-adapter"
if vim.fn.isdirectory(java_debug_path) == 1 then
  local java_debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
  if java_debug_jar ~= "" then
    table.insert(bundles, java_debug_jar)
  end
end

-- Java test extension
local java_test_path = mason_packages .. "/java-test"
if vim.fn.isdirectory(java_test_path) == 1 then
  local java_test_jars = vim.fn.glob(java_test_path .. "/extension/server/*.jar", false, true)
  for _, jar in ipairs(java_test_jars) do
    table.insert(bundles, jar)
  end
end

-- ===============================================
-- ⚙️ JDTLS CONFIGURATION
-- ===============================================
local config = {
  cmd = {
    get_java_executable(),
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. jdtls_path .. "/lombok.jar",
    "-jar", launcher_jar,
    "-configuration", config_dir,
    "-data", workspace_dir,
  },
  
  root_dir = root_dir,
  
  settings = {
    java = {
      signatureHelp = { enabled = true },
      eclipse = { downloadSources = true },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = vim.env.JAVA_HOME or "/opt/homebrew/opt/openjdk",
            default = true,
          },
        },
      },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
          "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
          "java.util.Objects.requireNonNull",
          "java.util.Collections.*",
          "java.util.Arrays.*",
        },
        importOrder = {
          "java", "javax", "jakarta", "org", "com",
          "static java", "static javax", "static org", "static com",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 5,
          staticStarThreshold = 3,
        },
      },
      saveActions = { organizeImports = true },
    },
  },
  
  init_options = { bundles = bundles },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  
  on_attach = function(client, bufnr)
    -- ===============================================
    -- 🚀 JAVA APPLICATION RUNNER UTILITIES
    -- ===============================================
    local function detect_project_type()
      local cwd = vim.fn.getcwd()
      
      -- Check for Spring Boot
      if vim.fn.filereadable(cwd .. "/build.gradle") == 1 then
        local gradle_content = table.concat(vim.fn.readfile(cwd .. "/build.gradle"), "\n")
        if string.match(gradle_content, "spring%-boot") then
          return "spring-gradle"
        end
        return "gradle"
      elseif vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
        local pom_content = table.concat(vim.fn.readfile(cwd .. "/pom.xml"), "\n")
        if string.match(pom_content, "spring%-boot") then
          return "spring-maven"
        end
        return "maven"
      end
      
      return "java"
    end
    
    local function run_java_app(with_debug, additional_args)
      local cwd = vim.fn.getcwd()
      local project_type = detect_project_type()
      
      -- Handle debug mode using nvim-dap
      if with_debug then
        local dap_ok, dap = pcall(require, "dap")
        if not dap_ok then
          vim.notify("❌ nvim-dap not available for debugging", vim.log.levels.ERROR)
          return
        end
        
        -- Set up main class configurations for DAP
        require('jdtls.dap').setup_dap_main_class_configs()
        
        -- Create Spring Boot debug configuration with arguments if needed
        if string.match(project_type, "spring") and additional_args then
          local args_list = {}
          -- Split additional_args by space and add to args list
          for arg in additional_args:gmatch("%S+") do
            table.insert(args_list, arg)
          end
          
          -- Create temporary debug configuration with args
          dap.configurations.java = dap.configurations.java or {}
          table.insert(dap.configurations.java, {
            type = 'java',
            request = 'launch',
            name = 'Spring Boot App (Debug with Args)',
            mainClass = '',  -- Will be determined by jdtls
            args = args_list,
            console = 'internalConsole',
            internalConsoleOptions = 'openOnSessionStart'
          })
        end
        
        -- Start debugging
        dap.continue()
        local app_type = string.match(project_type, "spring") and "Spring Boot" or "Java"
        vim.notify("🐛 Starting " .. app_type .. " debug session", vim.log.levels.INFO)
        return
      end
      
      -- Regular run mode using terminal
      local cmd
      if project_type == "spring-gradle" then
        if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
          cmd = "./gradlew bootRun"
        else
          cmd = "gradle bootRun"
        end
        -- For Gradle, use --args format
        if additional_args then
          cmd = cmd .. " --args='" .. additional_args .. "'"
        end
      elseif project_type == "spring-maven" then
        if vim.fn.filereadable(cwd .. "/mvnw") == 1 then
          cmd = "./mvnw spring-boot:run"
        else
          cmd = "mvn spring-boot:run"
        end
        -- For Maven, use spring-boot.run.arguments format
        if additional_args then
          cmd = cmd .. " -Dspring-boot.run.arguments=\"" .. additional_args .. "\""
        end
      elseif project_type == "gradle" then
        if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
          cmd = "./gradlew run"
        else
          cmd = "gradle run"
        end
        if additional_args then
          cmd = cmd .. " --args='" .. additional_args .. "'"
        end
      elseif project_type == "maven" then
        if vim.fn.filereadable(cwd .. "/mvnw") == 1 then
          cmd = "./mvnw exec:java"
        else
          cmd = "mvn exec:java"
        end
        if additional_args then
          cmd = cmd .. " " .. additional_args
        end
      else
        -- Use DAP for plain Java projects
        local dap_ok, dap = pcall(require, "dap")
        if dap_ok then
          require('jdtls.dap').setup_dap_main_class_configs()
          dap.continue()
          vim.notify("🚀 Running Java application via DAP", vim.log.levels.INFO)
          return
        else
          vim.notify("❌ No build tool or DAP found for running Java", vim.log.levels.ERROR)
          return
        end
      end
      
      vim.cmd("split | terminal " .. cmd)
      local app_type = string.match(project_type, "spring") and "Spring Boot" or "Java"
      vim.notify("🚀 Running " .. app_type .. " application", vim.log.levels.INFO)
    end
    
    local function run_with_profile_and_args(debug_mode)
      debug_mode = debug_mode or false
      local project_type = detect_project_type()
      
      if string.match(project_type, "spring") then
        vim.ui.input({
          prompt = "Spring Profile (default): ",
          default = "default"
        }, function(profile)
          if not profile then return end
          
          vim.ui.input({
            prompt = "Command arguments (optional): ",
            default = ""
          }, function(args)
            local full_args = "--spring.profiles.active=" .. profile
            if args and args ~= "" then
              full_args = full_args .. " " .. args
            end
            run_java_app(debug_mode, full_args)
          end)
        end)
      else
        vim.ui.input({
          prompt = "Main class (e.g., com.example.HelloJava): ",
          default = "com.example.HelloJava"
        }, function(main_class)
          if not main_class then return end
          
          vim.ui.input({
            prompt = "Program arguments (optional): ",
            default = ""
          }, function(args)
            local full_args = "-Dexec.mainClass=" .. main_class
            if args and args ~= "" then
              full_args = full_args .. " -Dexec.args='" .. args .. "'"
            end
            run_java_app(debug_mode, full_args)
          end)
        end)
      end
    end
    
    local function run_with_command(debug_mode)
      debug_mode = debug_mode or false
      local project_type = detect_project_type()
      
      if string.match(project_type, "spring") then
        vim.ui.input({
          prompt = "Command arguments (optional): ",
          default = ""
        }, function(command)
          if not command then return end
          
          vim.ui.input({
            prompt = "Spring Profile (default): ",
            default = "default"
          }, function(profile)
            if not profile then return end
            
            local args = "--spring.profiles.active=" .. profile .. " --command=" .. command
            run_java_app(debug_mode, args)
          end)
        end)
      else
        vim.notify("ℹ️ Custom commands are for Spring Boot projects. Use <leader>jr for regular Java apps.", vim.log.levels.INFO)
        run_with_profile_and_args(debug_mode)
      end
    end
    
    -- ===============================================
    -- ⌨️ KEYMAPS
    -- ===============================================
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Basic LSP
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)
    
    -- Java-specific refactoring
    vim.keymap.set("n", "<leader>jo", function() require('jdtls').organize_imports() end, opts)
    vim.keymap.set("n", "<leader>jv", function() require('jdtls').extract_variable() end, opts)
    vim.keymap.set("v", "<leader>jv", function() require('jdtls').extract_variable(true) end, opts)
    vim.keymap.set("n", "<leader>jc", function() require('jdtls').extract_constant() end, opts)
    vim.keymap.set("v", "<leader>jc", function() require('jdtls').extract_constant(true) end, opts)
    vim.keymap.set("v", "<leader>jm", function() require('jdtls').extract_method(true) end, opts)
    
    -- Testing
    vim.keymap.set("n", "<F7>", function() require('jdtls').test_class() end, opts)
    vim.keymap.set("n", "<F8>", function() require('jdtls').test_nearest_method() end, opts)
    
    -- Spring Boot / Java runners
    vim.keymap.set("n", "<F5>", function() run_java_app(false) end, 
      { desc = "Run Java/Spring Boot App", buffer = bufnr })
    vim.keymap.set("n", "<F12>", function() run_java_app(true) end, 
      { desc = "Debug Java/Spring Boot App", buffer = bufnr })
    vim.keymap.set("n", "<leader>jr", function() run_with_profile_and_args(false) end, 
      { desc = "Run with Profile & Args", buffer = bufnr })
    vim.keymap.set("n", "<leader>jd", function() run_with_profile_and_args(true) end, 
      { desc = "Debug with Profile & Args", buffer = bufnr })
    vim.keymap.set("n", "<leader>jc", function() run_with_command(false) end, 
      { desc = "Run with Command", buffer = bufnr })
    vim.keymap.set("n", "<leader>jC", function() run_with_command(true) end, 
      { desc = "Debug with Command", buffer = bufnr })
    
    -- Debug setup
    local dap_ok, dap = pcall(require, "dap")
    if dap_ok then
      require('jdtls.dap').setup_dap_main_class_configs()
    end
    
    -- ===============================================
    -- 📋 WHICH-KEY INTEGRATION
    -- ===============================================
    local wk_ok, which_key = pcall(require, "which-key")
    if wk_ok then
      which_key.add({
        { "<leader>j", group = "☕ Java", buffer = bufnr },
        { "<leader>jo", function() require('jdtls').organize_imports() end, desc = "Organize Imports", buffer = bufnr },
        { "<leader>jv", function() require('jdtls').extract_variable() end, desc = "Extract Variable", buffer = bufnr, mode = "n" },
        { "<leader>jv", function() require('jdtls').extract_variable(true) end, desc = "Extract Variable", buffer = bufnr, mode = "v" },
        { "<leader>jc", function() require('jdtls').extract_constant() end, desc = "Extract Constant", buffer = bufnr, mode = "n" },
        { "<leader>jc", function() require('jdtls').extract_constant(true) end, desc = "Extract Constant", buffer = bufnr, mode = "v" },
        { "<leader>jm", function() require('jdtls').extract_method(true) end, desc = "Extract Method", buffer = bufnr, mode = "v" },
        
        { "<leader>jr", function() run_with_profile_and_args(false) end, desc = "Run with Args/Profile", buffer = bufnr },
        { "<leader>jd", function() run_with_profile_and_args(true) end, desc = "Debug with Args/Profile", buffer = bufnr },
        { "<leader>jc", function() run_with_command(false) end, desc = "Run Command (Spring)", buffer = bufnr },
        { "<leader>jC", function() run_with_command(true) end, desc = "Debug Command (Spring)", buffer = bufnr },
        
        { "<F5>", function() run_java_app(false) end, desc = "Run Java/Spring Boot", buffer = bufnr },
        { "<F12>", function() run_java_app(true) end, desc = "Debug Java/Spring Boot", buffer = bufnr },
        { "<F7>", function() require('jdtls').test_class() end, desc = "Run Test Class", buffer = bufnr },
        { "<F8>", function() require('jdtls').test_nearest_method() end, desc = "Run Test Method", buffer = bufnr },
      })
    end
    
    vim.notify("☕ Java LSP ready! F5=Run, F12=Debug, <leader>jr=Run with args, <leader>jd=Debug with args", vim.log.levels.INFO)
  end,
}

-- ===============================================
-- 🚀 START JDTLS
-- ===============================================
require('jdtls').start_or_attach(config)

-- Auto-organize imports on save
local java_group = vim.api.nvim_create_augroup("JavaLSP", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = java_group,
  pattern = "*.java",
  callback = function()
    require('jdtls').organize_imports()
  end,
})

-- Java LSP configuration using nvim-jdtls
-- This follows official nvim-jdtls best practices for stability and compatibility

local status_ok, jdtls = pcall(require, "jdtls")
if not status_ok then
  vim.notify("nvim-jdtls not found!", vim.log.levels.ERROR)
  return
end

-- ===============================================
-- 📋 PROFILE SYSTEM SETUP
-- ===============================================
local profile_manager = require("custom.java-profiles")
local selected_profile = profile_manager.auto_detect_profile()

-- Check if user has set a specific profile via vim variable
if vim.g.java_profile then
  selected_profile = vim.g.java_profile
end

local current_profile = profile_manager.get_profile(selected_profile)
vim.notify("🎯 Using Java Profile: " .. current_profile.name, vim.log.levels.INFO)

-- Get extended client capabilities
local extendedClientCapabilities = jdtls.extendedClientCapabilities

-- Only load once per buffer to prevent multiple servers
if vim.b.jdtls_attached then
  return
end
vim.b.jdtls_attached = true

-- Helper function to get java executable path
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

-- Helper function to get JDTLS installation path
local function get_jdtls_path()
  -- Try Mason installation first
  local mason_status, mason_registry = pcall(require, "mason-registry")
  if mason_status and mason_registry.is_installed("jdtls") then
    local jdtls_pkg = mason_registry.get_package("jdtls")
    -- Use different method based on Mason version
    if type(jdtls_pkg.get_install_path) == "function" then
      return jdtls_pkg.get_install_path()
    else
      -- Fallback for newer Mason versions
      return vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    end
  end
  
  -- Fallback paths for manual installation
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

-- Get JDTLS installation path
local jdtls_path = get_jdtls_path()
if not jdtls_path then
  return
end

-- Find the launcher jar
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher_jar == "" then
  vim.notify("JDTLS launcher jar not found!", vim.log.levels.ERROR)
  return
end

-- Determine configuration directory based on OS
local config_dir
if vim.fn.has("mac") == 1 then
  config_dir = jdtls_path .. "/config_mac"
elseif vim.fn.has("unix") == 1 then
  config_dir = jdtls_path .. "/config_linux"
elseif vim.fn.has("win32") == 1 then
  config_dir = jdtls_path .. "/config_win"
else
  config_dir = jdtls_path .. "/config_linux"
end

-- Create workspace directory for project (one per unique root directory)
-- This prevents multiple JDTLS servers
local root_markers = {'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  root_dir = vim.fn.getcwd()
end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name

-- Ensure workspace directory exists
vim.fn.mkdir(workspace_dir, "p")

-- Try to load java-debug and java-test extensions if available
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

-- JDTLS configuration
local config = {
  -- Command to start JDTLS
  cmd = {
    get_java_executable(),
    
    -- JVM arguments
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    
    -- Lombok support if available
    "-javaagent:" .. jdtls_path .. "/lombok.jar",
    
    -- JDTLS jar
    "-jar", launcher_jar,
    
    -- Configuration and data directories
    "-configuration", config_dir,
    "-data", workspace_dir,
  },
  
  -- Root directory detection (critical for preventing multiple servers)
  root_dir = root_dir,
  
  -- Language server settings - IntelliJ IDEA-like configuration
  settings = {
    java = {
      -- ===== CORE LANGUAGE SERVER FEATURES =====
      signatureHelp = { 
        enabled = true,
        description = { enabled = true }  -- Show parameter descriptions
      },
      extendedClientCapabilities = extendedClientCapabilities,
      
      -- ===== BUILD AND PROJECT CONFIGURATION =====
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",  -- Like IntelliJ's "Import Changes" prompt
        -- Configure multiple Java runtimes (similar to IntelliJ Project Structure)
        runtimes = {
          {
            name = "JavaSE-17",
            path = vim.env.JAVA_HOME or "/opt/homebrew/opt/openjdk",
            default = true,
          },
          -- Add more runtimes as needed for multi-JDK projects
          -- {
          --   name = "JavaSE-21",
          --   path = "/opt/homebrew/opt/openjdk@21",
          -- },
        },
      },
      
      -- ===== MAVEN AND GRADLE INTEGRATION =====
      maven = {
        downloadSources = true,
        updateSnapshots = false,  -- Prevent automatic snapshot updates
      },
      
      -- ===== CODE LENS AND VISUAL AIDS =====
      implementationsCodeLens = {
        enabled = true,  -- Show implementation count above interfaces/abstract methods
      },
      referencesCodeLens = {
        enabled = true,  -- Show reference count above methods/fields
      },
      
      -- ===== REFERENCES AND NAVIGATION =====
      references = {
        includeDecompiledSources = true,  -- Like IntelliJ's "Attach Sources" feature
        includeAccessors = true,  -- Include getter/setter references
      },
      
      -- ===== INLAY HINTS (Parameter names, type hints) =====
      inlayHints = {
        parameterNames = {
          enabled = "literals",  -- Show parameter names for literals (similar to IntelliJ)
          exclusions = {
            "java.lang.String",
            "java.lang.CharSequence", 
            "java.lang.StringBuffer",
            "java.lang.StringBuilder"
          }
        },
      },
      
      -- ===== CODE FORMATTING (IntelliJ-like) =====
      format = {
        enabled = true,
        insertSpaces = true,
        tabSize = 4,
        comments = { enabled = true },
        onType = { enabled = true },  -- Format on semicolon, brace, etc.
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      
      -- ===== AUTO-COMPLETION (IntelliJ-like smart completion) =====
      completion = {
        enabled = true,
        maxResults = 50,  -- Limit completion results for performance
        guessMethodArguments = true,  -- Smart argument completion
        favoriteStaticMembers = {
          -- Testing frameworks (like IntelliJ's Live Templates)
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*", 
          "org.junit.jupiter.api.DynamicContainer.*",
          "org.junit.jupiter.api.DynamicTest.*",
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          
          -- Java utility methods
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "java.util.Collections.*",
          "java.util.Arrays.*",
          "java.time.LocalDateTime.*",
          "java.time.LocalDate.*",
          
          -- Logging frameworks
          "org.slf4j.LoggerFactory.getLogger",
          "java.util.logging.Logger.getLogger",
        },
        -- IntelliJ-like import ordering
        importOrder = {
          "java",
          "javax", 
          "jakarta",
          "org",
          "com",
          "static java",
          "static javax",
          "static org",
          "static com",
        },
        -- Filtered types (exclude from completion like IntelliJ's "Exclude from completion")
        filteredTypes = {
          "com.sun.*",
          "java.awt.*",
          "javax.swing.*",
          "sun.*",
        },
        postfix = { enabled = true },  -- Enable postfix completion (.var, .if, .for, etc.)
      },
      
      -- ===== IMPORT MANAGEMENT =====
      sources = {
        organizeImports = {
          starThreshold = 5,        -- Use * imports after 5 classes (IntelliJ default)
          staticStarThreshold = 3,  -- Use static * imports after 3 static imports
        },
      },
      
      -- ===== SAVE ACTIONS (IntelliJ-like on-save actions) =====
      saveActions = {
        organizeImports = true,  -- Auto-organize imports on save
      },
      
      -- ===== CLEANUP ON SAVE (IntelliJ Code Cleanup actions) =====
      cleanup = {
        actionsOnSave = {
          "addOverride",           -- Add @Override annotations
          "addDeprecated",         -- Add @Deprecated annotations  
          "qualifyMembers",        -- Qualify field access with 'this.'
          "addFinalModifier",      -- Add final modifier where possible
          "instanceofPatternMatch", -- Use pattern matching for instanceof
          "lambdaExpression",      -- Convert to lambda expressions
        },
      },
      
      -- ===== CODE GENERATION (IntelliJ-like templates and generation) =====
      codeGeneration = {
        generateComments = true,    -- Generate JavaDoc comments
        useBlocks = true,          -- Always use braces for if/for/while
        insertionLocation = "afterCursor",  -- Where to insert generated code
        
        -- toString() generation settings
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          codeStyle = "STRING_FORMAT",  -- Use String.format style
          limitElements = 0,           -- No limit on elements
          listArrayContents = true,    -- Include array contents
          skipNullValues = false,      -- Include null values
        },
        
        -- hashCode() and equals() generation
        hashCodeEquals = {
          useInstanceof = true,      -- Use instanceof instead of getClass()
          useJava7Objects = true,    -- Use Objects.equals() and Objects.hashCode()
        },
      },
      
      -- ===== PROJECT MANAGEMENT =====
      project = {
        referencedLibraries = {},  -- Will be populated by Maven/Gradle
        sourcePaths = {},          -- Will be auto-detected
        outputPath = "",           -- Will be set by build tool
      },
      
      -- ===== ERROR AND WARNING CONFIGURATION =====
      errors = {
        incompleteClasspath = {
          severity = "warning",  -- Show classpath issues as warnings
        },
      },
      
      -- ===== SYMBOL AND NAVIGATION SETTINGS =====
      symbols = {
        includeSourceMethodDeclarations = true,  -- Include method declarations in symbol search
      },
      
      -- ===== QUICK FIXES AND CODE ACTIONS =====
      quickfix = {
        showAt = "line",  -- Show quick fixes at line level
      },
      
      -- ===== MEMBER SORT ORDER (like IntelliJ's Code Style settings) =====
      memberSortOrder = "T,SF,SI,SM,I,F,C,M",  -- Type, Static Fields, Static Initializers, etc.
      
      -- ===== TEMPLATES (similar to IntelliJ Live Templates) =====
      templates = {
        fileHeader = {
          "/**",
          " * ${type_name}",
          " *",
          " * @author ${user}",
          " * @date ${date}",
          " */",
        },
        typeComment = {
          "/**",
          " * ${type_name}",
          " *",
          " * ${cursor}",
          " */",
        },
      },
    },
  },
  
  -- Initialization options for extensions (DAP will be handled automatically)
  init_options = {
    bundles = bundles,
  },
  
  -- Enhanced capabilities
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  
  -- On attach function
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Java-specific keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- ===== IntelliJ IDEA-like LSP Keymaps =====
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)
    
    -- ===== Advanced Navigation (IntelliJ-like Ctrl+B, Ctrl+Alt+B) =====
    vim.keymap.set("n", "<C-b>", vim.lsp.buf.declaration, { desc = "Go to Declaration (Ctrl+B)", buffer = bufnr })
    vim.keymap.set("n", "<C-A-b>", vim.lsp.buf.implementation, { desc = "Go to Implementation (Ctrl+Alt+B)", buffer = bufnr })
    vim.keymap.set("n", "<C-h>", vim.lsp.buf.type_definition, { desc = "Go to Type Definition", buffer = bufnr })
    
    -- ===== IntelliJ IDEA-style Refactoring Keymaps =====
    -- Organize Imports (Ctrl+Alt+O in IntelliJ)
    vim.keymap.set("n", "<C-A-o>", function() require('jdtls').organize_imports() end, 
      { desc = "Organize Imports (Ctrl+Alt+O)", buffer = bufnr })
    vim.keymap.set("n", "<leader>jo", function() require('jdtls').organize_imports() end, 
      { desc = "Organize Imports", buffer = bufnr })
      
    -- Extract Variable (Ctrl+Alt+V in IntelliJ)  
    vim.keymap.set("n", "<C-A-v>", function() require('jdtls').extract_variable() end, 
      { desc = "Extract Variable (Ctrl+Alt+V)", buffer = bufnr })
    vim.keymap.set("v", "<C-A-v>", function() require('jdtls').extract_variable(true) end, 
      { desc = "Extract Variable (Ctrl+Alt+V)", buffer = bufnr })
    vim.keymap.set("n", "<leader>jv", function() require('jdtls').extract_variable() end, 
      { desc = "Extract Variable", buffer = bufnr })
    vim.keymap.set("v", "<leader>jv", function() require('jdtls').extract_variable(true) end, 
      { desc = "Extract Variable", buffer = bufnr })
      
    -- Extract Constant (Ctrl+Alt+C in IntelliJ)
    vim.keymap.set("n", "<C-A-c>", function() require('jdtls').extract_constant() end, 
      { desc = "Extract Constant (Ctrl+Alt+C)", buffer = bufnr })
    vim.keymap.set("v", "<C-A-c>", function() require('jdtls').extract_constant(true) end, 
      { desc = "Extract Constant (Ctrl+Alt+C)", buffer = bufnr })
    vim.keymap.set("n", "<leader>jc", function() require('jdtls').extract_constant() end, 
      { desc = "Extract Constant", buffer = bufnr })
    vim.keymap.set("v", "<leader>jc", function() require('jdtls').extract_constant(true) end, 
      { desc = "Extract Constant", buffer = bufnr })
      
    -- Extract Method (Ctrl+Alt+M in IntelliJ)
    vim.keymap.set("v", "<C-A-m>", function() require('jdtls').extract_method(true) end, 
      { desc = "Extract Method (Ctrl+Alt+M)", buffer = bufnr })
    vim.keymap.set("v", "<leader>jm", function() require('jdtls').extract_method(true) end, 
      { desc = "Extract Method", buffer = bufnr })
      
    -- ===== Advanced JDTLS Commands (IntelliJ-like features) =====
    -- Generate Code (Alt+Insert in IntelliJ)
    vim.keymap.set("n", "<A-Insert>", vim.lsp.buf.code_action, 
      { desc = "Generate Code (Alt+Insert)", buffer = bufnr })
    vim.keymap.set("n", "<leader>jg", vim.lsp.buf.code_action, 
      { desc = "Generate Code", buffer = bufnr })
      
    -- Show Usages (Alt+F7 in IntelliJ)
    vim.keymap.set("n", "<A-F7>", vim.lsp.buf.references, 
      { desc = "Show Usages (Alt+F7)", buffer = bufnr })
      
    -- Quick Fix (Alt+Enter in IntelliJ)
    vim.keymap.set("n", "<A-CR>", vim.lsp.buf.code_action, 
      { desc = "Quick Fix (Alt+Enter)", buffer = bufnr })
    vim.keymap.set("n", "<A-Enter>", vim.lsp.buf.code_action, 
      { desc = "Quick Fix (Alt+Enter)", buffer = bufnr })
      
    -- Rename Refactoring (Shift+F6 in IntelliJ)
    vim.keymap.set("n", "<S-F6>", vim.lsp.buf.rename, 
      { desc = "Rename (Shift+F6)", buffer = bufnr })
      
    -- Format Code (Ctrl+Alt+L in IntelliJ)
    vim.keymap.set("n", "<C-A-l>", function() vim.lsp.buf.format { async = true } end, 
      { desc = "Format Code (Ctrl+Alt+L)", buffer = bufnr })
    vim.keymap.set("v", "<C-A-l>", function() vim.lsp.buf.format { async = true } end, 
      { desc = "Format Code (Ctrl+Alt+L)", buffer = bufnr })
      
    -- ===== Additional JDTLS-specific Commands =====
    -- Compile workspace
    vim.keymap.set("n", "<leader>jw", function() require('jdtls').compile('workspace') end, 
      { desc = "Compile Workspace", buffer = bufnr })
    vim.keymap.set("n", "<leader>jr", function() require('jdtls').compile('incremental') end, 
      { desc = "Compile Incremental", buffer = bufnr })
      
    -- Open JDT commands  
    vim.keymap.set("n", "<leader>js", function() require('jdtls').jshell() end, 
      { desc = "Open JShell", buffer = bufnr })
    vim.keymap.set("n", "<leader>jb", function() require('jdtls').javap() end, 
      { desc = "Show Bytecode", buffer = bufnr })
    
    
    -- Diagnostics
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
    
    -- Check if nvim-dap is available
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
      vim.notify("nvim-dap not found - debugging features limited", vim.log.levels.WARN)
    end
    
    -- IntelliJ-style Function Key Layout for Java Development:
    -- F5-F8:  Java Run/Test (unique to Java)
    -- F9-F12: DAP Debug Controls (global, reserved for debugging stepping)
    -- <leader>jd*: Java Debug Test functions (avoid F-key conflicts)
    
    -- F5: Run Java Application (discover and run main class)
    vim.keymap.set("n", "<F5>", function() 
      vim.cmd("wa") -- Save all files first
      if dap_ok then
        require('jdtls.dap').setup_dap_main_class_configs()
        local configs = dap.configurations.java or {}
        if #configs > 0 then
          dap.continue()
          vim.notify("🚀 Running Java application...", vim.log.levels.INFO)
        else
          vim.notify("❌ No main class found to run", vim.log.levels.ERROR)
        end
      else
        vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
      end
    end, { desc = "Run Java Application (F5)", buffer = bufnr })
    
    -- F6: Debug Java Application (same as F5 but with debugging)
    vim.keymap.set("n", "<F6>", function() 
      vim.cmd("wa") -- Save all files first
      if dap_ok then
        require('jdtls.dap').setup_dap_main_class_configs()
        dap.continue()
        vim.notify("🐛 Debugging Java application...", vim.log.levels.INFO)
      else
        vim.notify("❌ nvim-dap not available for debugging", vim.log.levels.ERROR)
      end
    end, { desc = "Debug Java Application (F6)", buffer = bufnr })
    
    -- F7: Run Test Class
    vim.keymap.set("n", "<F7>", function() 
      vim.cmd("wa") -- Save all files first
      require('jdtls').test_class()
      vim.notify("🧪 Running test class...", vim.log.levels.INFO)
    end, { desc = "Run Test Class (F7)", buffer = bufnr })
    
    -- F8: Run Nearest Test Method
    vim.keymap.set("n", "<F8>", function() 
      vim.cmd("wa") -- Save all files first
      require('jdtls').test_nearest_method()
      vim.notify("🧪 Running nearest test method...", vim.log.levels.INFO)
    end, { desc = "Run Nearest Test Method (F8)", buffer = bufnr })
    
    -- Java Debug Test functions (using leader keys to avoid DAP F-key conflicts)
    vim.keymap.set("n", "<leader>jdt", function() 
      vim.cmd("wa") -- Save all files first
      if dap_ok and #bundles > 0 then
        require('jdtls').test_class()
        vim.notify("🐛 Debugging test class...", vim.log.levels.INFO)
      else
        require('jdtls').test_class() -- Still run without debugging
        vim.notify("🧪 Running test class (debug not available)...", vim.log.levels.WARN)
      end
    end, { desc = "Debug Test Class", buffer = bufnr })
    
    vim.keymap.set("n", "<leader>jdn", function() 
      vim.cmd("wa") -- Save all files first
      if dap_ok and #bundles > 0 then
        require('jdtls').test_nearest_method()
        vim.notify("🐛 Debugging nearest test method...", vim.log.levels.INFO)
      else
        require('jdtls').test_nearest_method() -- Still run without debugging
        vim.notify("🧪 Running nearest test method (debug not available)...", vim.log.levels.WARN)
      end
    end, { desc = "Debug Nearest Test Method", buffer = bufnr })
    
    -- Status notification
    vim.notify("☕ Java LSP attached - nvim-jdtls ready!", vim.log.levels.INFO)
    if dap_ok and #bundles > 0 then
      vim.notify("🐛 Java debugging enabled with DAP", vim.log.levels.INFO)
    end
    
    -- ===============================================
    -- 🔧 WHICH-KEY INTEGRATION
    -- ===============================================
    local wk_ok, which_key = pcall(require, "which-key")
    if wk_ok then
      which_key.add({
        { "<leader>j", group = "☕ Java", buffer = bufnr },
        
        -- Navigation & LSP
        { "<leader>jg", group = "🧭 Navigation", buffer = bufnr },
        { "<leader>jgd", vim.lsp.buf.definition, desc = "Go to Definition", buffer = bufnr },
        { "<leader>jgD", vim.lsp.buf.declaration, desc = "Go to Declaration", buffer = bufnr },
        { "<leader>jgi", vim.lsp.buf.implementation, desc = "Go to Implementation", buffer = bufnr },
        { "<leader>jgr", vim.lsp.buf.references, desc = "Go to References", buffer = bufnr },
        { "<leader>jgt", vim.lsp.buf.type_definition, desc = "Go to Type Definition", buffer = bufnr },
        
        -- Refactoring
        { "<leader>jx", group = "🔄 Refactoring", buffer = bufnr },
        { "<leader>jxv", function() require('jdtls').extract_variable() end, desc = "Extract Variable", buffer = bufnr, mode = "n" },
        { "<leader>jxv", function() require('jdtls').extract_variable(true) end, desc = "Extract Variable", buffer = bufnr, mode = "v" },
        { "<leader>jxc", function() require('jdtls').extract_constant() end, desc = "Extract Constant", buffer = bufnr, mode = "n" },
        { "<leader>jxc", function() require('jdtls').extract_constant(true) end, desc = "Extract Constant", buffer = bufnr, mode = "v" },
        { "<leader>jxm", function() require('jdtls').extract_method(true) end, desc = "Extract Method", buffer = bufnr, mode = "v" },
        { "<leader>jxr", vim.lsp.buf.rename, desc = "Rename Symbol", buffer = bufnr },
        
        -- Code Actions & Generation
        { "<leader>jc", group = "💡 Code Actions", buffer = bufnr },
        { "<leader>jca", vim.lsp.buf.code_action, desc = "Show Code Actions", buffer = bufnr },
        { "<leader>jco", function() require('jdtls').organize_imports() end, desc = "Organize Imports", buffer = bufnr },
        { "<leader>jcf", function() vim.lsp.buf.format { async = true } end, desc = "Format Code", buffer = bufnr },
        
        -- Build & Compilation
        { "<leader>jb", group = "🔨 Build", buffer = bufnr },
        { "<leader>jbw", function() require('jdtls').compile('workspace') end, desc = "Compile Workspace", buffer = bufnr },
        { "<leader>jbi", function() require('jdtls').compile('incremental') end, desc = "Compile Incremental", buffer = bufnr },
        { "<leader>jbc", function() require('jdtls').compile('full') end, desc = "Clean Compile", buffer = bufnr },
        
        -- Run & Execute
        { "<leader>jr", group = "▶️ Run", buffer = bufnr },
        { "<leader>jra", "<F5>", desc = "Run Application (F5)", buffer = bufnr },
        { "<leader>jrd", "<F6>", desc = "Debug Application (F6)", buffer = bufnr },
        { "<leader>jrs", function() require('jdtls').jshell() end, desc = "Open JShell", buffer = bufnr },
        { "<leader>jrb", function() require('jdtls').javap() end, desc = "Show Bytecode", buffer = bufnr },
        
        -- Testing
        { "<leader>jt", group = "🧪 Testing", buffer = bufnr },
        { "<leader>jtc", "<F7>", desc = "Run Test Class (F7)", buffer = bufnr },
        { "<leader>jtm", "<F8>", desc = "Run Test Method (F8)", buffer = bufnr },
        { "<leader>jtd", "<leader>jdt", desc = "Debug Test Class", buffer = bufnr },
        { "<leader>jtn", "<leader>jdn", desc = "Debug Test Method", buffer = bufnr },
        
        -- Debug (DAP Integration)
        { "<leader>jd", group = "🐛 Debug", buffer = bufnr },
        { "<leader>jdb", "<F9>", desc = "Toggle Breakpoint (F9)", buffer = bufnr },
        { "<leader>jdc", "<F5>", desc = "Continue/Start (F5)", buffer = bufnr },
        { "<leader>jds", "<F10>", desc = "Step Over (F10)", buffer = bufnr },
        { "<leader>jdi", "<F11>", desc = "Step Into (F11)", buffer = bufnr },
        { "<leader>jdo", "<F12>", desc = "Step Out (F12)", buffer = bufnr },
        
        -- Diagnostics
        { "<leader>jq", group = "🔍 Diagnostics", buffer = bufnr },
        { "<leader>jqd", vim.diagnostic.open_float, desc = "Show Diagnostics", buffer = bufnr },
        { "<leader>jqn", vim.diagnostic.goto_next, desc = "Next Diagnostic", buffer = bufnr },
        { "<leader>jqp", vim.diagnostic.goto_prev, desc = "Previous Diagnostic", buffer = bufnr },
        { "<leader>jql", vim.diagnostic.setloclist, desc = "Diagnostic List", buffer = bufnr },
        
        -- Help & Documentation  
        { "<leader>jh", group = "❓ Help", buffer = bufnr },
        { "<leader>jhh", vim.lsp.buf.hover, desc = "Show Hover Info", buffer = bufnr },
        { "<leader>jhs", vim.lsp.buf.signature_help, desc = "Signature Help", buffer = bufnr },
        { "<leader>jhl", "<cmd>JdtShowLogs<CR>", desc = "Show JDTLS Logs", buffer = bufnr },
        { "<leader>jhr", "<cmd>JdtRestart<CR>", desc = "Restart JDTLS", buffer = bufnr },
      })
      
      vim.notify("🔧 Which-key mappings configured for Java", vim.log.levels.INFO)
    end
    
    -- ===============================================
    -- 📋 PROFILE SYSTEM INTEGRATION  
    -- ===============================================
    local profile_ok, java_profiles = pcall(require, "custom.java-profiles")
    if profile_ok then
      -- Auto-detect and suggest profile
      local suggested_profile = java_profiles.auto_detect_profile()
      if suggested_profile ~= "default" then
        vim.notify("💡 Detected project type, consider profile: " .. java_profiles.get_profile(suggested_profile).name, vim.log.levels.INFO)
      end
      
        -- Add profile management keymaps
        if wk_ok then
          which_key.add({
            { "<leader>js", group = "⚙️ Settings/Profiles", buffer = bufnr },
            { "<leader>jsl", function()
              local profiles = java_profiles.list_profiles()
              local profile_info = "📋 Available Java Profiles:\n\n"
              for _, profile in ipairs(profiles) do
                local marker = profile.name == java_profiles.current_profile and "👉 " or "   "
                profile_info = profile_info .. marker .. profile.display_name .. "\n      " .. profile.description .. "\n\n"
              end
              profile_info = profile_info .. "\n🍃 Spring Profiles: " .. java_profiles.get_active_spring_profiles()
              vim.notify(profile_info, vim.log.levels.INFO)
            end, desc = "List Profiles", buffer = bufnr },
            
            { "<leader>jss", function()
              java_profiles.select_profile(function(profile_name)
                vim.notify("🔄 Profile changed to: " .. java_profiles.get_profile(profile_name).name .. "\nRestart required to apply changes.", vim.log.levels.WARN)
              end)
            end, desc = "Select Profile", buffer = bufnr },
            
            { "<leader>jsc", function()
              local current = java_profiles.get_current_profile()
              local spring_profiles = java_profiles.get_active_spring_profiles()
              vim.notify("🎯 Current Profile: " .. current.name .. "\n" .. current.description .. "\n\n🍃 Spring Profiles: " .. spring_profiles, vim.log.levels.INFO)
            end, desc = "Current Profile", buffer = bufnr },
            
            { "<leader>jsa", function()
              local suggested = java_profiles.auto_detect_profile()
              local profile = java_profiles.get_profile(suggested)
              vim.notify("🤖 Auto-detected: " .. profile.name .. "\n" .. profile.description, vim.log.levels.INFO)
            end, desc = "Auto-detect Profile", buffer = bufnr },
            
            -- Spring Boot Profile Management
            { "<leader>jsp", group = "🍃 Spring Profiles", buffer = bufnr },
            { "<leader>jsps", function()
              java_profiles.select_spring_profiles(function(profiles)
                java_profiles.set_spring_profiles(profiles)
              end)
            end, desc = "Select Spring Profiles", buffer = bufnr },
            { "<leader>jspc", function()
              local current = java_profiles.get_active_spring_profiles()
              vim.notify("🍃 Current Spring Profiles: " .. current, vim.log.levels.INFO)
            end, desc = "Current Spring Profiles", buffer = bufnr },
            { "<leader>jspr", function()
              java_profiles.scan_spring_profiles()
              local profiles = table.concat(java_profiles.spring_profiles, ", ")
              vim.notify("🔍 Detected Spring Profiles: " .. profiles, vim.log.levels.INFO)
            end, desc = "Scan Spring Profiles", buffer = bufnr },
            { "<leader>jspd", function() java_profiles.set_spring_profiles("dev") end, desc = "Set to Dev", buffer = bufnr },
            { "<leader>jspl", function() java_profiles.set_spring_profiles("lcl") end, desc = "Set to Local", buffer = bufnr },
            { "<leader>jspp", function() java_profiles.set_spring_profiles("prd") end, desc = "Set to Production", buffer = bufnr },
            { "<leader>jsph", function() java_profiles.set_spring_profiles("lcl,hunterio") end, desc = "Set to Local+Hunter.io", buffer = bufnr },
            
            -- Quick profile switches (simplified)
            { "<leader>jsd", function() java_profiles.quick_switch("default") end, desc = "Switch to Default Spring", buffer = bufnr },
            { "<leader>jse", function() java_profiles.quick_switch("spring") end, desc = "Switch to Enhanced Spring", buffer = bufnr },
          })
          
          -- Add Spring Boot run commands
          which_key.add({
            { "<leader>jr", group = "▶️ Run", buffer = bufnr },
            { "<leader>jra", "<F5>", desc = "Run Application (F5)", buffer = bufnr },
            { "<leader>jrd", "<F6>", desc = "Debug Application (F6)", buffer = bufnr },
            { "<leader>jrs", function() require('jdtls').jshell() end, desc = "Open JShell", buffer = bufnr },
            { "<leader>jrb", function() require('jdtls').javap() end, desc = "Show Bytecode", buffer = bufnr },
            
            -- Spring Boot specific runs with profiles
            { "<leader>jrS", group = "🍃 Spring Boot", buffer = bufnr },
            { "<leader>jrSr", function() java_profiles.run_spring_app() end, desc = "Run with Current Profiles", buffer = bufnr },
            { "<leader>jrSd", function() java_profiles.run_spring_app("dev") end, desc = "Run with Dev Profile", buffer = bufnr },
            { "<leader>jrSl", function() java_profiles.run_spring_app("lcl") end, desc = "Run with Local Profile", buffer = bufnr },
            { "<leader>jrSp", function() java_profiles.run_spring_app("prd") end, desc = "Run with Production Profile", buffer = bufnr },
            { "<leader>jrSh", function() java_profiles.run_spring_app("lcl,hunterio") end, desc = "Run with Local+Hunter.io", buffer = bufnr },
            { "<leader>jrSs", function()
              java_profiles.select_spring_profiles(function(profiles)
                java_profiles.run_spring_app(profiles)
              end)
            end, desc = "Run with Selected Profiles", buffer = bufnr },
          })
        end      
      vim.notify("📋 Java profiles system loaded", vim.log.levels.INFO)
    end
  end,
}

-- ===============================================
-- 🚀 APPLY PROFILE AND START JDTLS
-- ===============================================

-- Apply the selected profile to the base configuration
local final_config = profile_manager.apply_profile(selected_profile, config)

-- Start or attach to JDTLS with profile-enhanced configuration
require('jdtls').start_or_attach(final_config)

-- Auto-commands for Java development
local java_group = vim.api.nvim_create_augroup("JavaLSP", { clear = true })

-- Organize imports on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = java_group,
  pattern = "*.java",
  callback = function()
    require('jdtls').organize_imports()
  end,
  desc = "Organize imports before saving Java files",
})

-- Setup completion for Java
vim.api.nvim_create_autocmd("FileType", {
  group = java_group,
  pattern = "java",
  callback = function()
    -- Enhanced completion for Java
    vim.opt_local.completeopt = "menu,menuone,noselect"
  end,
  desc = "Setup Java completion",
})

-- ===============================================
-- 🎛️ USER COMMANDS FOR PROFILE MANAGEMENT
-- ===============================================

-- Command to switch Java profiles
vim.api.nvim_create_user_command("JavaProfile", function(opts)
  local profile_manager = require("custom.java-profiles")
  
  if opts.args == "" then
    -- Show current profile and available options
    local current = profile_manager.get_current_profile()
    local profiles = profile_manager.list_profiles()
    
    local message = "🎯 Current Profile: " .. current.name .. "\n" .. current.description .. "\n\n📋 Available Profiles:\n"
    for _, profile in ipairs(profiles) do
      message = message .. "• " .. profile.display_name .. " - " .. profile.description .. "\n"
    end
    message = message .. "\nUsage: :JavaProfile <profile_name>"
    
    vim.notify(message, vim.log.levels.INFO)
  else
    -- Switch to specified profile
    local profile_name = opts.args
    if profile_manager.quick_switch(profile_name) then
      vim.notify("🔄 Switched to profile: " .. profile_manager.get_profile(profile_name).name .. "\nRestart Neovim to apply changes.", vim.log.levels.WARN)
    end
  end
end, {
  nargs = "?",
  complete = function()
    local profile_manager = require("custom.java-profiles")
    local profiles = profile_manager.list_profiles()
    local names = {}
    for _, profile in ipairs(profiles) do
      table.insert(names, profile.name)
    end
    return names
  end,
  desc = "Manage Java development profiles"
})

-- Command to auto-detect and suggest profile
vim.api.nvim_create_user_command("JavaProfileDetect", function()
  local profile_manager = require("custom.java-profiles")
  local suggested = profile_manager.auto_detect_profile()
  local profile = profile_manager.get_profile(suggested)
  
  local message = "🤖 Auto-detected Profile: " .. profile.name .. "\n" .. profile.description
  if suggested ~= profile_manager.current_profile then
    message = message .. "\n\n💡 Consider switching: :JavaProfile " .. suggested
  else
    message = message .. "\n\n✅ Already using the suggested profile!"
  end
  
  vim.notify(message, vim.log.levels.INFO)
end, {
  desc = "Auto-detect suitable Java profile for current project"
})

-- Command to show detailed profile information
vim.api.nvim_create_user_command("JavaProfileInfo", function(opts)
  local profile_manager = require("custom.java-profiles")
  local profile_name = opts.args ~= "" and opts.args or profile_manager.current_profile
  local profile = profile_manager.get_profile(profile_name)
  
  local message = "📋 Profile: " .. profile.name .. "\n\n"
  message = message .. "Description: " .. profile.description .. "\n\n"
  
  -- Show some key settings
  if profile.settings and profile.settings.java then
    local java_settings = profile.settings.java
    
    if java_settings.completion and java_settings.completion.maxResults then
      message = message .. "Max Completion Results: " .. java_settings.completion.maxResults .. "\n"
    end
    
    if java_settings.sources and java_settings.sources.organizeImports then
      local imports = java_settings.sources.organizeImports
      message = message .. "Import Thresholds: " .. (imports.starThreshold or "default") .. " (star), " .. (imports.staticStarThreshold or "default") .. " (static)\n"
    end
    
    if java_settings.completion and java_settings.completion.favoriteStaticMembers then
      local count = #java_settings.completion.favoriteStaticMembers
      message = message .. "Favorite Static Members: " .. count .. " configured\n"
    end
  end
  
  -- Show Spring profile info
  local spring_profiles = profile_manager.get_active_spring_profiles()
  message = message .. "\n🍃 Active Spring Profiles: " .. spring_profiles .. "\n"
  
  vim.notify(message, vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = function()
    local profile_manager = require("custom.java-profiles")
    local profiles = profile_manager.list_profiles()
    local names = {}
    for _, profile in ipairs(profiles) do
      table.insert(names, profile.name)
    end
    return names
  end,
  desc = "Show detailed information about a Java profile"
})

-- Spring Boot Commands
vim.api.nvim_create_user_command("SpringRun", function(opts)
  local profile_manager = require("custom.java-profiles")
  local profiles = opts.args ~= "" and opts.args or nil
  profile_manager.run_spring_app(profiles)
end, {
  nargs = "?",
  desc = "Run Spring Boot application with specified profiles"
})

vim.api.nvim_create_user_command("SpringProfiles", function(opts)
  local profile_manager = require("custom.java-profiles")
  
  if opts.args == "" then
    -- Show current and available profiles
    profile_manager.scan_spring_profiles()
    local current = profile_manager.get_active_spring_profiles()
    local available = table.concat(profile_manager.spring_profiles, ", ")
    
    local message = "🍃 Current Spring Profiles: " .. current .. "\n\n"
    message = message .. "📋 Available Spring Profiles: " .. available .. "\n\n"
    message = message .. "Usage: :SpringProfiles <profile1,profile2,...>"
    
    vim.notify(message, vim.log.levels.INFO)
  else
    -- Set Spring profiles
    profile_manager.set_spring_profiles(opts.args)
  end
end, {
  nargs = "?",
  complete = function()
    local profile_manager = require("custom.java-profiles")
    profile_manager.scan_spring_profiles()
    return profile_manager.spring_profiles
  end,
  desc = "Manage Spring Boot application profiles"
})
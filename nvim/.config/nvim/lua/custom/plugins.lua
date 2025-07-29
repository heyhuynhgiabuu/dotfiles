local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- Icons support for better UI
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {},
      default = true,
    }
  },

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Conform.nvim handles formatting now (replaces null-ls)
      {
        "stevearc/conform.nvim",
        config = function()
          require "custom.configs.conform"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.lsp-config"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Enhanced completions with better Go/Java support
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help", -- Enhanced function signatures
      "ray-x/cmp-treesitter", -- Better code structure completions
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
          }),
        },
        formatting = {
          format = function(entry, vim_item)
            -- Add source indicators for better visibility
            local source_mapping = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
              treesitter = "[TS]",
              nvim_lsp_signature_help = "[Sig]",
            }
            vim_item.menu = source_mapping[entry.source.name] or "[Other]"
            return vim_item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ 
            behavior = cmp.ConfirmBehavior.Replace,
            select = true 
          }),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          -- Enhanced Tab completion for snippets
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000, trigger_characters = { "." } },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 800 },
          { name = "treesitter", priority = 700 },
        }, {
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        }),
        completion = {
          completeopt = "menu,menuone,noinsert",
          autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
        },
        experimental = {
          ghost_text = true, -- Show preview text
        },
      })
      
      -- Enhanced Go completion
      cmp.setup.filetype('go', {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000, trigger_characters = { ".", ":" } },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 800 },
        }, {
          { name = "buffer", keyword_length = 2 },
          { name = "path" },
        }),
        completion = {
          autocomplete = {
            require('cmp.types').cmp.TriggerEvent.TextChanged,
            require('cmp.types').cmp.TriggerEvent.InsertEnter,
          },
        },
      })
      
      -- Enhanced Java completion
      cmp.setup.filetype('java', {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 800 },
        }, {
          { name = "buffer", keyword_length = 2 },
          { name = "path" },
        })
      })
      
      -- Enhanced Command Line Completion
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },

  -- Go development enhancements
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- Enhanced Go development features
        goimport = "gopls", -- Use gopls for imports
        gofmt = "gofumpt", -- Use gofumpt for formatting
        max_line_len = 120,
        tag_transform = false,
        test_template = "", -- Default test template
        test_template_dir = "", -- Default test template directory
        comment_placeholder = "   ",
        icons = { breakpoint = "🧘", currentpos = "🏃" },
        verbose = false,
        log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
        lsp_cfg = false, -- We handle LSP config separately
        lsp_gofumpt = false, -- Disable auto-formatting to avoid conflicts
        lsp_on_attach = false, -- We handle this in lsp-config
        dap_debug = true,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- Enhanced Java development with nvim-java (IntelliJ-like experience)
  {
    "nvim-java/nvim-java",
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-refactor",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      {
        "JavaHello/spring-boot.nvim",
        commit = "218c0c26c14d99feca778e4d13f5ec3e8b1b60f0",
      },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          require("dapui").setup({
            -- Enhanced DAP UI for better debugging experience
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.25 },
                  { id = "breakpoints", size = 0.25 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                position = "left",
                size = 40
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                position = "bottom",
                size = 10
              }
            },
          })
          
          -- Auto-open/close DAP UI
          local dap, dapui = require("dap"), require("dapui")
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      {
        "williamboman/mason.nvim",
        -- nvim-java handles registry configuration automatically
        -- Do not override registries here to avoid conflicts
      },
    },
    ft = { "java" },
    config = function()
      -- Setup nvim-java BEFORE lspconfig (critical for proper initialization)
      require("java").setup({
        -- Enhanced configuration for better IntelliJ-like experience
        root_markers = {
          'settings.gradle',
          'settings.gradle.kts', 
          'pom.xml',
          'build.gradle',
          'build.gradle.kts',
          'mvnw',
          'gradlew',
          '.git',
        },
        
        -- Use latest stable versions
        jdtls = {
          version = 'v1.43.0',
        },
        
        -- Enable all modern Java development features
        java_test = {
          enable = true,
          version = '0.40.1',
        },
        
        java_debug_adapter = {
          enable = true,
          version = '0.58.1',
        },
        
        spring_boot_tools = {
          enable = true,
          version = '1.55.1',
        },
        
        lombok = {
          version = 'nightly',
        },
        
        -- Auto-install JDK for convenience
        jdk = {
          auto_install = true,
          version = '17.0.2', -- LTS version, good for most projects
        },
        
        -- Enhanced notifications
        notifications = {
          dap = true,
        },
        
        verification = {
          invalid_order = true,
          duplicate_setup_calls = true,
          invalid_mason_registry = false,
        },
      })
      
      -- Setup lspconfig AFTER nvim-java (critical order)
      require('lspconfig').jdtls.setup({
        -- nvim-java handles all the JDTLS configuration automatically
        -- You can add custom settings here if needed
        settings = {
          java = {
            -- Enhanced Java settings for better IntelliJ-like experience
            signatureHelp = { enabled = true },
            maven = { downloadSources = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            inlayHints = {
              parameterNames = { enabled = 'all' },
            },
            format = { enabled = true }, -- Enable formatting
            saveActions = {
              organizeImports = true,
            },
          },
        },
      })
      
      -- Enhanced DAP configuration for Java debugging
      local dap = require('dap')
      
      -- Java-specific DAP keymaps (IntelliJ-style)
      local keymap = vim.keymap.set
      
      -- === BUILD & RUN (like IntelliJ) ===
      keymap("n", "<leader>jr", "<cmd>JavaRunnerRunMain<CR>", { desc = "Java - Run Main Class" })
      keymap("n", "<leader>js", "<cmd>JavaRunnerStopMain<CR>", { desc = "Java - Stop Running Application" })
      keymap("n", "<leader>jl", "<cmd>JavaRunnerToggleLogs<CR>", { desc = "Java - Toggle Logs" })
      keymap("n", "<leader>jb", "<cmd>JavaBuildBuildWorkspace<CR>", { desc = "Java - Build Workspace" })
      keymap("n", "<leader>jc", "<cmd>JavaBuildCleanWorkspace<CR>", { desc = "Java - Clean Workspace" })
      
      -- === TESTING (like IntelliJ Test Runner) ===
      keymap("n", "<leader>jtc", "<cmd>JavaTestRunCurrentClass<CR>", { desc = "Java - Run Test Class" })
      keymap("n", "<leader>jtm", "<cmd>JavaTestRunCurrentMethod<CR>", { desc = "Java - Run Test Method" })
      keymap("n", "<leader>jtd", "<cmd>JavaTestDebugCurrentClass<CR>", { desc = "Java - Debug Test Class" })
      keymap("n", "<leader>jtM", "<cmd>JavaTestDebugCurrentMethod<CR>", { desc = "Java - Debug Test Method" })
      keymap("n", "<leader>jtr", "<cmd>JavaTestViewLastReport<CR>", { desc = "Java - View Test Report" })
      
      -- === REFACTORING (like IntelliJ Refactor menu) ===
      keymap("n", "<leader>jxv", "<cmd>JavaRefactorExtractVariable<CR>", { desc = "Java - Extract Variable" })
      keymap("v", "<leader>jxv", "<cmd>JavaRefactorExtractVariable<CR>", { desc = "Java - Extract Variable" })
      keymap("n", "<leader>jxV", "<cmd>JavaRefactorExtractVariableAllOccurrence<CR>", { desc = "Java - Extract Variable (All)" })
      keymap("v", "<leader>jxV", "<cmd>JavaRefactorExtractVariableAllOccurrence<CR>", { desc = "Java - Extract Variable (All)" })
      keymap("n", "<leader>jxc", "<cmd>JavaRefactorExtractConstant<CR>", { desc = "Java - Extract Constant" })
      keymap("v", "<leader>jxc", "<cmd>JavaRefactorExtractConstant<CR>", { desc = "Java - Extract Constant" })
      keymap("n", "<leader>jxm", "<cmd>JavaRefactorExtractMethod<CR>", { desc = "Java - Extract Method" })
      keymap("v", "<leader>jxm", "<cmd>JavaRefactorExtractMethod<CR>", { desc = "Java - Extract Method" })
      keymap("n", "<leader>jxf", "<cmd>JavaRefactorExtractField<CR>", { desc = "Java - Extract Field" })
      keymap("v", "<leader>jxf", "<cmd>JavaRefactorExtractField<CR>", { desc = "Java - Extract Field" })
      
      -- === DEBUGGING (like IntelliJ Debugger) ===
      keymap("n", "<leader>jd", "<cmd>JavaDapConfig<CR>", { desc = "Java - Configure DAP" })
      
      -- Standard DAP controls (like IntelliJ debug toolbar)
      keymap("n", "<F5>", function() dap.continue() end, { desc = "Debug - Continue" })
      keymap("n", "<F6>", function() dap.step_over() end, { desc = "Debug - Step Over" })
      keymap("n", "<F7>", function() dap.step_into() end, { desc = "Debug - Step Into" })
      keymap("n", "<F8>", function() dap.step_out() end, { desc = "Debug - Step Out" })
      keymap("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Debug - Toggle Breakpoint" })
      keymap("n", "<leader>dB", function() 
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) 
      end, { desc = "Debug - Set Conditional Breakpoint" })
      keymap("n", "<leader>dr", function() dap.repl.open() end, { desc = "Debug - Open REPL" })
      keymap("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Debug - Toggle UI" })
      
      -- === PROFILES & SETTINGS (like IntelliJ Run Configurations) ===
      keymap("n", "<leader>jp", "<cmd>JavaProfile<CR>", { desc = "Java - Open Profiles" })
      keymap("n", "<leader>jk", "<cmd>JavaSettingsChangeRuntime<CR>", { desc = "Java - Change JDK Runtime" })
      
      -- === QUICK ACCESS (IntelliJ-style shortcuts) ===
      keymap("n", "<F9>", "<cmd>JavaTestRunCurrentClass<CR>", { desc = "Java - Run Tests (F9)" })
      keymap("n", "<F10>", "<cmd>JavaRunnerRunMain<CR>", { desc = "Java - Run Main (F10)" })
      keymap("n", "<S-F9>", "<cmd>JavaTestDebugCurrentClass<CR>", { desc = "Java - Debug Tests (Shift+F9)" })
      keymap("n", "<S-F10>", function()
        -- Debug main class (requires DAP setup)
        vim.cmd("JavaDapConfig")
        vim.defer_fn(function()
          dap.continue()
        end, 500)
      end, { desc = "Java - Debug Main (Shift+F10)" })
      
      -- Print setup success message
      vim.defer_fn(function()
        print("☕ nvim-java: IntelliJ-like Java environment ready!")
        print("📝 Use <leader>j* for Java commands | F9/F10 for quick run/test")
        print("🐛 Use F5-F8 for debugging | <leader>db for breakpoints")
      end, 2000)
    end,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup({
        mapping = {"jk", "jj"}, -- map jk and jj to escape
        timeout = vim.o.timeoutlen,
        clear_empty_lines = false,
        keys = "<Esc>",
      })
    end,
  },

  -- Which-key for displaying keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "whichkey")
      local wk = require("which-key")
      
      -- Updated config for which-key v3+
      wk.setup({
        preset = "modern",
        delay = 200,
        expand = 1,
        notify = true,
        -- Key mappings are now configured using spec
        spec = {},
        -- Icons configuration
        icons = {
          breadcrumb = "»",
          separator = "➜", 
          group = "+",
          ellipsis = "…",
          mappings = true,
          rules = {},
          colors = true,
          keys = {
            Up = " ",
            Down = " ",
            Left = " ",
            Right = " ",
            C = "󰘴 ",
            M = "󰘵 ",
            D = "󰘳 ",
            S = "󰘶 ",
            CR = "󰌑 ",
            Esc = "󱊷 ",
            ScrollWheelDown = "󱕐 ",
            ScrollWheelUp = "󱕑 ",
            NL = "󰌑 ",
            BS = "󰁮",
            Space = "󱁐 ",
            Tab = "󰌒 ",
          },
        },
        win = {
          border = "rounded",
          padding = { 1, 2 },
          wo = {
            winblend = 0,
          },
        },
        layout = {
          width = { min = 20 },
          spacing = 3,
        },
        keys = {
          scroll_down = "<c-d>",
          scroll_up = "<c-u>",
        },
        sort = { "local", "order", "group", "alphanum", "mod" },
        expand = 0,
        replace = {
          key = {
            function(key)
              return require("which-key.view").format(key)
            end,
          },
        },
      })
      
      -- Register groups using add method
      wk.add({
        { "<leader>f", group = "File" },
        { "<leader>l", group = "LSP" },
        { "<leader>g", group = "Git/Go" },
        { "<leader>j", group = "Java" },
        { "<leader>jr", group = "Java Run" },
        { "<leader>jt", group = "Java Test" },
        { "<leader>jx", group = "Java Refactor" },
        { "<leader>t", group = "Terminal" },
        { "<leader>w", group = "Window" },
        { "<leader>b", group = "Buffer" },
        { "<leader>d", group = "Debug" },
        { "<leader>s", group = "Search" },
        { "<leader>h", group = "Help" },
        { "<leader>a", group = "AugmentCode" },
        { "<leader>v", group = "View/Visual" },
        { "<leader>vt", desc = "Show directory tree in floating window" },
        { "<leader>tv", desc = "New vertical terminal" },
        { "<leader>tn", desc = "Toggle line number" },
        { "<leader>aw", desc = "Show workspace folders" },
        { "<leader>aW", desc = "Add current directory to workspace" },
        { "<leader>aF", desc = "Add custom folder to workspace" },
      })
    end,
  },

  -- AugmentCode AI integration (single AI solution)
  {
    "augmentcode/augment.vim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      -- CRITICAL: Set workspace folders BEFORE plugin loads (per official docs)
      -- Load workspace folders from global config or set defaults
      local workspace_config = vim.fn.expand("~/.config/augment/workspace_folders.conf")
      local workspace_folders = {}
      
      -- Try to load from config file first
      if vim.fn.filereadable(workspace_config) == 1 then
        local lines = vim.fn.readfile(workspace_config)
        for _, line in ipairs(lines) do
          line = vim.trim(line)
          -- Skip comments and empty lines
          if line ~= "" and not vim.startswith(line, "#") and not vim.startswith(line, "!") then
            -- Expand home directory
            if vim.startswith(line, "~/") then
              line = vim.fn.expand(line)
            end
            -- Only add if directory exists
            if vim.fn.isdirectory(line) == 1 then
              table.insert(workspace_folders, line)
            end
          end
        end
      end
      
      -- Set default workspace folders if none found
      if #workspace_folders == 0 then
        workspace_folders = {
          vim.fn.expand("~/projects"),
          vim.fn.expand("~/code"),
          vim.fn.expand("~/dotfiles"),
          vim.fn.getcwd(), -- Always include current working directory
        }
        -- Filter to only existing directories
        workspace_folders = vim.tbl_filter(function(path)
          return vim.fn.isdirectory(path) == 1
        end, workspace_folders)
      end
      
      -- Set the workspace folders before plugin loads
      vim.g.augment_workspace_folders = workspace_folders
    end,
    config = function()
      -- AugmentCode as primary AI with clean, conflict-free setup
      -- Global config files: ~/.config/augment/ (symlinked from ~/dotfiles/augment/.config/augment/)
      
      -- Set official options for optimal single-AI experience
      vim.g.augment_disable_tab_mapping = true  -- CRITICAL: Disable to avoid nvim-cmp conflicts
      vim.g.augment_suppress_version_warning = false
      vim.g.augment_node_command = "node"
      
      -- Configure highlighting for AugmentCode suggestions
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'AugmentSuggestionHighlight', {
            fg = '#7dc4e4',  -- Nice blue color for primary AI
            ctermfg = 12,
            italic = true,
            force = true
          })
        end,
        desc = "AugmentCode - Set suggestion highlighting"
      })
      
      -- Apply highlighting for current colorscheme
      vim.api.nvim_set_hl(0, 'AugmentSuggestionHighlight', {
        fg = '#7dc4e4',
        ctermfg = 12,
        italic = true,
        force = true
      })
      
      -- Load project-specific configuration if it exists
      local project_config = vim.fn.getcwd() .. "/.augmentconfig"
      if vim.fn.filereadable(project_config) == 1 then
        vim.cmd("source " .. project_config)
      end
      
      -- AugmentCode keymaps (clean, single-AI setup)
      local keymap = vim.keymap.set
      
      -- Chat commands (official)
      keymap("n", "<leader>ac", ":Augment chat ", { desc = "AugmentCode - Send chat message" })
      keymap("v", "<leader>ac", ":Augment chat ", { desc = "AugmentCode - Chat about selection" })
      keymap("n", "<leader>an", "<cmd>Augment chat-new<CR>", { desc = "AugmentCode - New chat conversation" })
      keymap("n", "<leader>at", "<cmd>Augment chat-toggle<CR>", { desc = "AugmentCode - Toggle chat panel" })
      
      -- Status and management (official)
      keymap("n", "<leader>as", "<cmd>Augment status<CR>", { desc = "AugmentCode - Show status" })
      keymap("n", "<leader>al", "<cmd>Augment log<CR>", { desc = "AugmentCode - Show log" })
      
      -- Authentication (official)
      keymap("n", "<leader>ai", "<cmd>Augment signin<CR>", { desc = "AugmentCode - Sign in" })
      keymap("n", "<leader>ao", "<cmd>Augment signout<CR>", { desc = "AugmentCode - Sign out" })
      
      -- Completion control via variables
      keymap("n", "<leader>ae", function()
        vim.g.augment_disable_completions = false
        print("AugmentCode completions enabled")
      end, { desc = "AugmentCode - Enable completions" })
      
      keymap("n", "<leader>ad", function()
        vim.g.augment_disable_completions = true
        print("AugmentCode completions disabled")
      end, { desc = "AugmentCode - Disable completions" })
      
      -- Workspace folder management (per official docs)
      keymap("n", "<leader>aw", function()
        local folders = vim.g.augment_workspace_folders or {}
        print("🔮 AugmentCode Workspace Folders:")
        if #folders == 0 then
          print("   No workspace folders configured")
        else
          for i, folder in ipairs(folders) do
            print(string.format("   %d. %s", i, folder))
          end
        end
        print("Use <leader>aW to add current directory")
      end, { desc = "AugmentCode - Show workspace folders" })
      
      keymap("n", "<leader>aW", function()
        local current_dir = vim.fn.getcwd()
        local folders = vim.g.augment_workspace_folders or {}
        
        -- Check if current directory is already in workspace
        for _, folder in ipairs(folders) do
          if folder == current_dir then
            print("Current directory already in workspace: " .. current_dir)
            return
          end
        end
        
        -- Add current directory to workspace
        table.insert(folders, current_dir)
        vim.g.augment_workspace_folders = folders
        
        print("Added to workspace: " .. current_dir)
        print("Restart Neovim to sync new workspace folder")
      end, { desc = "AugmentCode - Add current directory to workspace" })
      
      keymap("n", "<leader>aF", function()
        vim.ui.input({ prompt = "Enter workspace folder path: " }, function(input)
          if input and input ~= "" then
            local path = vim.fn.expand(input)
            if vim.fn.isdirectory(path) == 1 then
              local folders = vim.g.augment_workspace_folders or {}
              table.insert(folders, path)
              vim.g.augment_workspace_folders = folders
              print("Added to workspace: " .. path)
              print("Restart Neovim to sync new workspace folder")
            else
              print("Directory not found: " .. path)
            end
          end
        end)
      end, { desc = "AugmentCode - Add custom folder to workspace" })
      
      -- Completion acceptance - CONFLICT-FREE keys only
      -- Using Ctrl-L as primary (safe, no conflicts with nvim-cmp)
      keymap("i", "<C-l>", function()
        if vim.fn.exists('*augment#Accept') == 1 then
          -- Check if we're in a safe context to accept
          if vim.fn.mode() == 'i' then
            local result = vim.fn['augment#Accept']()
            if result and result ~= "" then
              return result
            end
          end
        end
        return ""
      end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion" })
      
      -- Alternative: Ctrl-J (safe, commonly used for acceptance)
      keymap("i", "<C-j>", function()
        if vim.fn.exists('*augment#Accept') == 1 then
          if vim.fn.mode() == 'i' then
            local result = vim.fn['augment#Accept']()
            if result and result ~= "" then
              return result
            end
          end
        end
        return ""
      end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion (alt)" })
      
      -- Fallback: Ctrl-Y (very safe, standard vim)
      keymap("i", "<C-y>", function()
        if vim.fn.exists('*augment#Accept') == 1 then
          if vim.fn.mode() == 'i' then
            local result = vim.fn['augment#Accept']()
            if result and result ~= "" then
              return result
            end
          end
        end
        return "<C-y>"  -- Fallback to normal Ctrl-Y
      end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion or scroll up" })
      
      -- Print startup message
      vim.defer_fn(function()
        local folders = vim.g.augment_workspace_folders or {}
        print("🚀 AugmentCode: Primary AI ready | Ctrl-L to accept | <leader>ac for chat")
        print(string.format("📁 Workspace: %d folders configured | <leader>aw to view", #folders))
      end, 1000)
    end,
    event = "VeryLazy",
    cmd = { "Augment" },
  },

  -- UI Enhancement Plugins for IntelliJ-like Experience
  
  -- LSP Progress Notifications (shows "ServiceReady", "Configuring DAP", etc.)
  {
    "j-hui/fidget.nvim",
    event = "VimEnter",
    config = function()
      require("fidget").setup({
        notification = {
          window = {
            normal_hl = "Comment",
            winblend = 0,
            border = "none",
            zindex = 45,
            max_width = 0,
            max_height = 0,
            x_padding = 1,
            y_padding = 0,
            align = "bottom",
            relative = "editor",
          },
          view = {
            stack_upwards = false,
            icon_separator = " ",
            group_separator = "---",
            group_separator_hl = "Comment",
          },
        },
        progress = {
          poll_rate = 0,
          suppress_on_insert = false,
          ignore_done_already = false,
          ignore_empty_message = false,
          clear_on_detach = function(client_id)
            local client = vim.lsp.get_client_by_id(client_id)
            return client and client.name or nil
          end,
          notification_group = function(msg)
            return msg.lsp_client.name
          end,
          ignore = {},
          display = {
            render_limit = 16,
            done_ttl = 3,
            done_icon = "✓",
            done_style = "Constant",
            progress_ttl = math.huge,
            progress_icon = { pattern = "dots", period = 1 },
            progress_style = "WarningMsg",
            group_style = "Title",
            icon_style = "Question",
            priority = 30,
            skip_history = true,
            format_message = require("fidget.progress.display").default_format_message,
            format_annote = function(msg)
              return msg.title
            end,
            format_group_name = function(group)
              return tostring(group)
            end,
            overrides = {
              rust_analyzer = { name = "rust-analyzer" },
              jdtls = { name = "☕ Java LSP" },
            },
          },
        },
        integration = {
          ["nvim-tree"] = {
            enable = true,
          },
        },
        logger = {
          level = vim.log.levels.WARN,
          max_size = 10000,
          float_precision = 0.01,
          path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
        },
      })
    end,
  },

  -- Enhanced Notifications (replaces basic vim.notify)
  {
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        fps = 30,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = ""
        },
        level = 2,
        minimum_width = 50,
        render = "compact",
        stages = "fade_in_slide_out",
        time_formats = {
          notification = "%T",
          notification_history = "%FT%T"
        },
        timeout = 3000,
        top_down = true
      })
      
      -- Set nvim-notify as default notification handler
      vim.notify = require("notify")
      
      -- Key mapping to view notification history
      vim.keymap.set("n", "<leader>nh", function()
        require("notify").history()
      end, { desc = "Show notification history" })
      
      -- Key mapping to dismiss all notifications
      vim.keymap.set("n", "<leader>nd", function()
        require("notify").dismiss({ silent = true, pending = true })
      end, { desc = "Dismiss all notifications" })
    end,
  },

  -- Diagnostics Panel (for validation messages and error display)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
      require("trouble").setup({
        position = "bottom",
        height = 10,
        width = 50,
        icons = true,
        mode = "workspace_diagnostics",
        severity = nil,
        fold_open = "",
        fold_closed = "",
        group = true,
        padding = true,
        cycle_results = true,
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = { "<cr>", "<tab>" },
          open_split = { "<c-x>" },
          open_vsplit = { "<c-v>" },
          open_tab = { "<c-t>" },
          jump_close = { "o" },
          toggle_mode = "m",
          switch_severity = "s",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          open_code_href = "c",
          close_folds = { "zM", "zm" },
          open_folds = { "zR", "zr" },
          toggle_fold = { "zA", "za" },
          previous = "k",
          next = "j",
          help = "?"
        },
        multiline = true,
        indent_lines = true,
        win_config = { border = "single" },
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { "lsp_definitions" },
        include_declaration = true,
        signs = {
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "",
        },
        use_diagnostic_signs = true
      })
      
      -- Key mappings for trouble
      vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
      vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = "Workspace Diagnostics" })
      vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = "Document Diagnostics" })
      vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "Quickfix" })
      vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end, { desc = "Location List" })
      vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = "LSP References" })
    end,
  },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}
return plugins

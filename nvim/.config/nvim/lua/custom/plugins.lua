local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- nvim-nio (required dependency for nvim-dap-ui)
  {
    "nvim-neotest/nvim-nio",
    lazy = false,
  },

  -- neoconf.nvim for professional LSP configuration management
  -- CRITICAL: Must be loaded BEFORE nvim-lspconfig
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    config = function()
      require("neoconf").setup({
        -- import existing settings from other plugins
        import = {
          vscode = true, -- local .vscode/settings.json
          coc = false,   -- global/local coc-settings.json (disabled - we don't use coc)
          nlsp = false,  -- global/local nlsp-settings.nvim (disabled - not needed)
        },
        -- send new configuration to lsp clients when changing json settings
        live_reload = true,
        -- set the filetype to jsonc for settings files with comments
        filetype_jsonc = true,
        plugins = {
          lspconfig = {
            enabled = true,
          },
          jsonls = {
            enabled = true,
            configured_servers_only = true,
          },
          lua_ls = {
            enabled_for_neovim_config = true,
          },
        },
      })
    end,
  },

  -- nvim-dap (Debug Adapter Protocol) for debugging support
  -- MUST be loaded before nvim-jdtls to ensure proper integration
  {
    'mfussenegger/nvim-dap',
    lazy = false, -- Load immediately to ensure availability
    config = function()
      -- Basic DAP setup - detailed config is in dap-config.lua
      local dap = require("dap")
      vim.notify("🐛 nvim-dap loaded successfully", vim.log.levels.INFO)
    end,
  },

  -- nvim-dap-ui for IntelliJ-like debugging UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    lazy = false,
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      
      -- Setup dap-ui with IntelliJ-like layout
      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.notify("🐛 Debug session started - DAP UI opened", vim.log.levels.INFO)
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        vim.notify("🏁 Debug session ended - DAP UI closed", vim.log.levels.INFO)
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        vim.notify("🚪 Debug session exited - DAP UI closed", vim.log.levels.INFO)
      end

      -- Additional keymaps for DAP UI
      vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<Leader>dE", function() dapui.eval() end, { desc = "Evaluate expression under cursor" })
      vim.keymap.set("v", "<Leader>dE", function() dapui.eval() end, { desc = "Evaluate selected expression" })
      vim.keymap.set("n", "<Leader>df", function() dapui.float_element() end, { desc = "Float DAP element" })
      
      vim.notify("🎨 nvim-dap-ui configured for IntelliJ-like debugging experience", vim.log.levels.INFO)
    end,
  },

  -- nvim-dap-virtual-text for inline variable values (like IntelliJ)
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter"
    },
    lazy = false,
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })
      
      vim.notify("💭 nvim-dap-virtual-text configured for inline variable display", vim.log.levels.INFO)
    end,
  },

  -- nvim-jdtls for professional Java development
  -- Stable, reliable JDTLS integration without Mason API issues
  {
    'mfussenegger/nvim-jdtls',
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
    },
    ft = { "java" },
    -- Configuration is handled in ftplugin/java.lua for proper per-project setup
  },

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
        mapping = cmp.mapping.preset.cmdline({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'c' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'c' }),
        }),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { 
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        }),
        completion = {
          autocomplete = { 
            require('cmp.types').cmp.TriggerEvent.TextChanged,
          },
        },
        formatting = {
          format = function(entry, vim_item)
            -- Enhanced formatting for command line
            local source_mapping = {
              cmdline = "[CMD]",
              path = "[Path]",
              buffer = "[Buf]",
            }
            vim_item.menu = source_mapping[entry.source.name] or "[Other]"
            return vim_item
          end,
        },
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
        { "<leader>jb", group = "Java Build" },
        { "<leader>jr", group = "Java Run" },
        { "<leader>jt", group = "Java Test" },
        { "<leader>jx", group = "Java Refactor" },
        { "<leader>jd", group = "Java Debug" },
        { "<leader>js", group = "Java Settings" },
        { "<leader>jg", group = "Java Go To" },
        { "<leader>jc", group = "Java Code" },
        { "<leader>t", group = "Terminal" },
        { "<leader>w", group = "Window" },
        { "<leader>b", group = "Buffer" },
        { "<leader>d", group = "Debug" },
        { "<leader>db", group = "Debug Breakpoints" },
        { "<leader>ds", group = "Debug Step" },
        { "<leader>dr", group = "Debug REPL/Restart" },
        { "<leader>dv", group = "Debug View/Eval" },
        { "<leader>s", group = "Search" },
        { "<leader>h", group = "Help" },
        { "<leader>a", group = "AugmentCode" },
        { "<leader>v", group = "View/Visual" },
        { "<leader>x", group = "Diagnostics/Quickfix" },
        { "<leader>vt", desc = "Show directory tree in floating window" },
        { "<leader>tv", desc = "New vertical terminal" },
        { "<leader>tn", desc = "Toggle line number" },
        { "<leader>aw", desc = "Show workspace folders" },
        { "<leader>aW", desc = "Add current directory to workspace" },
        { "<leader>aF", desc = "Add custom folder to workspace" },
        -- Debug hotkeys documentation
        { "<F5>", desc = "Start/Continue Debug" },
        { "<F6>", desc = "Pause Debug" },
        { "<F9>", desc = "Toggle Breakpoint" },
        { "<F10>", desc = "Step Over" },
        { "<F11>", desc = "Step Into" },
        { "<S-F11>", desc = "Step Out" },
        { "<S-F5>", desc = "Stop Debug" },
        { "<C-F5>", desc = "Restart Debug" },
        { "<leader>db", desc = "Toggle Breakpoint" },
        { "<leader>dB", desc = "Conditional Breakpoint" },
        { "<leader>dC", desc = "Clear All Breakpoints" },
        { "<leader>dc", desc = "Debug Continue" },
        { "<leader>dt", desc = "Debug Terminate" },
        { "<leader>dr", desc = "Debug Restart/REPL" },
        { "<leader>dh", desc = "Debug Help" },
        { "<leader>ds", desc = "Debug Show Scopes" },
        { "<leader>df", desc = "Debug Show Frames" },
        { "<leader>dv", desc = "Debug Hover/Eval" },
        { "<leader>de", desc = "Debug Evaluate Expression" },
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

  -- Enhanced Command Line UI with floating input
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- Enhanced command line with floating UI
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = {},
          format = {
            -- Conceal the long command-line when typing
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            input = {}, -- Used by input()
          },
        },
        messages = {
          -- NOTE: If you enable messages, then the cmdline is enabled automatically.
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },
        popupmenu = {
          enabled = true,
          backend = "nui", -- Use nui for better integration
          kind_icons = {}, -- Use default icons
        },
        -- Enhanced notifications
        notify = {
          enabled = true,
          view = "notify",
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
        },
        views = {
          cmdline_popup = {
            position = {
              row = 25,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            filter_options = {},
            win_options = {
              winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            },
          },
        },
      })
    end,
  },

  -- Enhanced search UI
  {
    "nvim-pack/nvim-spectre",
    event = "VeryLazy",
    config = function()
      require("spectre").setup({
        color_devicons = true,
        highlight = {
          ui = "String",
          search = "DiffChange",
          replace = "DiffDelete"
        },
        mapping = {
          ['toggle_line'] = {
            map = "dd",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle current item"
          },
          ['enter_file'] = {
            map = "<cr>",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "goto current file"
          },
          ['send_to_qf'] = {
            map = "<leader>q",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all item to quickfix"
          },
          ['replace_cmd'] = {
            map = "<leader>c",
            cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
            desc = "input replace vim command"
          },
          ['show_option_menu'] = {
            map = "<leader>o",
            cmd = "<cmd>lua require('spectre').show_options()<CR>",
            desc = "show option"
          },
          ['run_current_replace'] = {
            map = "<leader>rc",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line"
          },
          ['run_replace'] = {
            map = "<leader>R",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "replace all"
          },
          ['change_view_mode'] = {
            map = "<leader>v",
            cmd = "<cmd>lua require('spectre').change_view()<CR>",
            desc = "change result view mode"
          },
          ['change_replace_sed'] = {
            map = "trs",
            cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
            desc = "use sed to replace"
          },
          ['change_replace_oxi'] = {
            map = "tro",
            cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
            desc = "use oxi to replace"
          },
          ['toggle_live_update'] = {
            map = "tu",
            cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
            desc = "update change when vim write file."
          },
          ['toggle_ignore_case'] = {
            map = "ti",
            cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
            desc = "toggle ignore case"
          },
          ['toggle_ignore_hidden'] = {
            map = "th",
            cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
            desc = "toggle search hidden"
          },
          ['resume_last_search'] = {
            map = "<leader>l",
            cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
            desc = "resume last search before close"
          },
        },
        find_engine = {
          ['rg'] = {
            cmd = "rg",
            args = {
              '--color=never',
              '--no-heading',
              '--with-filename',
              '--line-number',
              '--column',
            },
            options = {
              ['ignore-case'] = {
                value = "--ignore-case",
                icon = "[I]",
                desc = "ignore case"
              },
              ['hidden'] = {
                value = "--hidden",
                desc = "hidden file",
                icon = "[H]"
              },
            }
          },
        },
        replace_engine = {
          ['sed'] = {
            cmd = "sed",
            args = nil,
            options = {
              ['ignore-case'] = {
                value = "--ignore-case",
                icon = "[I]",
                desc = "ignore case"
              },
            }
          },
        },
        default = {
          find = {
            cmd = "rg",
            options = {"ignore-case"}
          },
          replace = {
            cmd = "sed"
          }
        },
        replace_vim_cmd = "cdo",
        is_open = false,
        is_insert_mode = false,
      })
      
      -- Key mappings for spectre
      vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
        desc = "Toggle Spectre"
      })
      vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Search current word"
      })
      vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
        desc = "Search current word"
      })
      vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Search on current file"
      })
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

  -- Enhanced status line with more information
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            'branch',
            'diff',
            {
              'diagnostics',
              sources = { 'nvim_diagnostic', 'nvim_lsp' },
              sections = { 'error', 'warn', 'info', 'hint' },
              diagnostics_color = {
                error = 'DiagnosticError',
                warn  = 'DiagnosticWarn',
                info  = 'DiagnosticInfo',
                hint  = 'DiagnosticHint',
              },
              symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
              colored = true,
              update_in_insert = false,
              always_visible = false,
            }
          },
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 1, -- Relative path
              shorting_target = 40,
              symbols = {
                modified = '[+]',
                readonly = '[RO]',
                unnamed = '[No Name]',
                newfile = '[New]',
              }
            }
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            {
              -- Show LSP status
              function()
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                  return ""
                end
                
                local client_names = {}
                for _, client in pairs(clients) do
                  table.insert(client_names, client.name)
                end
                return " " .. table.concat(client_names, ", ")
              end,
              color = { fg = '#7dc4e4' },
            }
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {'nvim-tree', 'trouble', 'quickfix'}
      })
    end,
  },

  -- Enhanced buffer line with tabs and close buttons
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.default,
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = '▎',
            style = 'icon',
          },
          buffer_close_icon = '',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          max_name_length = 30,
          max_prefix_length = 30,
          truncate_names = true,
          tab_size = 21,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
          },
          sort_by = 'insert_after_current',
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true
            }
          },
        },
        highlights = {
          buffer_selected = {
            bold = true,
            italic = true,
          },
        },
      })
    end,
  },


  -- Enhanced terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = 'curved',
          width = function()
            return math.floor(vim.o.columns * 0.8)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.8)
          end,
          winblend = 0,
          zindex = 1000,
          title_pos = 'center',
        },
        winbar = {
          enabled = false,
          name_formatter = function(term)
            return term.name
          end
        },
      })
      
      -- Enhanced terminal key mappings
      local Terminal = require('toggleterm.terminal').Terminal
      
      -- Horizontal terminal
      local horizontal_term = Terminal:new({
        direction = "horizontal",
        size = 15,
      })
      
      -- Vertical terminal
      local vertical_term = Terminal:new({
        direction = "vertical",
        size = vim.o.columns * 0.4,
      })
      
      -- Lazygit terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "double",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
      })
      
      -- Key mappings
      vim.keymap.set("n", "<leader>tv", function() vertical_term:toggle() end, { desc = "New vertical terminal" })
      vim.keymap.set("n", "<leader>th", function() horizontal_term:toggle() end, { desc = "New horizontal terminal" })
      vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "New floating terminal" })
      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Open Lazygit" })
      
      -- Terminal mode mappings
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end
      
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
  },

  -- Enhanced indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          injected_languages = false,
          highlight = { "Function", "Label" },
          priority = 500,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })
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

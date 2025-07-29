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

  -- Java development enhancements
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      -- JDTLS configuration is handled by ftplugin/java.lua
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

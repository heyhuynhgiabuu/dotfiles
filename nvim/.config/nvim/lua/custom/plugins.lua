local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

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
        lsp_gofumpt = true,
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
      require("better_escape").setup()
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
      
      local default_opts = {
        plugins = { 
          spelling = true,
          presets = {
            operators = false, -- adds help for operators like d, y, ...
            motions = false, -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
          },
        },
        triggers_blacklist = {
          i = { "j", "k" },
          v = { "j", "k" },
        },
        window = {
          border = "rounded", -- none, single, double, shadow
          position = "bottom", -- bottom, top
          margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
          padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
          winblend = 0
        },
        layout = {
          height = { min = 4, max = 25 }, -- min and max height of the columns
          width = { min = 20, max = 50 }, -- min and max width of the columns
          spacing = 3, -- spacing between columns
          align = "left", -- align columns left, center or right
        },
      }
      
      wk.setup(vim.tbl_deep_extend("force", default_opts, opts or {}))
      
      -- Register some basic leader key descriptions
      wk.register({
        ["<leader>"] = {
          f = { name = "File" },
          l = { name = "LSP" },
          g = { name = "Git/Go" },
          j = { name = "Java" },
          t = { name = "Terminal" },
          w = { name = "Window" },
          b = { name = "Buffer" },
          d = { name = "Debug" },
          s = { name = "Search" },
          h = { name = "Help" },
        }
      })
    end,
  },

  -- GitHub Copilot integration
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Basic Copilot settings
      vim.g.copilot_enabled = true
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      -- Custom keymaps for Copilot
      vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion"
      })
      
      vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-o>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
      
      -- Enable Copilot for specific file types
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["gitcommit"] = true,
        ["markdown"] = true,
        ["yaml"] = true,
      }
    end,
  },

  -- GitHub Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
      show_help = "yes",
      prompts = {
        Explain = "Please explain how the following code works.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Tests = "Please generate tests for my code.",
        Refactor = "Please refactor the following code to improve its clarity and readability.",
        FixCode = "Please fix the following code to make it work as intended.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
        SwaggerJSDoc = "Please write JSDoc for the following API using Swagger.",
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)
      
      -- Keymaps for Copilot Chat
      vim.keymap.set("n", "<leader>cc", ":CopilotChat ", { desc = "CopilotChat - Open chat" })
      vim.keymap.set("n", "<leader>ce", "<cmd>CopilotChatExplain<cr>", { desc = "CopilotChat - Explain code" })
      vim.keymap.set("n", "<leader>ct", "<cmd>CopilotChatTests<cr>", { desc = "CopilotChat - Generate tests" })
      vim.keymap.set("n", "<leader>cr", "<cmd>CopilotChatReview<cr>", { desc = "CopilotChat - Review code" })
      vim.keymap.set("n", "<leader>cf", "<cmd>CopilotChatRefactor<cr>", { desc = "CopilotChat - Refactor code" })
      vim.keymap.set("n", "<leader>cd", "<cmd>CopilotChatDocumentation<cr>", { desc = "CopilotChat - Documentation" })
      
      -- Visual mode mappings
      vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<cr>", { desc = "CopilotChat - Explain code" })
      vim.keymap.set("v", "<leader>ct", ":CopilotChatTests<cr>", { desc = "CopilotChat - Generate tests" })
      vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<cr>", { desc = "CopilotChat - Review code" })
      vim.keymap.set("v", "<leader>cf", ":CopilotChatRefactor<cr>", { desc = "CopilotChat - Refactor code" })
    end,
    event = "VeryLazy",
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

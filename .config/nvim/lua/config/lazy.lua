-- GIAI ĐOẠN 2 - BƯỚC 2: PLUGIN NÂNG CAO
-- =====================================
--
-- File: ~/dotfiles/.config/nvim/lua/config/lazy.lua
-- Mục tiêu: Cấu hình các plugin UI, tìm kiếm, git, LSP & format nâng cao

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- UI & GIAO DIỆN
    { "nvim-lualine/lualine.nvim" },        -- Thanh trạng thái dưới
    { "akinsho/bufferline.nvim",           -- Hiển thị tab như VSCode
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup()
        end
    },

    -- FILE & GIT TOOL
    {
        "nvim-neo-tree/neo-tree.nvim",       -- File Explorer
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup()
        end
    },
    {
        "lewis6991/gitsigns.nvim",           -- Git thay đổi bên lề trái
        config = function()
            require("gitsigns").setup()
        end
    },

    -- SEARCH & FINDER
    {
        "nvim-telescope/telescope.nvim",     -- Tìm file, symbol, lệnh, v.v.
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            telescope.setup()
            local buildin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", buildin.find_files, { desc = "Tìm file" })
            vim.keymap.set("n", "<leader>fg", buildin.live_grep, { desc = "Tìm text trong project" })
            vim.keymap.set("n", "<leader>fb", buildin.buffers, { desc = "Tìm bufer đang mở" })
            vim.keymap.set("n", "<leader>ft", buildin.help_tags, { desc = "Tìm help tags" })
        end
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = vim.fn.executable("make") == 1,
    },

    -- AUTOCOMPLETE & LSP
   "hrsh7th/nvim-cmp",                    -- Engine chính cho autocomplete
    "hrsh7th/cmp-nvim-lsp",                -- Nguồn lấy từ LSP
    "hrsh7th/cmp-buffer",                  -- Autocomplete từ buffer
    "hrsh7th/cmp-path",                    -- Autocomplete path
    "onsails/lspkind.nvim",                -- Hiển thị icon đẹp khi gợi ý

    -- SNIPPET & LUA
    "L3MON4D3/LuaSnip",                    -- Snippet Engine

    -- TREESITTER
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "markdown", "bash", "python", "javascript", "html", "css", "java" },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = { enable = true },
            })
        end
    },

    -- LSP CONFIG
    "neovim/nvim-lspconfig",               -- Cấu hình LSP
    {
        "williamboman/mason.nvim",           -- UI cài LSP dễ hơn
        config = function()
            require("mason").setup()
        end
    },
    "mfussenegger/nvim-jdtls", -- Java LSP hỗ trợ jdtls

    -- FORMATTER
    "mhartington/formatter.nvim",          -- Format code theo file
    {
        "folke/which-key.nvim",
        config =function()
            require("which-key").setup()
        end
    },
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end
    },
})


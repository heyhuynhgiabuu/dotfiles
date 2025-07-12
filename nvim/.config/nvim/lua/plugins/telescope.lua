-- Advanced Search & Finder
return {
    {
        "nvim-telescope/telescope.nvim",
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
}

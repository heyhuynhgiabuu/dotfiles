-- Advanced File Explorer
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup()
        vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
    end
}

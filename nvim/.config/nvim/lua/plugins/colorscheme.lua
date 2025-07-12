-- Colorscheme Plugins
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end
    },
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme("tokyonight")
        end
    },
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme("onedark")
        end
    },
}
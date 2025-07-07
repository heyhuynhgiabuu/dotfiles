-- Advanced Noice
return {
    "folke/noice.nvim",
    dependencies = { "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup()
    end
}
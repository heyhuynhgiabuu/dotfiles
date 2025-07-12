-- Advanced Markdown Preview
return {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
}
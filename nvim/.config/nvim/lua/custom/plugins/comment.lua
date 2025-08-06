return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  config = function()
    require("Comment").setup()
    -- Keymap mặc định:
    -- gcc: comment dòng hiện tại (normal mode)
    -- gc: comment khối đã chọn (visual mode)
  end,
}

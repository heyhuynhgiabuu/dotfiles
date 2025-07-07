local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>e", ":Neotree toggle<CR>")

-- Custom function to open a floating terminal
local function open_floating_term(cmd)
    vim.api.nvim_open_win(
        vim.api.nvim_create_buf(false, true),
        true,
        {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.8),
            height = math.floor(vim.o.lines * 0.8),
            row = math.floor(vim.o.lines * 0.1),
            col = math.floor(vim.o.columns * 0.1),
            style = "minimal",
            border = "rounded",
        }
    )
    vim.cmd("startinsert")
    vim.cmd("terminal " .. cmd)
end

-- Find or create notes using the script
map("n", "<leader>fo", function()
    open_floating_term("note")
end, { desc = "Find/Create Note" })

local notes_dir = vim.fn.expand("~/dotfiles/notes/")

vim.keymap.set("n", "<leader>fn", function()
  vim.ui.input({ prompt = "Note name: " }, function(input)
    if input and #input > 0 then
      local filename = notes_dir .. input .. ".md"
      vim.cmd("edit " .. filename)
    end
  end)
end, { desc = "Open or create markdown note" })

-- Integrated write vietnamese at edit mode
local im_select = require("config.im-select-helper")

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = im_select.on_insert_enter,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = im_select.on_insert_leave,
})

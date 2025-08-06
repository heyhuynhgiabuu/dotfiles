local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

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

-- Custom function to open a horizontal split terminal
local function open_horizontal_term(cmd)
    vim.cmd("split | terminal " .. (cmd or ""))
    vim.cmd("startinsert")
end

-- Keymap: <leader>th to open horizontal terminal
map("n", "<leader>th", function()
    open_horizontal_term()
end, { desc = "Open horizontal terminal" })

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

-- Vietnamese input method switching is now handled by im_select_helper.lua

-- Tab as VSCode
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer"})
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc ="Prev buffer"})

-- UI Git
vim.keymap.set("n", "]g", ":Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
vim.keymap.set("n", "[g", ":Gitsigns prev_hunk<CR>", { desc = "Prev git hunk" })
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Blame line" })

-- Go-specific keymaps (enhanced with ray-x/go.nvim integration)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true, desc = "" }
    
    -- Enhanced Go run/test commands with go.nvim
    vim.keymap.set("n", "<leader>gr", ":split | terminal go run %<CR>", vim.tbl_extend("force", opts, { desc = "Go run in terminal" }))
  end
})

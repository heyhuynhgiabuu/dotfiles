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

-- Go-specific keymaps (only active in Go files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true, desc = "" }
    
    -- Go run/test commands
    vim.keymap.set("n", "<leader>gr", ":terminal go run .<CR>", vim.tbl_extend("force", opts, { desc = "Go run" }))
    vim.keymap.set("n", "<leader>gt", ":terminal go test ./...<CR>", vim.tbl_extend("force", opts, { desc = "Go test" }))
    vim.keymap.set("n", "<leader>gtv", ":terminal go test -v ./...<CR>", vim.tbl_extend("force", opts, { desc = "Go test verbose" }))
    vim.keymap.set("n", "<leader>gb", ":terminal go build .<CR>", vim.tbl_extend("force", opts, { desc = "Go build" }))
    vim.keymap.set("n", "<leader>gm", ":terminal go mod tidy<CR>", vim.tbl_extend("force", opts, { desc = "Go mod tidy" }))
    
    -- Go tools
    vim.keymap.set("n", "<leader>gf", ":!gofumpt -w %<CR>", vim.tbl_extend("force", opts, { desc = "Go format file" }))
    vim.keymap.set("n", "<leader>gi", ":!goimports -w %<CR>", vim.tbl_extend("force", opts, { desc = "Go fix imports" }))
    vim.keymap.set("n", "<leader>gl", ":terminal golangci-lint run<CR>", vim.tbl_extend("force", opts, { desc = "Go lint" }))
    
    -- Go-specific LSP keymaps
    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "<leader>gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    vim.keymap.set("n", "<leader>gT", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
  end,
})

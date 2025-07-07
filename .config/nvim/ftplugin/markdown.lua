-- Markdown specific keymaps
local opts = { noremap = true, silent = true, buffer = true }

-- Format markdown file
vim.keymap.set('n', 'gqap', 'gqap', opts) -- Format paragraph

-- Quick header creation
vim.keymap.set('i', '<C-h>', function()
    local level = vim.fn.input("Header level (1-6): ")
    local text = vim.fn.input("Header text: ")
    if level and text then
        return string.rep("#", tonumber(level)) .. " " .. text
    end
end, { expr = true, buffer = true })

-- Bold text
vim.keymap.set('v', '<C-b>', 'c**<C-r>"**<Esc>', opts)

-- Italic text  
vim.keymap.set('v', '<C-i>', 'c*<C-r>"*<Esc>', opts)

-- Preview Markdown
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { buffer = true, desc = "Preview Markdown" })
vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { buffer = true, desc = "Stop Markdown Preview" })

-- Insert link
vim.keymap.set("n", "<leader>il", ":MarkdownInsertLink<CR>", { buffer = true, desc = "Insert Link" })

-- Insert image
vim.keymap.set("n", "<leader>ii", ":MarkdownInsertImage<CR>", { buffer = true, desc = "Insert Image" })
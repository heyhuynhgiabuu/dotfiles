-- NvChad core mappings (minimal)
-- Custom mappings are handled in custom/mappings.lua

-- Essential NvChad mappings only
local map = vim.keymap.set

-- Basic essential mappings that NvChad core needs
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" })

-- Allow moving the cursor through wrapped lines with j, k
map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { desc = "Move down", expr = true })
map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { desc = "Move up", expr = true })

-- Basic window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })

-- Note: All other custom mappings are in custom/mappings.lua

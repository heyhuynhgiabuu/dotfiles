-- GIAI ĐOẠN 2 - BƯỚC 2: PLUGIN NÂNG CAO
-- =====================================
--
-- File: ~/dotfiles/.config/nvim/lua/config/lazy.lua
-- Mục tiêu: Cấu hình các plugin UI, tìm kiếm, git, LSP & format nâng cao

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

local uname = vim.loop.os_uname()
local hostname = vim.loop.os_gethostname()
local lazy_opts = {}
if not (uname.sysname == "Darwin" and hostname == "killerkidbo") then
    lazy_opts.lockfile = "~/dotfiles/.config/nvim/lazy-lock.json"
end
require("lazy").setup("plugins", lazy_opts)


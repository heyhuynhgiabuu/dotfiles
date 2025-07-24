local M = {}

M.root = vim.fn.stdpath "data" .. "/lazy" -- directory where plugins will be installed
M.defaults = {
  lazy = true, -- should plugins be lazy-loaded?
  version = nil,
  -- version = "*", -- enable this to try installing the latest stable versions of plugins
}
-- leave nil when passing the spec as the first argument to setup()
M.spec = nil ---@type LazySpec
M.lockfile = vim.fn.stdpath "config" .. "/lazy-lock.json" -- lockfile generated after running update.
M.concurrency = jit.os:find "Windows" and (vim.uv.available_parallelism() * 2) or nil ---@type number limit the maximum amount of concurrent tasks
M.git = {
  -- defaults for the `Lazy log` command
  -- log = { "--since=3 days ago" }, -- show commits from the last 3 days
  log = { "-8" }, -- show the last 8 commits
  url_format = "https://github.com/%s.git",
  -- lazy.nvim requires git >=2.19.0. If you really want to use lazy with an older version,
  -- then set the below to false. This should work, but is NOT supported and will
  -- increase downloads a lot.
  filter = true,
}
M.pkg = {
  enabled = true,
  cache = vim.fn.stdpath "state" .. "/lazy/pkg-cache.lua",
  versions = true, -- Honor versions in pkg sources
  -- the first package source that is found for a plugin will be used.
  sources = {
    "lazy",
    "rockspec", -- will only be used when rocks.enabled is true
    "packspec",
  },
}
M.rocks = {
  enabled = true,
  root = vim.fn.stdpath "data" .. "/lazy-rocks",
  server = "https://nvim-neorocks.github.io/rocks-binaries/",
}
M.performance = {
  cache = {
    enabled = true,
  },
  reset_packpath = true, -- reset the package path to improve startup time
  rtp = {
    reset = true, -- reset the runtime path to improve startup time
    ---@type string[]
    paths = {}, -- add any custom paths here that you want to includes in the rtp
    ---@type string[] list any plugins you want to disable here
    disabled_plugins = {
      "gzip",
      "matchit",
      "matchparen",
      "netrwPlugin",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
    },
  },
}

return M

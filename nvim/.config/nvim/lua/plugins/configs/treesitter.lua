local options = {
  ensure_installed = {
    "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "html", "css", "javascript", "typescript", "tsx", "json", "jsonc", "c"
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      return false
    end,
  },
  indent = {
    enable = true,
    disable = { "python", "yaml" },
  },
  auto_install = true,
  sync_install = false,
}

return options

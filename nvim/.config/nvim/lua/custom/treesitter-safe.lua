-- Safe treesitter configuration with error handling (Updated for main branch)
-- This file provides a fallback if main treesitter config fails

local ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  return
end

-- Safe setup with error handling for main branch
local function safe_treesitter_setup()
  local success, error_msg = pcall(function()
    treesitter_configs.setup({
      -- Essential parsers only for main branch
      ensure_installed = { "lua", "vim", "vimdoc", "query" },
      
      -- Auto install missing parsers
      auto_install = true,
      
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        -- Disable for large files or problematic languages
        disable = function(lang, buf)
          -- Disable for large files
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          
          -- No need to disable specific languages in main branch
          -- The new queries should be more stable
          return false
        end,
      },
      
      indent = {
        enable = true,
        -- Only disable for languages with known indent issues
        disable = { "python", "yaml" },
      },
      
      -- Simplified config for main branch
      sync_install = false,
    })
  end)
  
  if not success then
    vim.notify("Treesitter setup failed: " .. tostring(error_msg), vim.log.levels.WARN)
    -- Fallback: disable treesitter highlighting completely
    vim.cmd("syntax on") -- Use Vim syntax highlighting as fallback
  else
    vim.notify("Treesitter safe setup completed successfully", vim.log.levels.INFO)
  end
end

-- Execute safe setup
safe_treesitter_setup()

return {
  safe_treesitter_setup = safe_treesitter_setup,
}

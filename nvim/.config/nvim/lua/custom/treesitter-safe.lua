-- Safe treesitter configuration with error handling
-- This file provides a fallback if main treesitter config fails

local ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  return
end

-- Safe setup with error handling
local function safe_treesitter_setup()
  local success, error_msg = pcall(function()
    treesitter_configs.setup({
      ensure_installed = { "lua", "vim", "vimdoc" }, -- Only essential parsers
      
      highlight = {
        enable = true,
        use_languagetree = true,
        additional_vim_regex_highlighting = false,
        -- Comprehensive disable function
        disable = function(lang, buf)
          -- Disable for large files
          local max_filesize = 50 * 1024 -- 50 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          
          -- Disable problematic languages that cause query_predicates errors
          local problematic_langs = { "go", "java", "printf" }
          for _, problematic_lang in ipairs(problematic_langs) do
            if lang == problematic_lang then
              return true
            end
          end
          
          return false
        end,
      },
      
      indent = {
        enable = false, -- Disable treesitter indent to avoid conflicts
      },
      
      sync_install = false,
      auto_install = false,
      ignore_install = { "printf", "go", "java" },
    })
  end)
  
  if not success then
    vim.notify("Treesitter setup failed: " .. tostring(error_msg), vim.log.levels.WARN)
    -- Fallback: disable treesitter highlighting completely
    vim.cmd("syntax on") -- Use Vim syntax highlighting as fallback
  end
end

-- Execute safe setup
safe_treesitter_setup()

return {
  safe_treesitter_setup = safe_treesitter_setup,
}

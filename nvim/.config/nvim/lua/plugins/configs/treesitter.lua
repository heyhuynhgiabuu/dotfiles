local options = {
  ensure_installed = { 
    "lua", 
    "vim", 
    "vimdoc", 
    "javascript", 
    "typescript", 
    "html", 
    "css",
    "markdown",
    "markdown_inline",
    "c"
    -- Temporarily remove Go and Java until highlighter issues are fixed
  },

  highlight = {
    enable = true,
    use_languagetree = true,
    -- Add additional_vim_regex_highlighting for fallback
    additional_vim_regex_highlighting = false,
    -- Disable for very large files and problematic languages
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      
      -- Temporarily disable Go and Java highlighting to fix query_predicates error
      if lang == "go" or lang == "java" then
        return true
      end
      
      return false
    end,
  },

  indent = { 
    enable = true,
    disable = { "python", "go", "java" } -- Disable problematic languages
  },

  -- Install parsers synchronously to avoid race conditions
  sync_install = true,
  
  -- Don't auto install to avoid conflicts during startup
  auto_install = false,
  
  -- Ignore install errors for problematic parsers
  ignore_install = { "printf", "go", "java" },
  
  -- Add parser install configs to avoid download issues
  parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
}

-- Add gotmpl parser config for Go templates
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.gotmpl = {
  install_info = {
    url = "https://github.com/ngalaiko/tree-sitter-go-template",
    files = { "src/parser.c" },
    branch = "master",
  },
  filetype = "gotmpl",
}

return options

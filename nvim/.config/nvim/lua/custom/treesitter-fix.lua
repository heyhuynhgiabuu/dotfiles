-- Manual treesitter parser installation script
-- Run this in NeoVim if automatic installation fails

local parsers_to_install = {
  "lua",
  "vim", 
  "vimdoc",
  "go",
  "java",
  "javascript",
  "typescript",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "c"
}

-- Function to install parsers manually
local function install_parsers()
  local ts_install = require('nvim-treesitter.install')
  
  for _, parser in ipairs(parsers_to_install) do
    print("Installing parser: " .. parser)
    ts_install.install(parser)
  end
end

-- Function to check parser status
local function check_parsers()
  local ts_configs = require('nvim-treesitter.configs')
  local parsers = require('nvim-treesitter.parsers')
  
  print("=== Treesitter Parser Status ===")
  for _, parser in ipairs(parsers_to_install) do
    local installed = parsers.has_parser(parser)
    print(parser .. ": " .. (installed and "✅ Installed" or "❌ Missing"))
  end
end

-- Export functions
return {
  install_parsers = install_parsers,
  check_parsers = check_parsers,
  parsers_to_install = parsers_to_install
}

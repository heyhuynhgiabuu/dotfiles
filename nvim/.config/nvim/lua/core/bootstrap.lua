local M = {}

M.lazy = function(install_path)
  print "  Bootstrapping lazy.nvim .."

  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }
  vim.opt.rtp:prepend(install_path)
  
  print "  Bootstrapped lazy.nvim successfully!"
end

M.gen_chadrc_template = function()
  if not vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1] then
    local input = vim.fn.input "Do you want to install chadrc template? (y/n): "
    if input:match "^%s*[yY]%s*$" then
      local custom_dir = vim.fn.stdpath "config" .. "/lua/custom"
      vim.fn.mkdir(custom_dir, "p")

      local chadrc_template = [[-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },
}

M.plugins = "custom.plugins"

return M
]]

      local file = io.open(custom_dir .. "/chadrc.lua", "w")
      file:write(chadrc_template)
      file:close()
    end
  end
end

return M

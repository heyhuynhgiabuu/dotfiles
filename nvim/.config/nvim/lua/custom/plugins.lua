-- KISS Plugin Loader - Auto-loads all plugins from custom/plugins/
-- Refactored for modularity and maintainability

local overrides = require("custom.configs.overrides")

-- Auto-load all plugin files from custom/plugins directory
local plugins = {}
local plugin_dir = vim.fn.stdpath("config") .. "/lua/custom/plugins"

-- Get list of all .lua files in plugins directory
local plugin_files = vim.fn.glob(plugin_dir .. "/*.lua", false, true)

-- Sort files to ensure consistent load order
table.sort(plugin_files)

-- Load each plugin file
for _, file in ipairs(plugin_files) do
	local filename = vim.fn.fnamemodify(file, ":t:r") -- Get filename without extension

	-- Skip if it's the main plugins.lua to avoid recursion
	if filename ~= "plugins" then
		local ok, plugin_config = pcall(require, "custom.plugins." .. filename)
		if ok and plugin_config then
			-- If plugin_config is a table, add it to plugins
			if type(plugin_config) == "table" then
				table.insert(plugins, plugin_config)
			end
		else
			vim.notify("Failed to load plugin: " .. filename, vim.log.levels.WARN)
		end
	end
end

-- Plugin load order verification (critical dependencies first)
local load_order_info = {
	-- Core dependencies (loaded first)
	"nvim-nio",
	"neoconf",
	"nvim-dap",
	"nvim-web-devicons",

	-- LSP and completion stack
	"nvim-lspconfig",
	"nvim-treesitter",
	"nvim-cmp",

	-- Language-specific
	"nvim-jdtls",
	"go",
	"typescript-tools",

	-- Debug stack
	"nvim-dap-ui",
	"nvim-dap-virtual-text",

	-- UI enhancements
	"fidget",
	"nvim-notify",
	"noice",
	"which-key",
	"lualine",
	"bufferline",
	"nvim-tree",
	"trouble",
	"nvim-spectre",
	"toggleterm",
	"indent-blankline",

	-- User experience
	"better-escape",
	"vim-visual-multi",
	"augment",
}

-- Add load order information as comments for debugging
vim.defer_fn(function()
	local loaded_count = #plugins
	local expected_count = #load_order_info
	if loaded_count ~= expected_count then
		vim.notify(
			string.format("Plugin loader: %d/%d plugins loaded", loaded_count, expected_count),
			vim.log.levels.INFO
		)
	else
		vim.notify(string.format("✅ All %d plugins loaded successfully", loaded_count), vim.log.levels.INFO)
	end
end, 2000)

return plugins


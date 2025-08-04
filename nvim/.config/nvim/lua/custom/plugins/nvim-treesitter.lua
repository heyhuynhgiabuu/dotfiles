-- Updated Treesitter configuration for main branch with comprehensive error handling
-- This replaces the old master branch configuration

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- Use the new main branch instead of master
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		-- Clear any existing parsers and configurations
		vim.cmd("TSDisable highlight")
		
		-- Setup nvim-treesitter
		require("nvim-treesitter.configs").setup({
			-- Essential parsers for core functionality
			ensure_installed = {
				"lua",
				"vim", 
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"jsonc",
				"c",
			},
			
			-- Auto install missing parsers when entering buffer
			auto_install = true,
			
			-- Sync install for better reliability
			sync_install = false,
			
			highlight = {
				enable = true,
				-- Disable for very large files
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
					return false
				end,
				additional_vim_regex_highlighting = false,
			},
			
			indent = {
				enable = true,
				-- Disable for problematic languages
				disable = { "python", "yaml" },
			},
		})
		
		-- Re-enable highlight after setup
		vim.cmd("TSEnable highlight")
		
		-- Clear any error messages from previous problematic queries
		vim.cmd("messages clear")
	end,
}
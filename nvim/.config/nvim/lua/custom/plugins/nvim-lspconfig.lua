-- LSP Configuration with Performance Optimizations
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Conform.nvim handles formatting now (replaces null-ls)
		{
			"stevearc/conform.nvim",
			config = function()
				require("custom.configs.conform")
			end,
		},
	},
	config = function()
		-- Use unified LSP configuration for better performance and less conflicts
		require("custom.configs.lspconfig-unified").setup()
	end,
}
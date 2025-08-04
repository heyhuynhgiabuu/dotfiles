-- LSP Configuration with Conform.nvim for formatting
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
		require("plugins.configs.lspconfig")
		require("custom.lsp-config")
	end, -- Override to setup mason-lspconfig
}
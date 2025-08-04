-- neoconf.nvim for professional LSP configuration management
-- CRITICAL: Must be loaded BEFORE nvim-lspconfig
return {
	"folke/neoconf.nvim",
	cmd = "Neoconf",
	config = function()
		require("neoconf").setup({
			-- import existing settings from other plugins
			import = {
				vscode = true, -- local .vscode/settings.json
				coc = false, -- global/local coc-settings.json (disabled - we don't use coc)
				nlsp = false, -- global/local nlsp-settings.nvim (disabled - not needed)
			},
			-- send new configuration to lsp clients when changing json settings
			live_reload = true,
			-- set the filetype to jsonc for settings files with comments
			filetype_jsonc = true,
			plugins = {
				lspconfig = {
					enabled = true,
				},
				jsonls = {
					enabled = true,
					configured_servers_only = true,
				},
				lua_ls = {
					enabled_for_neovim_config = true,
				},
			},
		})
	end,
}
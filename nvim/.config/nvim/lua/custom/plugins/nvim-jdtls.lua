-- nvim-jdtls for professional Java development
-- Stable, reliable JDTLS integration without Mason API issues
return {
	"mfussenegger/nvim-jdtls",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
	},
	ft = { "java" },
	-- Configuration is handled in ftplugin/java.lua for proper per-project setup
}
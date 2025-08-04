-- nvim-dap (Debug Adapter Protocol) for debugging support
-- MUST be loaded before nvim-jdtls to ensure proper integration
return {
	"mfussenegger/nvim-dap",
	lazy = false, -- Load immediately to ensure availability
	config = function()
		-- Basic DAP setup - detailed config is in dap-config.lua
		local dap = require("dap")
		vim.notify("nvim-dap loaded successfully", vim.log.levels.INFO)
	end,
}
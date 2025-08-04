-- Go development enhancements
return {
	"ray-x/go.nvim",
	dependencies = {
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("go").setup({
			-- Enhanced Go development features
			goimport = "gopls", -- Use gopls for imports
			gofmt = "gofumpt", -- Use gofumpt for formatting
			max_line_len = 120,
			tag_transform = false,
			test_template = "", -- Default test template
			test_template_dir = "", -- Default test template directory
			comment_placeholder = "   ",
			icons = { breakpoint = "🧘", currentpos = "🏃" },
			verbose = false,
			log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
			lsp_cfg = false, -- We handle LSP config separately
			lsp_gofumpt = false, -- Disable auto-formatting to avoid conflicts
			lsp_on_attach = false, -- We handle this in lsp-config
			dap_debug = true,
		})
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
}
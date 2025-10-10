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
			goimport = "gopls",
			gofmt = "gofumpt",
			max_line_len = 120,
			tag_transform = false,
			test_template = "",
			test_template_dir = "",
			comment_placeholder = "   ",
			icons = { breakpoint = "🧘", currentpos = "🏃" },
			verbose = false,
			log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
			lsp_cfg = false,
			lsp_gofumpt = false,
			lsp_on_attach = false,
			lsp_codelens = false,
			dap_debug = true,
			-- FIX: Disable treesitter textobjects to avoid outdated query errors
			textobjects = false,
		})
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
}

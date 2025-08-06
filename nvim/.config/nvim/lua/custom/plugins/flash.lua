-- flash.nvim advanced configuration for Neovim
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		modes = {
			search = {
				enabled = true,
			},
			char = {
				jump_labels = true,
			},
		},
	},
	keys = {
		{
			"<leader>fj",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"<leader>ft",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"<leader>fr",
			mode = { "o" },
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"<leader>fT",
			mode = { "n", "x" },
			function()
				require("flash").treesitter()
			end,
			desc = "Treesitter Search",
		},
		{
			"<C-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
	dependencies = {
		"nvim-treesitter",
		"nvim-treesitter-textobjects",
	},
	config = function()
		vim.api.nvim_set_hl(0, "FlashMatch", { link = "Search" })
		vim.api.nvim_set_hl(0, "FlashBackdrop", { link = "Comment" })
		vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = "#ffffff", bold = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "help", "alpha", "dashboard", "neo-tree" },
			callback = function()
				vim.b.flash_disable = true
			end,
		})
	end,
}

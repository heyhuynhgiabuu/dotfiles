return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {},
	},
	{
		"folke/sidekick.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
				win = {
					layout = "left", -- Open CLI on left side (nvim-tree is on right)
				},
			},
		},
		keys = {
			-- Disabled Tab mapping - interferes with file navigation
			-- Use <leader>sj instead for sidekick jump
			-- {
			-- 	"<tab>",
			-- 	function()
			-- 		if not require("sidekick").nes_jump_or_apply() then
			-- 			return "<Tab>"
			-- 		end
			-- 	end,
			-- 	expr = true,
			-- 	desc = "Goto/Apply Next Edit Suggestion",
			-- },
			{
				"<leader>sj",
				function()
					require("sidekick").nes_jump_or_apply()
				end,
				desc = "Sidekick Jump/Apply Next Edit",
			},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle({ focus = true })
			end,
			mode = { "n", "v" },
			desc = "Sidekick Toggle CLI (Left Panel)",
		},
		-- OpenCode integration disabled due to TUI incompatibility with tmux
		-- See: docs/editors/opencode-performance-analysis.md
		-- {
		-- 	"<leader>ao",
		-- 	function()
		-- 		require("sidekick.cli").toggle({ name = "opencode", focus = true })
		-- 	end,
		-- 	desc = "Sidekick OpenCode",
		-- 	mode = { "n", "v" },
		-- },
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "v" },
				desc = "Sidekick Prompt",
			},
			{
				"<c-.>",
				function()
					require("sidekick.cli").focus()
				end,
				mode = { "n", "x", "i", "t" },
				desc = "Sidekick Focus",
			},
		},
	},
}

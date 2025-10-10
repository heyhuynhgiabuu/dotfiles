-- Which-key for displaying keybindings
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
	cmd = "WhichKey",
	config = function(_, opts)
		dofile(vim.g.base46_cache .. "whichkey")
		local wk = require("which-key")

		-- Updated config for which-key v3+
		wk.setup({
			preset = "modern",
			delay = 200,
			expand = 1,
			notify = true,
			-- Key mappings are now configured using spec
			spec = {},
			-- Icons configuration
			icons = {
				breadcrumb = "»",
				separator = "➜",
				group = "+",
				ellipsis = "…",
				mappings = true,
				rules = {},
				colors = true,
				keys = {
					Up = " ",
					Down = " ",
					Left = " ",
					Right = " ",
					C = "󰘴 ",
					M = "󰘵 ",
					D = "󰘳 ",
					S = "󰘶 ",
					CR = "󰌑 ",
					Esc = "󱊷 ",
					ScrollWheelDown = "󱕐 ",
					ScrollWheelUp = "󱕑 ",
					NL = "󰌑 ",
					BS = "󰁮",
					Space = "󱁐 ",
					Tab = "󰌒 ",
				},
			},
			win = {
				border = "rounded",
				padding = { 1, 2 },
				wo = {
					winblend = 0,
				},
			},
			layout = {
				width = { min = 20 },
				spacing = 3,
			},
			keys = {
				scroll_down = "<c-d>",
				scroll_up = "<c-u>",
			},
			sort = { "local", "order", "group", "alphanum", "mod" },
			expand = 0,
			replace = {
				key = {
					function(key)
						return require("which-key.view").format(key)
					end,
				},
			},
		})

		-- Register groups using add method
		wk.add({
			{ "<leader>f", group = "File" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>g", group = "Git/Go" },
			{ "<leader>ts", group = "TypeScript" },
			{ "<leader>j", group = "Java" },
			{ "<leader>jb", group = "Java Build" },
			{ "<leader>jr", group = "Java Run" },
			{ "<leader>jt", group = "Java Test" },
			{ "<leader>jx", group = "Java Refactor" },
			{ "<leader>jd", group = "Java Debug" },
			{ "<leader>js", group = "Java Settings" },
			{ "<leader>jg", group = "Java Go To" },
			{ "<leader>jc", group = "Java Code" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>w", group = "Window" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>db", group = "Debug Breakpoints" },
			{ "<leader>ds", group = "Debug Step" },
			{ "<leader>dr", group = "Debug REPL/Restart" },
			{ "<leader>dv", group = "Debug View/Eval" },
			{ "<leader>s", group = "Search" },
			{ "<leader>h", group = "Help" },
			{ "<leader>a", group = "AI/Sidekick" },
			{ "<leader>v", group = "View/Visual" },
			{ "<leader>x", group = "Diagnostics/Quickfix" },
			{ "<leader>vt", desc = "Show directory tree in floating window" },
			{ "<leader>tv", desc = "New vertical terminal" },
			{ "<leader>tn", desc = "Toggle line number" },
			-- Debug hotkeys documentation
			{ "<F5>", desc = "Start/Continue Debug" },
			{ "<F6>", desc = "Pause Debug" },
			{ "<F9>", desc = "Toggle Breakpoint" },
			{ "<F10>", desc = "Step Over" },
			{ "<F11>", desc = "Step Into" },
			{ "<S-F11>", desc = "Step Out" },
			{ "<S-F5>", desc = "Stop Debug" },
			{ "<C-F5>", desc = "Restart Debug" },
			{ "<leader>db", desc = "Toggle Breakpoint" },
			{ "<leader>dB", desc = "Conditional Breakpoint" },
			{ "<leader>dC", desc = "Clear All Breakpoints" },
			{ "<leader>dc", desc = "Debug Continue" },
			{ "<leader>dt", desc = "Debug Terminate" },
			{ "<leader>dr", desc = "Debug Restart/REPL" },
			{ "<leader>dh", desc = "Debug Help" },
			{ "<leader>ds", desc = "Debug Show Scopes" },
			{ "<leader>df", desc = "Debug Show Frames" },
			{ "<leader>dv", desc = "Debug Hover/Eval" },
			{ "<leader>de", desc = "Debug Evaluate Expression" },
			-- TypeScript specific mappings
			{ "<leader>tso", desc = "Organize Imports" },
			{ "<leader>tss", desc = "Sort Imports" },
			{ "<leader>tsr", desc = "Remove Unused Imports" },
			{ "<leader>tsu", desc = "Remove All Unused" },
			{ "<leader>tsa", desc = "Add Missing Imports" },
			{ "<leader>tsf", desc = "Fix All Errors" },
			{ "<leader>tsg", desc = "Go to Source Definition" },
			{ "<leader>tsR", desc = "Rename File" },
			{ "<leader>tsF", desc = "File References" },
			{ "<leader>tf", desc = "Fix All & Save" },
			{ "<leader>to", desc = "Organize & Format" },
		})
	end,
}
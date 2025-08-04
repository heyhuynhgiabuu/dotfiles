-- nvim-dap-ui for IntelliJ-like debugging UI
return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	lazy = false,
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		-- Setup dap-ui with video-style layout (matching screenshot)
		dapui.setup({
			icons = {
				expanded = "▾",
				collapsed = "▸",
				current_frame = "▸",
			},
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			element_mappings = {},
			expand_lines = vim.fn.has("nvim-0.7") == 1,
			layouts = {
				{
					-- Left sidebar - Debug information (exactly like video)
					elements = {
						-- Variables/Scopes at top (most important)
						{ id = "scopes", size = 0.30 },
						-- Call stack (execution flow)
						{ id = "stacks", size = 0.30 },
						-- Breakpoints (management)
						{ id = "breakpoints", size = 0.20 },
						-- Watches (custom expressions)
						{ id = "watches", size = 0.20 },
					},
					size = 50, -- 50 columns width (wider for readability)
					position = "left",
				},
				{
					-- Bottom panel - Console and REPL (like video)
					elements = {
						-- Console for program output (main)
						{ id = "console", size = 0.60 },
						-- REPL for interactive debugging
						{ id = "repl", size = 0.40 },
					},
					size = 12, -- 12 lines height (fixed size, not percentage)
					position = "bottom",
				},
			},
			controls = {
				enabled = true,
				element = "console", -- Show controls in console area
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = "rounded", -- Modern rounded borders
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			windows = {
				indent = 1,
			},
			render = {
				max_type_length = nil, -- Don't truncate type information
				max_value_lines = 100, -- Show more lines for complex values
				indent = 1,
			},
		})

		-- Automatically open/close DAP UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
			vim.notify("DAP UI opened", vim.log.levels.INFO)
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
			vim.notify("DAP UI closed", vim.log.levels.INFO)
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
			vim.notify("DAP UI closed", vim.log.levels.INFO)
		end

		-- Additional keymaps for DAP UI
		vim.keymap.set("n", "<Leader>du", function()
			dapui.toggle()
		end, { desc = "Toggle DAP UI" })
		vim.keymap.set("n", "<Leader>dE", function()
			dapui.eval()
		end, { desc = "Evaluate expression under cursor" })
		vim.keymap.set("v", "<Leader>dE", function()
			dapui.eval()
		end, { desc = "Evaluate selected expression" })
		vim.keymap.set("n", "<Leader>df", function()
			dapui.float_element()
		end, { desc = "Float DAP element" })
	end,
}
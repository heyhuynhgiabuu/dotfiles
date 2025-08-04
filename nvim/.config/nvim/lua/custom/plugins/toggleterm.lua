-- Enhanced terminal integration
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	config = function()
		require("toggleterm").setup({
			size = 20,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			persist_mode = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			auto_scroll = true,
			float_opts = {
				border = "curved",
				width = function()
					return math.floor(vim.o.columns * 0.8)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.8)
				end,
				winblend = 0,
				zindex = 1000,
				title_pos = "center",
			},
			winbar = {
				enabled = false,
				name_formatter = function(term)
					return term.name
				end,
			},
		})

		-- Enhanced terminal key mappings
		local Terminal = require("toggleterm.terminal").Terminal

		-- Horizontal terminal
		local horizontal_term = Terminal:new({
			direction = "horizontal",
			size = 15,
		})

		-- Vertical terminal
		local vertical_term = Terminal:new({
			direction = "vertical",
			size = vim.o.columns * 0.4,
		})

		-- Lazygit terminal
		local lazygit = Terminal:new({
			cmd = "lazygit",
			dir = "git_dir",
			direction = "float",
			float_opts = {
				border = "double",
			},
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(
					term.bufnr,
					"n",
					"q",
					"<cmd>close<CR>",
					{ noremap = true, silent = true }
				)
			end,
			on_close = function(term)
				vim.cmd("startinsert!")
			end,
		})

		-- Key mappings
		vim.keymap.set("n", "<leader>tv", function()
			vertical_term:toggle()
		end, { desc = "New vertical terminal" })
		vim.keymap.set("n", "<leader>th", function()
			horizontal_term:toggle()
		end, { desc = "New horizontal terminal" })
		vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "New floating terminal" })
		vim.keymap.set("n", "<leader>gg", function()
			lazygit:toggle()
		end, { desc = "Open Lazygit" })

		-- Terminal mode mappings
		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
	end,
}
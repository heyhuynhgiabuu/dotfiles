-- AugmentCode AI integration (single AI solution)
return {
	"augmentcode/augment.vim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	init = function()
		-- CRITICAL: Set workspace folders BEFORE plugin loads (per official docs)
		-- Load workspace folders from global config or set defaults
		local workspace_config = vim.fn.expand("~/.config/augment/workspace_folders.conf")
		local workspace_folders = {}

		-- Try to load from config file first
		if vim.fn.filereadable(workspace_config) == 1 then
			local lines = vim.fn.readfile(workspace_config)
			for _, line in ipairs(lines) do
				line = vim.trim(line)
				-- Skip comments and empty lines
				if line ~= "" and not vim.startswith(line, "#") and not vim.startswith(line, "!") then
					-- Expand home directory
					if vim.startswith(line, "~/") then
						line = vim.fn.expand(line)
					end
					-- Only add if directory exists
					if vim.fn.isdirectory(line) == 1 then
						table.insert(workspace_folders, line)
					end
				end
			end
		end

		-- Set default workspace folders if none found
		if #workspace_folders == 0 then
			workspace_folders = {
				vim.fn.expand("~/projects"),
				vim.fn.expand("~/code"),
				vim.fn.expand("~/dotfiles"),
				vim.fn.getcwd(), -- Always include current working directory
			}
			-- Filter to only existing directories
			workspace_folders = vim.tbl_filter(function(path)
				return vim.fn.isdirectory(path) == 1
			end, workspace_folders)
		end

		-- Set the workspace folders before plugin loads
		vim.g.augment_workspace_folders = workspace_folders
	end,
	config = function()
		-- AugmentCode as primary AI with clean, conflict-free setup
		-- Global config files: ~/.config/augment/ (symlinked from ~/dotfiles/augment/.config/augment/)

		-- Set official options for optimal single-AI experience
		vim.g.augment_disable_tab_mapping = true -- CRITICAL: Disable to avoid nvim-cmp conflicts
		vim.g.augment_suppress_version_warning = false
		vim.g.augment_node_command = "node"

		-- Configure highlighting for AugmentCode suggestions
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				vim.api.nvim_set_hl(0, "AugmentSuggestionHighlight", {
					fg = "#7dc4e4", -- Nice blue color for primary AI
					ctermfg = 12,
					italic = true,
					force = true,
				})
			end,
			desc = "AugmentCode - Set suggestion highlighting",
		})

		-- Apply highlighting for current colorscheme
		vim.api.nvim_set_hl(0, "AugmentSuggestionHighlight", {
			fg = "#7dc4e4",
			ctermfg = 12,
			italic = true,
			force = true,
		})

		-- Load project-specific configuration if it exists
		local project_config = vim.fn.getcwd() .. "/.augmentconfig"
		if vim.fn.filereadable(project_config) == 1 then
			vim.cmd("source " .. project_config)
		end

		-- AugmentCode keymaps (clean, single-AI setup)
		local keymap = vim.keymap.set

		-- Chat commands (official)
		keymap("n", "<leader>ac", ":Augment chat ", { desc = "AugmentCode - Send chat message" })
		keymap("v", "<leader>ac", ":Augment chat ", { desc = "AugmentCode - Chat about selection" })
		keymap("n", "<leader>an", "<cmd>Augment chat-new<CR>", { desc = "AugmentCode - New chat conversation" })
		keymap("n", "<leader>at", "<cmd>Augment chat-toggle<CR>", { desc = "AugmentCode - Toggle chat panel" })

		-- Status and management (official)
		keymap("n", "<leader>as", "<cmd>Augment status<CR>", { desc = "AugmentCode - Show status" })
		keymap("n", "<leader>al", "<cmd>Augment log<CR>", { desc = "AugmentCode - Show log" })

		-- Authentication (official)
		keymap("n", "<leader>ai", "<cmd>Augment signin<CR>", { desc = "AugmentCode - Sign in" })
		keymap("n", "<leader>ao", "<cmd>Augment signout<CR>", { desc = "AugmentCode - Sign out" })

		-- Completion control via variables
		keymap("n", "<leader>ae", function()
			vim.g.augment_disable_completions = false
			print("AugmentCode completions enabled")
		end, { desc = "AugmentCode - Enable completions" })

		keymap("n", "<leader>ad", function()
			vim.g.augment_disable_completions = true
			print("AugmentCode completions disabled")
		end, { desc = "AugmentCode - Disable completions" })

		-- Workspace folder management (per official docs)
		keymap("n", "<leader>aw", function()
			local folders = vim.g.augment_workspace_folders or {}
			print("🔮 AugmentCode Workspace Folders:")
			if #folders == 0 then
				print("   No workspace folders configured")
			else
				for i, folder in ipairs(folders) do
					print(string.format("   %d. %s", i, folder))
				end
			end
			print("Use <leader>aW to add current directory")
		end, { desc = "AugmentCode - Show workspace folders" })

		keymap("n", "<leader>aW", function()
			local current_dir = vim.fn.getcwd()
			local folders = vim.g.augment_workspace_folders or {}

			-- Check if current directory is already in workspace
			for _, folder in ipairs(folders) do
				if folder == current_dir then
					print("Current directory already in workspace: " .. current_dir)
					return
				end
			end

			-- Add current directory to workspace
			table.insert(folders, current_dir)
			vim.g.augment_workspace_folders = folders

			print("Added to workspace: " .. current_dir)
			print("Restart Neovim to sync new workspace folder")
		end, { desc = "AugmentCode - Add current directory to workspace" })

		keymap("n", "<leader>aF", function()
			vim.ui.input({ prompt = "Enter workspace folder path: " }, function(input)
				if input and input ~= "" then
					local path = vim.fn.expand(input)
					if vim.fn.isdirectory(path) == 1 then
						local folders = vim.g.augment_workspace_folders or {}
						table.insert(folders, path)
						vim.g.augment_workspace_folders = folders
						print("Added to workspace: " .. path)
						print("Restart Neovim to sync new workspace folder")
					else
						print("Directory not found: " .. path)
					end
				end
			end)
		end, { desc = "AugmentCode - Add custom folder to workspace" })

		-- Completion acceptance - CONFLICT-FREE keys only
		-- Using Ctrl-L as primary (safe, no conflicts with nvim-cmp)
		keymap("i", "<C-l>", function()
			if vim.fn.exists("*augment#Accept") == 1 then
				-- Check if we're in a safe context to accept
				if vim.fn.mode() == "i" then
					local result = vim.fn["augment#Accept"]()
					if result and result ~= "" then
						return result
					end
				end
			end
			return ""
		end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion" })

		-- Alternative: Ctrl-J (safe, commonly used for acceptance)
		keymap("i", "<C-j>", function()
			if vim.fn.exists("*augment#Accept") == 1 then
				if vim.fn.mode() == "i" then
					local result = vim.fn["augment#Accept"]()
					if result and result ~= "" then
						return result
					end
				end
			end
			return ""
		end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion (alt)" })

		-- Fallback: Ctrl-Y (very safe, standard vim)
		keymap("i", "<C-y>", function()
			if vim.fn.exists("*augment#Accept") == 1 then
				if vim.fn.mode() == "i" then
					local result = vim.fn["augment#Accept"]()
					if result and result ~= "" then
						return result
					end
				end
			end
			return "<C-y>" -- Fallback to normal Ctrl-Y
		end, { expr = true, silent = true, desc = "AugmentCode - Accept suggestion or scroll up" })

		-- Print startup message
		vim.defer_fn(function()
			local folders = vim.g.augment_workspace_folders or {}
			print("🚀 AugmentCode: Primary AI ready | Ctrl-L to accept | <leader>ac for chat")
			print(string.format("📁 Workspace: %d folders configured | <leader>aw to view", #folders))
		end, 1000)
	end,
	event = "VeryLazy",
	cmd = { "Augment" },
}
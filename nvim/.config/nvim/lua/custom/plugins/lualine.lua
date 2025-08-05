-- Enhanced status line with more information
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VimEnter",
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
lualine_b = {
          "branch",
          "diff",
        },
        lualine_z = {
  {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn", "info", "hint" },
    diagnostics_color = {
      error = "DiagnosticError",
      warn = "DiagnosticWarn",
      info = "DiagnosticInfo",
      hint = "DiagnosticHint",
    },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
    colored = true,
    update_in_insert = false,
    always_visible = true,
  },
  "location"
},				lualine_c = {
					{
						"filename",
						file_status = true,
						newfile_status = false,
						path = 1, -- Relative path
						shorting_target = 40,
						symbols = {
							modified = "[+]",
							readonly = "[RO]",
							unnamed = "[No Name]",
							newfile = "[New]",
						},
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					{
						-- Show LSP status
						function()
							local clients = vim.lsp.get_active_clients()
							if next(clients) == nil then
								return ""
							end

							local client_names = {}
							for _, client in pairs(clients) do
								table.insert(client_names, client.name)
							end
							return " " .. table.concat(client_names, ", ")
						end,
						color = { fg = "#7dc4e4" },
					},
				},
				lualine_y = { "progress" },
				
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = { "nvim-tree", "trouble", "quickfix" },
		})
	end,
}
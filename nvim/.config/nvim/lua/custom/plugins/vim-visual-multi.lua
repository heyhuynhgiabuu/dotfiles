-- Multi-cursor editing (vim-visual-multi)
return {
	"mg979/vim-visual-multi",
	branch = "master",
	event = { "BufReadPost", "BufNewFile" },
	init = function()
		-- Để mặc định, plugin đã tối ưu cho VSCode/IntelliJ style
		-- Nếu muốn custom keymap, hãy thêm vào đây
		vim.g.VM_maps = {
			["Find Under"] = "<C-d>",
			["Find Subword Under"] = "<C-d>",
			["Select All"] = "<C-S-d>",
			["Add Cursor Down"] = "<C-Down>",
			["Add Cursor Up"] = "<C-Up>",
		}
		vim.g.VM_leader = "\\"
		vim.g.VM_theme = "iceblue"
		vim.g.VM_set_statusline = 0
	end,
}
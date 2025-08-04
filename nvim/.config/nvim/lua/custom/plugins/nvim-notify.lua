-- Enhanced Command Line UI with floating input
return {
	"rcarriga/nvim-notify",
	config = function()
		require("notify").setup({
			render = "compact",
			stages = "fade_in_slide_out",
			timeout = 3000,
			max_width = 100,
		})
		vim.notify = require("notify")
	end,
}
-- Override plugin configs
local overrides = require("custom.configs.overrides")

return {
	"nvim-treesitter/nvim-treesitter",
	opts = overrides.treesitter,
}
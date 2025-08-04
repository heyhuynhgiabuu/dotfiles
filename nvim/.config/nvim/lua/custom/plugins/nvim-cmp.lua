-- Enhanced completions with better Go/Java support
return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp-signature-help", -- Enhanced function signatures
		"ray-x/cmp-treesitter", -- Better code structure completions
		"saadparwaiz1/cmp_luasnip",
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		-- Load snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered({
					border = "rounded",
				}),
				documentation = cmp.config.window.bordered({
					border = "rounded",
				}),
			},
			formatting = {
				format = function(entry, vim_item)
					-- Add source indicators for better visibility
					local source_mapping = {
						nvim_lsp = "[LSP]",
						luasnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
						treesitter = "[TS]",
						nvim_lsp_signature_help = "[Sig]",
					}
					vim_item.menu = source_mapping[entry.source.name] or "[Other]"
					return vim_item
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				-- Enhanced Tab completion for snippets
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000, trigger_characters = { "." } },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				{ name = "luasnip", priority = 800 },
				{ name = "treesitter", priority = 700 },
			}, {
				{ name = "buffer", keyword_length = 3 },
				{ name = "path" },
			}),
			completion = {
				completeopt = "menu,menuone,noinsert",
				autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
			},
			experimental = {
				ghost_text = true, -- Show preview text
			},
		})

		-- Enhanced Go completion
		cmp.setup.filetype("go", {
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000, trigger_characters = { ".", ":" } },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				{ name = "luasnip", priority = 800 },
			}, {
				{ name = "buffer", keyword_length = 2 },
				{ name = "path" },
			}),
			completion = {
				autocomplete = {
					require("cmp.types").cmp.TriggerEvent.TextChanged,
					require("cmp.types").cmp.TriggerEvent.InsertEnter,
				},
			},
		})

		-- Enhanced Java completion
		cmp.setup.filetype("java", {
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				{ name = "luasnip", priority = 800 },
			}, {
				{ name = "buffer", keyword_length = 2 },
				{ name = "path" },
			}),
		})

		-- Enhanced Command Line Completion
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline({
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { "c" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { "c" }),
			}),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}),
			completion = {
				autocomplete = {
					require("cmp.types").cmp.TriggerEvent.TextChanged,
				},
			},
			formatting = {
				format = function(entry, vim_item)
					-- Enhanced formatting for command line
					local source_mapping = {
						cmdline = "[CMD]",
						path = "[Path]",
						buffer = "[Buf]",
					}
					vim_item.menu = source_mapping[entry.source.name] or "[Other]"
					return vim_item
				end,
			},
		})
	end,
}
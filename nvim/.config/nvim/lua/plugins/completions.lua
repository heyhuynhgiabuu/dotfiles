return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = { 
            "saadparwaiz1/cmp_luasnip", 
            "rafamadriz/friendly-snippets",
            -- Add Go and Java specific snippets
            "golang/vscode-go",
            "redhat-developer/vscode-java",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            -- Load language-specific snippets
            require("luasnip.loaders.from_vscode").lazy_load({paths = {"~/.vscode/extensions/golang.go/snippets"}})
        end,
    },
    {
        "hrsh7th/cmp-nvim-lsp", -- Engine chính cho autocomplete
        "hrsh7th/cmp-buffer", -- Autocomplete từ buffer
        "hrsh7th/cmp-path", -- Autocomplete path
        "hrsh7th/cmp-cmdline", -- Autocomplete commandline
        -- Enhanced completions for Go and Java
        "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signature help
        "ray-x/cmp-treesitter", -- Treesitter completions
    },
    {
        "hrsh7th/nvim-cmp", -- Engine chính cho autocomplete
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            
            -- Load snippets from VSCode extensions
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
                        winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
                    }),
                    documentation = cmp.config.window.bordered({
                        border = "rounded",
                    }),
                },
                formatting = {
                    format = function(entry, vim_item)
                        -- Add source indicators
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            treesitter = "[TS]",
                            nvim_lsp_signature_help = "[Sig]",
                        })[entry.source.name]
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
                        select = true 
                    }),
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    -- Better snippet navigation
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
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip", priority = 800 },
                    { name = "treesitter", priority = 700 },
                }, {
                    { name = "buffer", keyword_length = 3 },
                    { name = "path" },
                }),
                -- Enhanced completion behavior
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                experimental = {
                    ghost_text = true, -- Show ghost text for suggestions
                },
            })
            
            -- Enhanced completion for Go files
            cmp.setup.filetype('go', {
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip", priority = 800 },
                }, {
                    { name = "buffer", keyword_length = 2 },
                    { name = "path" },
                })
            })
            
            -- Enhanced completion for Java files
            cmp.setup.filetype('java', {
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip", priority = 800 },
                }, {
                    { name = "buffer", keyword_length = 2 },
                    { name = "path" },
                })
            })
            
            -- Setup command line completion using autocommand to ensure it runs after everything is loaded
            vim.api.nvim_create_autocmd("CmdlineEnter", {
                callback = function()
                    local cmp = require('cmp')
                    
                    -- Setup search completion
                    cmp.setup.cmdline('/', {
                        completion = { autocomplete = false },
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = {
                            { name = 'buffer', opts = { keyword_pattern = [=[[^[:blank:]].*]=] } }
                        }
                    })
                    
                    cmp.setup.cmdline('?', {
                        completion = { autocomplete = false },
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = {
                            { name = 'buffer', opts = { keyword_pattern = [=[[^[:blank:]].*]=] } }
                        }
                    })
                    
                    -- Setup command completion
                    cmp.setup.cmdline(':', {
                        completion = { autocomplete = false },
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = cmp.config.sources({
                            { name = 'path' }
                        }, {
                            { name = 'cmdline' }
                        })
                    })
                end,
                once = true, -- Only run once
            })
        end,
    },
}
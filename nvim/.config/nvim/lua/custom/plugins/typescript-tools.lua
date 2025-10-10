-- TypeScript Tools - Modern TypeScript/JavaScript LSP with native tsserver protocol
-- Replaces traditional typescript-language-server with faster, more reliable solution

local typescript_tools_config = {
  "pmizio/typescript-tools.nvim",
  event = { "BufReadPre", "BufNewFile" },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local api = require("typescript-tools.api")
    
    require("typescript-tools").setup({
      on_attach = function(client, bufnr)
        -- Enhanced on_attach function with TypeScript specific keymaps
        local function opts(desc)
          return { buffer = bufnr, desc = "TS " .. desc }
        end

        -- Basic LSP keymaps
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts "Hover")
        vim.keymap.set("n", "gri", vim.lsp.buf.implementation, opts "Go to implementation")
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts "Show signature")
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts "Go to type definition")
        vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts "LSP rename")
        vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action, opts "Code action")
        vim.keymap.set("n", "grr", vim.lsp.buf.references, opts "Show references")

        -- TypeScript specific keymaps
        vim.keymap.set("n", "<leader>tso", "<cmd>TSToolsOrganizeImports<cr>", opts "Organize imports")
        vim.keymap.set("n", "<leader>tss", "<cmd>TSToolsSortImports<cr>", opts "Sort imports") 
        vim.keymap.set("n", "<leader>tsr", "<cmd>TSToolsRemoveUnusedImports<cr>", opts "Remove unused imports")
        vim.keymap.set("n", "<leader>tsu", "<cmd>TSToolsRemoveUnused<cr>", opts "Remove all unused")
        vim.keymap.set("n", "<leader>tsa", "<cmd>TSToolsAddMissingImports<cr>", opts "Add missing imports")
        vim.keymap.set("n", "<leader>tsf", "<cmd>TSToolsFixAll<cr>", opts "Fix all")
        vim.keymap.set("n", "<leader>tsg", "<cmd>TSToolsGoToSourceDefinition<cr>", opts "Go to source definition")
        vim.keymap.set("n", "<leader>tsR", "<cmd>TSToolsRenameFile<cr>", opts "Rename file")
        vim.keymap.set("n", "<leader>tsF", "<cmd>TSToolsFileReferences<cr>", opts "File references")

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
      end,
      handlers = {
        -- Filter out annoying TypeScript diagnostics
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({
          -- Ignore 'This may be converted to an async function' diagnostics
          80006,
          -- Ignore 'File is a CommonJS module' diagnostics  
          80001,
        }),
      },
      settings = {
        -- Spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,
        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = "insert_leave",
        -- Expose all supported code actions
        expose_as_code_action = "all",
        -- TypeScript server path (auto-detected)
        tsserver_path = nil,
        -- No external plugins for now
        tsserver_plugins = {},
        -- Memory limit in megabytes or "auto"(basically no limit)
        tsserver_max_memory = "auto",
        -- Enhanced file preferences for better TypeScript experience
        tsserver_file_preferences = {
          -- Enable inlay hints
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          -- Better completions
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          includeCompletionsWithSnippetText = true,
          -- Import preferences
          includePackageJsonAutoImports = "auto",
          quotePreference = "auto",
          displayPartsForJSDoc = true,
          generateReturnInDocTemplate = true,
        },
        tsserver_format_options = {
          -- Better formatting
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
          insertSpaceAfterCommaDelimiter = true,
          insertSpaceAfterSemicolonInForStatements = true,
          insertSpaceBeforeAndAfterBinaryOperators = true,
          insertSpaceAfterConstructor = false,
          insertSpaceAfterKeywordsInControlFlowStatements = true,
          insertSpaceAfterFunctionKeywordForAnonymousFunctions = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
          insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
          insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
          insertSpaceAfterTypeAssertion = false,
          insertSpaceBeforeFunctionParenthesis = false,
          placeOpenBraceOnNewLineForFunctions = false,
          placeOpenBraceOnNewLineForControlBlocks = false,
        },
        -- Enable TypeScript locale
        tsserver_locale = "en",
        -- Enable function call completions
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        -- Enable code lens (experimental)
        code_lens = "off",
        disable_member_code_lens = true,
        -- JSX close tag (disabled to avoid conflicts)
        jsx_close_tag = {
          enable = false,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    })
  end,
}

return typescript_tools_config

local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- Custom function to open a floating terminal
local function open_floating_term(cmd)
    vim.api.nvim_open_win(
        vim.api.nvim_create_buf(false, true),
        true,
        {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.8),
            height = math.floor(vim.o.lines * 0.8),
            row = math.floor(vim.o.lines * 0.1),
            col = math.floor(vim.o.columns * 0.1),
            style = "minimal",
            border = "rounded",
        }
    )
    vim.cmd("startinsert")
    vim.cmd("terminal " .. cmd)
end

-- Find or create notes using the script
map("n", "<leader>fo", function()
    open_floating_term("note")
end, { desc = "Find/Create Note" })

local notes_dir = vim.fn.expand("~/dotfiles/notes/")

vim.keymap.set("n", "<leader>fn", function()
  vim.ui.input({ prompt = "Note name: " }, function(input)
    if input and #input > 0 then
      local filename = notes_dir .. input .. ".md"
      vim.cmd("edit " .. filename)
    end
  end)
end, { desc = "Open or create markdown note" })

-- Vietnamese input method switching is now handled by im_select_helper.lua

-- Tab as VSCode
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer"})
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc ="Prev buffer"})

-- UI Git
vim.keymap.set("n", "]g", ":Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
vim.keymap.set("n", "[g", ":Gitsigns prev_hunk<CR>", { desc = "Prev git hunk" })
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Blame line" })

-- Go-specific keymaps (enhanced with ray-x/go.nvim integration)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true, desc = "" }
    
    -- Enhanced Go run/test commands with go.nvim
    vim.keymap.set("n", "<leader>gr", ":GoRun<CR>", vim.tbl_extend("force", opts, { desc = "Go run (go.nvim)" }))
    vim.keymap.set("n", "<leader>gt", ":GoTest<CR>", vim.tbl_extend("force", opts, { desc = "Go test (go.nvim)" }))
    vim.keymap.set("n", "<leader>gtf", ":GoTestFunc<CR>", vim.tbl_extend("force", opts, { desc = "Go test function" }))
    vim.keymap.set("n", "<leader>gtv", ":GoTest -v<CR>", vim.tbl_extend("force", opts, { desc = "Go test verbose" }))
    vim.keymap.set("n", "<leader>gb", ":GoBuild<CR>", vim.tbl_extend("force", opts, { desc = "Go build (go.nvim)" }))
    vim.keymap.set("n", "<leader>gm", ":terminal go mod tidy<CR>", vim.tbl_extend("force", opts, { desc = "Go mod tidy" }))
    vim.keymap.set("n", "<leader>gc", ":GoCoverage<CR>", vim.tbl_extend("force", opts, { desc = "Go coverage" }))
    
    -- Enhanced Go tools with go.nvim
    vim.keymap.set("n", "<leader>gf", ":GoFmt<CR>", vim.tbl_extend("force", opts, { desc = "Go format (gofumpt)" }))
    vim.keymap.set("n", "<leader>gi", ":GoImports<CR>", vim.tbl_extend("force", opts, { desc = "Go organize imports" }))
    vim.keymap.set("n", "<leader>gl", ":GoLint<CR>", vim.tbl_extend("force", opts, { desc = "Go lint (golangci-lint)" }))
    vim.keymap.set("n", "<leader>gv", ":GoVet<CR>", vim.tbl_extend("force", opts, { desc = "Go vet" }))
    
    -- Go code generation and refactoring
    vim.keymap.set("n", "<leader>ga", ":GoAddTag<CR>", vim.tbl_extend("force", opts, { desc = "Go add struct tags" }))
    vim.keymap.set("n", "<leader>gA", ":GoRmTag<CR>", vim.tbl_extend("force", opts, { desc = "Go remove struct tags" }))
    vim.keymap.set("n", "<leader>ge", ":GoIfErr<CR>", vim.tbl_extend("force", opts, { desc = "Go if err snippet" }))
    vim.keymap.set("n", "<leader>gF", ":GoFillStruct<CR>", vim.tbl_extend("force", opts, { desc = "Go fill struct" }))
    vim.keymap.set("n", "<leader>gp", ":GoImpl<CR>", vim.tbl_extend("force", opts, { desc = "Go implement interface" }))
    
    -- Go debugging
    vim.keymap.set("n", "<leader>gD", ":GoDebug<CR>", vim.tbl_extend("force", opts, { desc = "Go debug" }))
    vim.keymap.set("n", "<leader>gB", ":GoDbgBreakpoint<CR>", vim.tbl_extend("force", opts, { desc = "Go debug breakpoint" }))
    
    -- Enhanced Go-specific LSP keymaps
    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "<leader>gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    vim.keymap.set("n", "<leader>gT", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
    vim.keymap.set("n", "<leader>gR", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
    vim.keymap.set("n", "<leader>gK", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    vim.keymap.set("n", "<leader>gs", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
    vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
  end,
})

-- Java-specific keymaps (enhanced with JDTLS integration)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local opts = { noremap = true, silent = true, buffer = true }
    
    -- Enhanced Java compilation and execution
    vim.keymap.set("n", "<leader>jc", ":!javac %<CR>", vim.tbl_extend("force", opts, { desc = "Compile Java file" }))
    vim.keymap.set("n", "<leader>jr", function()
      local filename = vim.fn.expand("%:t:r")
      vim.cmd("!java " .. filename)
    end, vim.tbl_extend("force", opts, { desc = "Run Java class" }))
    
    -- Enhanced Maven/Gradle commands
    vim.keymap.set("n", "<leader>jm", ":!mvn compile<CR>", vim.tbl_extend("force", opts, { desc = "Maven compile" }))
    vim.keymap.set("n", "<leader>jmt", ":!mvn test<CR>", vim.tbl_extend("force", opts, { desc = "Maven test" }))
    vim.keymap.set("n", "<leader>jmp", ":!mvn package<CR>", vim.tbl_extend("force", opts, { desc = "Maven package" }))
    vim.keymap.set("n", "<leader>jmc", ":!mvn clean<CR>", vim.tbl_extend("force", opts, { desc = "Maven clean" }))
    vim.keymap.set("n", "<leader>jg", ":!gradle build<CR>", vim.tbl_extend("force", opts, { desc = "Gradle build" }))
    vim.keymap.set("n", "<leader>jgt", ":!gradle test<CR>", vim.tbl_extend("force", opts, { desc = "Gradle test" }))
    vim.keymap.set("n", "<leader>jgc", ":!gradle clean<CR>", vim.tbl_extend("force", opts, { desc = "Gradle clean" }))
    
    -- Enhanced Java-specific LSP keymaps with JDTLS features
    vim.keymap.set("n", "<leader>jo", function()
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and string.match(action.kind, "source.organizeImports")
        end,
        apply = true,
      })
    end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
    
    vim.keymap.set("n", "<leader>jf", function()
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and string.match(action.kind, "quickfix")
        end,
        apply = true,
      })
    end, vim.tbl_extend("force", opts, { desc = "Apply quick fix" }))
    
    -- Java refactoring (JDTLS specific)
    vim.keymap.set("n", "<leader>jrv", function()
      require('jdtls').extract_variable()
    end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
    
    vim.keymap.set("v", "<leader>jrv", function()
      require('jdtls').extract_variable(true)
    end, vim.tbl_extend("force", opts, { desc = "Extract variable (visual)" }))
    
    vim.keymap.set("n", "<leader>jrc", function()
      require('jdtls').extract_constant()
    end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
    
    vim.keymap.set("v", "<leader>jrc", function()
      require('jdtls').extract_constant(true)
    end, vim.tbl_extend("force", opts, { desc = "Extract constant (visual)" }))
    
    vim.keymap.set("v", "<leader>jrm", function()
      require('jdtls').extract_method(true)
    end, vim.tbl_extend("force", opts, { desc = "Extract method" }))
    
    -- Java testing
    vim.keymap.set("n", "<leader>jtc", function()
      require('jdtls').test_class()
    end, vim.tbl_extend("force", opts, { desc = "Test class" }))
    
    vim.keymap.set("n", "<leader>jtm", function()
      require('jdtls').test_nearest_method()
    end, vim.tbl_extend("force", opts, { desc = "Test nearest method" }))
    
    -- Enhanced Java navigation
    vim.keymap.set("n", "<leader>jd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "<leader>jI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    vim.keymap.set("n", "<leader>jT", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
    vim.keymap.set("n", "<leader>jR", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
    vim.keymap.set("n", "<leader>jK", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    vim.keymap.set("n", "<leader>js", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
    vim.keymap.set("n", "<leader>jn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set("n", "<leader>jca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
  end,
})

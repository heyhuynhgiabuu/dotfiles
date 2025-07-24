-- Custom mappings that extend NvChad core mappings
-- This file is loaded after lua/mappings.lua via custom/init.lua
-- Core mappings are minimal in lua/mappings.lua

local map = vim.keymap.set

-- Basic mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- General navigation
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- Visual mode improvements
map("v", ">", ">gv", { desc = "Indent and reselect" })
map("v", "<", "<gv", { desc = "Unindent and reselect" })

-- File operations
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Formatting
map("n", "<leader>fm", function()
  require("conform").format()
end, { desc = "Format file" })

-- Git operations
map("n", "]g", ":Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
map("n", "[g", ":Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })
map("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage git hunk" })
map("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset git hunk" })
map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
map("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Git blame line" })

-- Note taking
map("n", "<leader>fn", function()
  local notes_dir = vim.fn.expand("~/dotfiles/notes/")
  vim.ui.input({ prompt = "Note name: " }, function(input)
    if input and #input > 0 then
      local filename = notes_dir .. input .. ".md"
      vim.cmd("edit " .. filename)
    end
  end)
end, { desc = "Open or create note" })

-- Diagnostics and utilities
map("n", "<leader>ce", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diagnostics > 0 then
    local message = diagnostics[1].message
    vim.fn.setreg("+", message)
    print("Copied diagnostic: " .. message)
  else
    print("No diagnostic at cursor")
  end
end, { desc = "Copy diagnostic message" })

map("n", "<leader>ne", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>pe", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Copy file path
map("n", "<leader>cp", function()
  local filepath = vim.fn.expand("%:p")
  vim.fn.setreg("+", filepath)
  print("Copied: " .. filepath)
end, { desc = "Copy file path" })

-- Language-specific mappings (Go) - only active in Go files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true }
    
    -- Go development with go.nvim
    map("n", "<leader>gr", ":GoRun<CR>", vim.tbl_extend("force", opts, { desc = "Go run" }))
    map("n", "<leader>gt", ":GoTest<CR>", vim.tbl_extend("force", opts, { desc = "Go test" }))
    map("n", "<leader>gb", ":GoBuild<CR>", vim.tbl_extend("force", opts, { desc = "Go build" }))
    map("n", "<leader>gf", ":GoFmt<CR>", vim.tbl_extend("force", opts, { desc = "Go format" }))
    map("n", "<leader>gi", ":GoImports<CR>", vim.tbl_extend("force", opts, { desc = "Go organize imports" }))
    map("n", "<leader>gl", ":GoLint<CR>", vim.tbl_extend("force", opts, { desc = "Go lint" }))
    map("n", "<leader>ga", ":GoAddTag<CR>", vim.tbl_extend("force", opts, { desc = "Go add tags" }))
    map("n", "<leader>ge", ":GoIfErr<CR>", vim.tbl_extend("force", opts, { desc = "Go if err" }))
    map("n", "<leader>gc", ":GoCoverage<CR>", vim.tbl_extend("force", opts, { desc = "Go coverage" }))
    
    -- Go LSP mappings
    map("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "<leader>gR", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
    map("n", "<leader>gK", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
    map("n", "<leader>gn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  end,
})

-- Language-specific mappings (Java) - only active in Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local opts = { buffer = true }
    
    -- Java compilation and execution
    map("n", "<leader>jc", ":!javac %<CR>", vim.tbl_extend("force", opts, { desc = "Compile Java file" }))
    map("n", "<leader>jr", function()
      local filename = vim.fn.expand("%:t:r")
      vim.cmd("!java " .. filename)
    end, vim.tbl_extend("force", opts, { desc = "Run Java class" }))
    
    -- Java LSP features
    map("n", "<leader>jo", function()
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and string.match(action.kind, "source.organizeImports")
        end,
        apply = true,
      })
    end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
    
    map("n", "<leader>jf", function()
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and string.match(action.kind, "quickfix")
        end,
        apply = true,
      })
    end, vim.tbl_extend("force", opts, { desc = "Quick fix" }))
    
    -- Java refactoring (if jdtls is available)
    map("n", "<leader>jrv", function()
      if pcall(require, 'jdtls') then
        require('jdtls').extract_variable()
      else
        print("JDTLS not available")
      end
    end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
    
    map("n", "<leader>jrc", function()
      if pcall(require, 'jdtls') then
        require('jdtls').extract_constant()
      else
        print("JDTLS not available")
      end
    end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
    
    -- Java testing
    map("n", "<leader>jtc", function()
      if pcall(require, 'jdtls') then
        require('jdtls').test_class()
      else
        print("JDTLS not available")
      end
    end, vim.tbl_extend("force", opts, { desc = "Test class" }))
    
    map("n", "<leader>jtm", function()
      if pcall(require, 'jdtls') then
        require('jdtls').test_nearest_method()
      else
        print("JDTLS not available")
      end
    end, vim.tbl_extend("force", opts, { desc = "Test method" }))
  end,
})

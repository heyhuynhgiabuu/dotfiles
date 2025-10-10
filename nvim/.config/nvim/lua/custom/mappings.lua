-- Custom mappings that extend NvChad core mappings
-- This file is loaded after lua/mappings.lua via custom/init.lua
-- Core mappings are minimal in lua/mappings.lua

local map = vim.keymap.set

-- Basic mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
-- Remove jk mapping to avoid conflict with j
-- map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

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

-- OpenCode tmux integration (replaces sidekick.nvim approach)
map("n", "<leader>oc", function()
	local result = vim.fn.system(
		"tmux select-window -t opencode 2>/dev/null || tmux new-window -n opencode 'cd ~/dotfiles && opencode'"
	)
	if vim.v.shell_error == 0 then
		print("OpenCode window ready")
	else
		print("OpenCode launch failed: " .. result)
	end
end, { desc = "Toggle OpenCode Window" })

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
  vim.notify("Copied file path: " .. filepath)
end, { desc = "Copy file path to clipboard" })

-- Copy current line content to clipboard
map("n", "<leader>cl", function()
  local line = vim.api.nvim_get_current_line()
  vim.fn.setreg("+", line)
  vim.notify("Copied current line to clipboard")
end, { desc = "Copy current line content to clipboard" })

-- Copy function/class under cursor to clipboard (requires textobject 'af')
map("n", "<leader>cf", "vaf\"+y", { desc = "Copy function/class under cursor to clipboard", noremap = true, silent = true })

-- Copy symbol name under cursor to clipboard
map("n", "<leader>cs", function()
  local symbol = vim.fn.expand("<cword>")
  vim.fn.setreg("+", symbol)
  vim.notify("Copied symbol name: " .. symbol)
end, { desc = "Copy symbol name under cursor to clipboard" })

-- Enhanced line number toggle
map("n", "<leader>tn", function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = false
    print("Line numbers: OFF")
  elseif vim.wo.number then
    vim.wo.relativenumber = true
    print("Line numbers: RELATIVE")
  else
    vim.wo.number = true
    print("Line numbers: ABSOLUTE")
  end
end, { desc = "Toggle line number" })

-- Enhanced command-line navigation (when noice.nvim is active)
map("c", "<C-a>", "<Home>", { desc = "Go to beginning of command line" })
map("c", "<C-e>", "<End>", { desc = "Go to end of command line" })
map("c", "<C-f>", "<Right>", { desc = "Move cursor right" })
map("c", "<C-b>", "<Left>", { desc = "Move cursor left" })
map("c", "<C-d>", "<Del>", { desc = "Delete character" })
map("c", "<C-h>", "<BS>", { desc = "Backspace" })

-- Better command-line editing
map("c", "<C-k>", function()
  local pos = vim.fn.getcmdpos()
  local line = vim.fn.getcmdline()
  return line:sub(1, pos - 1)
end, { expr = true, desc = "Kill line from cursor" })

-- Enhanced search UI keymaps
map("n", "<leader>ss", "<cmd>lua require('spectre').toggle()<CR>", { desc = "Toggle search & replace" })
map("n", "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", { desc = "Search current word" })
map("v", "<leader>sw", "<esc><cmd>lua require('spectre').open_visual()<CR>", { desc = "Search selection" })

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

-- Copy opencode reference: @file#Lstart-end
map("v", "<leader>y", function()
  local buf_path = vim.fn.expand("%:~:.")
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local ref = string.format("@%s#L%d-%d", buf_path, start_line, end_line)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Copy file reference for opencode" })

-- Copy selected lines content to clipboard
map("v", "<leader>c", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local content = table.concat(lines, "\n")
  vim.fn.setreg("+", content)
  vim.notify("Copied selected lines to clipboard")
end, { desc = "Copy selected lines content to clipboard" })

-- JAVA BUILD TOOLS & PROJECT SETUP
-- Gradle commands for Java project initialization and management

map("n", "<leader>jw", function()
  vim.ui.input({ 
    prompt = "Gradle version (default: 8.5): ",
    default = "8.5"
  }, function(version)
    if not version or #version == 0 then
      version = "8.5"
    end
    local cmd = string.format("gradle wrapper --gradle-version %s", version)
    vim.cmd("split")
    vim.cmd("term " .. cmd)
    vim.cmd("startinsert")
    vim.notify("Creating Gradle wrapper with version " .. version)
  end)
end, { desc = "Java: Create Gradle wrapper" })

map("n", "<leader>ji", function()
  local cmd = "gradle init --type java-application --dsl groovy"
  vim.cmd("split")
  vim.cmd("term " .. cmd)
  vim.cmd("startinsert")
  vim.notify("Initializing Gradle Java project")
end, { desc = "Java: Initialize Gradle project" })

map("n", "<leader>jb", function()
  local cmd = "./gradlew build"
  vim.cmd("split")
  vim.cmd("term " .. cmd)
  vim.cmd("startinsert")
  vim.notify("Building Gradle project")
end, { desc = "Java: Build Gradle project" })

map("n", "<leader>jg", function()
  local cmd = "./gradlew test"
  vim.cmd("split")
  vim.cmd("term " .. cmd)
  vim.cmd("startinsert")
  vim.notify("Running Gradle tests")
end, { desc = "Java: Run Gradle tests" })

-- VIM-VISUAL-MULTI ENHANCED KEYBINDINGS  
-- Alternative keybindings for vim-visual-multi if defaults don't work

map("n", "<leader>mn", function()
	if vim.fn.exists(':VMulti') > 0 then
		vim.cmd('normal! <Plug>(VM-Find-Under)')
	else
		print("vim-visual-multi not available")
	end
end, { desc = "Multi-cursor: Find word (alternative)" })

map("n", "<leader>ma", function()
	if vim.fn.exists(':VMulti') > 0 then
		vim.cmd('normal! <Plug>(VM-Select-All)')
	else
		print("vim-visual-multi not available")
	end
end, { desc = "Multi-cursor: Select all occurrences" })

map("v", "<leader>mn", function()
	if vim.fn.exists(':VMulti') > 0 then
		vim.cmd('normal! <Plug>(VM-Find-Subword-Under)')
	else
		print("vim-visual-multi not available")
	end
end, { desc = "Multi-cursor: Find selection (alternative)" })

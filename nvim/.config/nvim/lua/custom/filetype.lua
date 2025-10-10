-- Filetype detection for TypeScript/JavaScript files
-- Fix for missing .tsx/.jsx detection in Neovim 0.11

vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
    jsx = "javascriptreact",
    ts = "typescript",
    js = "javascript",
  },
  pattern = {
    [".*%.config%.ts"] = "typescript",
    [".*%.config%.js"] = "javascript",
  },
})

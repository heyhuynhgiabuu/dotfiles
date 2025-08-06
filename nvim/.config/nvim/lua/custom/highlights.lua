-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}

---@type Base46HLGroupsList
M.override = {
  Comment = {
    italic = true,
  },
}

---@type HLTable
M.add = {
  NvimTreeOpenedFolderName = { fg = "green", bold = true },
}

-- Auto-added missing required fields for Base46HLGroupsList
M.override = vim.tbl_extend('force', M.override, {
  nvUpdaterTitleFAIL = { fg = "red", bg = "NONE" },
  nvUpdaterTitleDone = { fg = "green", bg = "NONE" },
  nvUpdaterTitle = { fg = "yellow", bg = "NONE" },
  nvUpdaterProgressFAIL = { fg = "red", bg = "NONE" },
  nvUpdaterProgressDONE = { fg = "green", bg = "NONE" },
  nvUpdaterProgress = { fg = "yellow", bg = "NONE" },
  nvUpdaterFAIL = { fg = "red", bg = "NONE" },
  nvUpdaterCommits = { fg = "blue", bg = "NONE" },
  healthSuccess = { fg = "green", bg = "NONE" },
  gitcommitUntrackedFile = { link = "Normal" },
  gitcommitUntracked = { link = "Normal" },
  gitcommitUnmergedType = { link = "Normal" },
  gitcommitUnmergedFile = { link = "Normal" },
  gitcommitSummary = { link = "Normal" },
  gitcommitSelectedType = { link = "Normal" },
  gitcommitSelectedFile = { link = "Normal" },
  gitcommitSelected = { link = "Normal" },
  gitcommitOverflow = { link = "Normal" },
  gitcommitHeader = { link = "Normal" },
  gitcommitDiscardedType = { link = "Normal" },
  gitcommitDiscardedFile = { link = "Normal" },
  gitcommitDiscarded = { link = "Normal" },
  gitcommitComment = { link = "Comment" },
  gitcommitBranch = { link = "Normal" },
  diffOldFile = { link = "Normal" },
  diffNewFile = { link = "Normal" },
  WinSeparator = { link = "Normal" },
  WildMenu = { link = "Normal" },
  WhichKeyValue = { link = "Normal" },
  WhichKeySeparator = { link = "Normal" },
  WhichKeyGroup = { link = "Normal" },
  WhichKeyDesc = { link = "Normal" },
  WhichKey = { link = "Normal" },
  WarningMsg = { fg = "yellow", bg = "NONE" },
  VisualNOS = { link = "Visual" },
  Visual = { bg = "grey" },
  Variable = { link = "Normal" },
  UnderLined = { underline = true },
  Typedef = { link = "Type" },
  Type = { fg = "blue" },
  TooLong = { link = "Normal" },
  Todo = { fg = "yellow", bg = "NONE" },
  Title = { fg = "magenta", bold = true },
})

return M

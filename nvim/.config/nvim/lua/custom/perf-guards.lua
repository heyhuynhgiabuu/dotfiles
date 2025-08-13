-- Performance guards: disable expensive features for large or long-line files
-- Keeps editing responsive while preserving functionality for normal files.
-- Criteria:
--   * Large file: > 200 KB
--   * Extremely large file: > 1 MB (aggressive disable)
--   * Long line mode: any line > 2000 chars
-- Actions:
--   * Disable Treesitter highlight & indentation
--   * Disable LSP semantic tokens (if supported)
--   * Reduce update time & turn off certain UI plugins (optional hooks)

local api = vim.api
local M = {}

local function file_size(path)
  local ok, stat = pcall(vim.loop.fs_stat, path)
  if ok and stat then
    return stat.size or 0
  end
  return 0
end

local function has_long_line(buf, threshold)
  threshold = threshold or 2000
  local ok, lines = pcall(api.nvim_buf_get_lines, buf, 0, -1, false)
  if not ok then return false end
  for _, l in ipairs(lines) do
    if #l > threshold then return true end
  end
  return false
end

local function disable_feature(msg, fn)
  local ok, err = pcall(fn)
  if not ok then
    vim.schedule(function()
      vim.notify('[perf-guards] Failed to disable '..msg..': '..tostring(err), vim.log.levels.DEBUG)
    end)
  end
end

local function apply_guards(buf)
  local name = api.nvim_buf_get_name(buf)
  if name == '' then return end
  local size = file_size(name)
  local long_line = has_long_line(buf)

  local large = size > 200 * 1024 -- 200 KB
  local huge = size > 1024 * 1024 -- 1 MB

  if not (large or long_line) then return end

  vim.schedule(function()
    vim.notify(string.format('[perf] optimizing for %s%s%s',
      large and 'large-file ' or '', long_line and 'long-line ' or '', huge and '(HUGE)' or ''), vim.log.levels.INFO)
  end)

  -- Treesitter disable (if active)
  if pcall(require, 'nvim-treesitter') then
    disable_feature('treesitter highlight', function() vim.cmd('TSDisable highlight') end)
    disable_feature('treesitter indent', function() vim.cmd('TSDisable indent') end)
  end

  -- LSP semantic tokens (per client)
  for _, client in pairs(vim.lsp.get_active_clients({bufnr = buf})) do
    if client.server_capabilities.semanticTokensProvider then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end

  -- Option tweaks
  vim.bo[buf].syntax = 'off'
  vim.bo[buf].foldmethod = 'manual'
  vim.opt_local.updatetime = 1000
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.spell = false

  if huge then
    vim.opt_local.wrap = false
    vim.opt_local.colorcolumn = ''
  end
end

function M.setup()
  api.nvim_create_autocmd({'BufReadPost','BufNewFile'}, {
    callback = function(args)
      -- Defer to allow other plugins (like lazy) to finish
      vim.defer_fn(function()
        apply_guards(args.buf)
      end, 50)
    end,
  })
end

M.setup()
return M

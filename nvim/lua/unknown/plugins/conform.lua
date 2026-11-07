-- formater
-- See: https://github.com/stevearc/conform.nvim

-- Bypass mason .CMD wrappers on Windows — they break when path contains spaces
local is_win = vim.fn.has('win32') == 1
local mason_root = is_win and (vim.fn.stdpath('data') .. '/mason/packages/') or nil

local function mason_bin(pkg, subdir)
  if not is_win then return pkg end
  local path = mason_root .. pkg .. '/' .. (subdir or '') .. pkg .. '.exe'
  return vim.uv.fs_stat(path) and path or pkg
end

return {
  'stevearc/conform.nvim',
  dependencies = { 'mason-org/mason.nvim' },
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = false, -- Disabled auto-format on save; use <leader>f to format manually
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      go = { 'gofumpt', 'goimports' },
    },
    formatters = {
      ruff_format = { command = mason_bin('ruff', 'venv/Scripts/') },
      stylua = { command = mason_bin('stylua') },
      gofumpt = { command = mason_bin('gofumpt') },
      goimports = { command = mason_bin('goimports') },
    },
  },
}

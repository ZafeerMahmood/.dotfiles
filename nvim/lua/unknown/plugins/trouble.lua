-- Pretty, navigable lists for diagnostics, references, quickfix, symbols
-- The "Problems panel" — aggregates output from all your LSPs (gopls, ts_ls, pylsp, ruff, eslint)
-- See: https://github.com/folke/trouble.nvim

return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {
    focus = true,
  },
  keys = {
    { '<leader>dd', '<cmd>Trouble diagnostics toggle<cr>', desc = '[D]iagnostics (Trouble)' },
    { '<leader>dD', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = '[D] Buffer Diagnostics' },
    { '<leader>ds', '<cmd>Trouble symbols toggle focus=false<cr>', desc = '[D] Symbols' },
    { '<leader>dr', '<cmd>Trouble lsp_references toggle<cr>', desc = '[D] LSP References' },
    { '<leader>dl', '<cmd>Trouble loclist toggle<cr>', desc = '[D] Location List' },
    { '<leader>dq', '<cmd>Trouble qflist toggle<cr>', desc = '[D] Quickfix List' },
  },
}

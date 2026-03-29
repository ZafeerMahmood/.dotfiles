-- Merge conflict resolution with inline highlights and quick actions
-- See: https://github.com/akinsho/git-conflict.nvim

return {
  'akinsho/git-conflict.nvim',
  version = '*',
  event = 'BufReadPost',
  opts = {
    default_mappings = true, -- co (ours), ct (theirs), cb (both), c0 (none)
    default_commands = true, -- GitConflictChooseOurs, etc.
    highlights = {
      incoming = 'DiffAdd',
      current = 'DiffText',
    },
  },
  keys = {
    { ']x', '<cmd>GitConflictNextConflict<cr>', desc = 'Next conflict' },
    { '[x', '<cmd>GitConflictPrevConflict<cr>', desc = 'Prev conflict' },
    { '<leader>gc', '<cmd>GitConflictListQf<cr>', desc = '[G]it [c]onflict quickfix list' },
  },
}

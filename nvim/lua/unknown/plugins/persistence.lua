-- Session management
-- See: https://github.com/folke/persistence.nvim

return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  keys = {
    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore [S]ession' },
    { '<leader>qS', function() require('persistence').select() end, desc = 'Select [S]ession' },
  },
  opts = {},
}

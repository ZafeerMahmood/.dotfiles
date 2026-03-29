-- Fast navigation - jump anywhere with 2-3 keystrokes
-- See: https://github.com/folke/flash.nvim

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    { '<leader>z', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump' },
    { '<leader>Z', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
  },
}

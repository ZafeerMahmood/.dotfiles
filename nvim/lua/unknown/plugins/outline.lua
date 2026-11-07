-- Symbol outline sidebar
-- See: https://github.com/hedyhli/outline.nvim

return {
  'hedyhli/outline.nvim',
  cmd = 'Outline',
  keys = {
    { '<leader>o', '<cmd>Outline<CR>', desc = 'Toggle [O]utline' },
  },
  opts = {
    outline_window = {
      position = 'right',
      width = 30,
      auto_close = false,
      auto_jump = false,
    },
    symbol_folding = {
      autofold_depth = 1,
    },
  },
}

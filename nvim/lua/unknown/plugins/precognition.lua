-- Vim training: shows virtual text hints for available motions
-- See: https://github.com/tris203/precognition.nvim

return {
  'tris203/precognition.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>tp',
      function()
        require('precognition').toggle()
      end,
      desc = '[T]oggle [P]recognition',
    },
  },
  opts = {
    startVisible = false,
    showBlankVirtLine = false,
  },
}

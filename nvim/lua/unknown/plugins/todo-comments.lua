-- Highlight todo, notes, etc in comments
-- See: https://github.com/folke/todo-comments.nvim

return {
  'folke/todo-comments.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
  keys = {
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Prev Todo Comment' },
  },
}

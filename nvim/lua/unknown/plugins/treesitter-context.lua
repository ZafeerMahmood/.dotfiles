-- Sticky context headers (like VSCode)
-- Shows function/class headers at top when scrolling inside long blocks

return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = 'BufReadPost',
  opts = {
    max_lines = 3, -- Max lines to show at top
    multiline_threshold = 1, -- Max lines for single context
  },
  keys = {
    { '[C', function() require('treesitter-context').go_to_context() end, desc = 'Jump to [C]ontext (treesitter)' },
  },
}
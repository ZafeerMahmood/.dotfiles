-- Colorize matching brackets/parentheses/braces
-- Colors provided by unknown-decay theme
-- See: https://github.com/HiPhish/rainbow-delimiters.nvim

return {
  'hiphish/rainbow-delimiters.nvim',
  event = 'BufReadPost',
  config = function()
    local rainbow = require('rainbow-delimiters')
    require('rainbow-delimiters.setup').setup {
      strategy = {
        [''] = rainbow.strategy['global'],
        tsx = rainbow.strategy['global'],
        typescriptreact = rainbow.strategy['global'],
        markdown = rainbow.strategy['noop'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        tsx = 'rainbow-parens',
        typescriptreact = 'rainbow-parens',
        javascript = 'rainbow-parens',
        javascriptreact = 'rainbow-parens',
      },
    }
  end,
}

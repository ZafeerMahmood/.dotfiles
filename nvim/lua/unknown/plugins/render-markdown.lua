-- In-buffer markdown rendering (headings, lists, code blocks, tables, etc.)
-- See: https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Commands: :RenderMarkdown toggle | enable | disable | preview

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.nvim',
  },
  ft = { 'markdown' },
  cmd = { 'RenderMarkdown' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    file_types = { 'markdown', 'gitcommit' },
    render_modes = { 'n', 'c' },
    debounce = 200,
    max_file_size = 2.0,
    anti_conceal = { enabled = true, above = 0, below = 0 },
    completions = { lsp = { enabled = true } },

    heading = {
      sign = false,
      width = 'block',
      left_pad = 1,
      right_pad = 2,
      min_width = 60,
      border = true,
      border_virtual = true,
      position = 'inline',
      icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ' },
    },

    code = {
      sign = false,
      style = 'full',
      width = 'block',
      left_pad = 1,
      right_pad = 2,
      min_width = 60,
      border = 'thick',
      language_pad = 2,
    },

    bullet = {
      left_pad = 1,
      right_pad = 1,
      icons = { '●', '○', '◆', '◇' },
    },

    checkbox = {
      unchecked = { icon = '󰄱 ' },
      checked   = { icon = '󰱒 ' },
    },

    dash = { icon = '─' },

    pipe_table = {
      style = 'normal',
      preset = 'round',
      cell = 'trimmed',
      padding = 1,
    },
  },
  keys = {
    { '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', desc = '[T]oggle [M]arkdown render' },
  },
}

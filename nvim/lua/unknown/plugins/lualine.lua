-- Feature-rich statusline
-- See: https://github.com/nvim-lualine/lualine.nvim

return {
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'auto',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      globalstatus = true,
      disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'snacks_dashboard' } },
    },
    sections = {
      lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
      lualine_b = { 'branch' },
      lualine_c = {
        {
          'diagnostics',
          symbols = { error = ' ', warn = ' ', info = ' ', hint = '󰌵 ' },
        },
        { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
        { 'filename', path = 1 },
      },
      lualine_x = {
        {
          function()
            local reg = vim.fn.reg_recording()
            if reg ~= '' then return ' @' .. reg end
            return ''
          end,
          cond = function() return vim.fn.reg_recording() ~= '' end,
          color = { fg = '#ff6666' },
        },
        {
          function() return require('noice').api.status.command.get() end,
          cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
        },
        {
          require('lazy.status').updates,
          cond = require('lazy.status').has_updates,
          color = { fg = '#ff9e64' },
        },
        {
          'diff',
          symbols = { added = ' ', modified = ' ', removed = ' ' },
        },
      },
      lualine_y = {
        { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
        { 'location', padding = { left = 0, right = 1 } },
      },
      lualine_z = { { 'filetype', separator = { right = '' }, left_padding = 2 } },
    },
    extensions = { 'lazy', 'quickfix', 'fugitive' },
  },
}

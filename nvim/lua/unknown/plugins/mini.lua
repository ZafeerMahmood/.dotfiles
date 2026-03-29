-- Collection of various small independent plugins/modules
-- See: https://github.com/echasnovski/mini.nvim

return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Move lines/selections with Shift+Arrow keys (hold Shift, press arrows repeatedly)
    require('mini.move').setup {
      mappings = {
        -- Move visual selection
        left = '<S-Left>',
        right = '<S-Right>',
        down = '<S-Down>',
        up = '<S-Up>',
        -- Move current line in Normal mode
        line_left = '<S-Left>',
        line_right = '<S-Right>',
        line_down = '<S-Down>',
        line_up = '<S-Up>',
      },
      options = {
        reindent_linewise = true, -- Auto-indent when moving lines vertically
      },
    }

    -- NOTE: mini.statusline disabled - using lualine instead (see lua/custom/plugins/lualine.lua)
    -- local statusline = require 'mini.statusline'
    -- statusline.setup { use_icons = vim.g.have_nerd_font }
    -- statusline.section_location = function()
    --   return '%2l:%-2v'
    -- end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}

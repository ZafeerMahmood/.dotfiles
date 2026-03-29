-- Shows pending keybinds in a popup
-- See: https://github.com/folke/which-key.nvim

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'modern',
    delay = 0,
    icons = {
      -- Set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    -- Document existing key chains
    spec = {
      { '<leader>a', group = '[A]I Claude', icon = { icon = ' ', color = 'orange' } },
      { '<leader>b', group = '[B]uffer', icon = { icon = '󰈔 ', color = 'cyan' } },
      { '<leader>c', group = '[C]ode', icon = { icon = ' ', color = 'blue' } },
      { '<leader>g', group = '[G]it', icon = { icon = '󰊢 ', color = 'red' } },
      { '<leader>h', group = 'Git [H]unk', icon = { icon = ' ', color = 'green' }, mode = { 'n', 'v' } },
      { '<leader>m', group = '[M]arks (Harpoon)', icon = { icon = '󱡀 ', color = 'cyan' } },
      { '<leader>l', group = '[L]int', icon = { icon = '󱉶 ', color = 'yellow' } },
      { '<leader>s', group = '[S]earch', icon = { icon = ' ', color = 'purple' } },
      { '<leader>sn', group = '[N]oice', icon = { icon = '󰍡 ', color = 'yellow' } },
      { '<leader>t', group = '[T]oggle', icon = { icon = ' ', color = 'azure' } },
      { '<leader>e', icon = { icon = '󰙅 ', color = 'green' } },
      { '<leader>f', icon = { icon = '󰉢 ', color = 'blue' } },
      { '<leader>q', icon = { icon = ' ', color = 'red' } },
      { '<leader>r', icon = { icon = '󰛔 ', color = 'orange' } },
      { '<leader>x', icon = { icon = '󰅖 ', color = 'red' } },
      { '<leader>X', icon = { icon = '󰅗 ', color = 'red' } },
      { '<leader>z', icon = { icon = '⚡', color = 'yellow' } },
      { '<leader>/', icon = { icon = '󰆉 ', color = 'grey' } },
    },
  },
}

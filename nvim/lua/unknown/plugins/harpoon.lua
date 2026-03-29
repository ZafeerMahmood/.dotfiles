-- Harpoon for file switching
-- github: https://github.com/ThePrimeagen/harpoon

-- return {} -- not setup for now 
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>ma', function() require('harpoon'):list():add() end, desc = 'Harpoon [a]dd file' },
    { '<leader>mR', function() require('harpoon'):list():remove() end, desc = 'Harpoon [r]emove file' },
    { '<leader>mm', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon [m]enu' },
    { '<leader>mn', function() require('harpoon'):list():next() end, desc = 'Harpoon [n]ext' },
    { '<leader>mp', function() require('harpoon'):list():prev() end, desc = 'Harpoon [p]rev' },
    { '<leader>1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon file 1' },
    { '<leader>2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon file 2' },
    { '<leader>3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon file 3' },
    { '<leader>4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon file 4' },
    { '<leader>5', function() require('harpoon'):list():select(5) end, desc = 'Harpoon file 5' },
  },
  config = function()
    require('harpoon'):setup()
  end,
}

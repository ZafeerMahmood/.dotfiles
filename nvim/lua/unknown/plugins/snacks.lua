-- Snacks.nvim utilities
-- See: https://github.com/folke/snacks.nvim

local homer = [[
                       _ ,___,-'",-=-.
           __,-- _ _,-'_)_  (""`'-._\ `.
        _,'  __ |,' ,-' __)  ,-     /. |
      ,'_,--'   |     -'  _)/         `\
    ,','      ,'       ,-'_,`           :
    ,'     ,-'       ,(,-(              :
         ,'       ,-' ,    _            ;
        /        ,-._/`---'            /
       /        (____)(----. )       ,'
      /         (      `.__,     /\ /,
     :           ;-.___         /__\/|
     |         ,'      `--.      -,\ |
     :        /            \    .__/
      \      (__            \    |_
       \       ,`-, *       /   _|,\
        \    ,'   `-.     ,'_,-'    \
       (_\,-'    ,'\")-,'-'       __\
        \       /  // ,'|      ,--'  `-.
         `-.    `-/ \'  |   _,'         `.
            `-._ /      `--'/             \
    -hrr-      ,'           |              \
              /             |               \
           ,-'              |               /
          /                 |             -']]

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    { '<C-\\>', function() Snacks.terminal(nil, { win = { position = 'float', border = 'rounded' } }) end, desc = 'Toggle terminal' },
  },
  opts = {
    bigfile = { enabled = true, size = 1.5 * 1024 * 1024 },
    dashboard = {
      enabled = true,
      preset = {
        header = homer,
        keys = {
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
          { icon = ' ', key = 'c', desc = 'Config', action = ':e $MYVIMRC' },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      sections = {
        { section = 'header', align = 'center' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup', align = 'center' },
      },
    },
    indent = {
      enabled = true,
      animate = { enabled = false },
    },
    scroll = {
      enabled = false,
    },
    terminal = { enabled = true },
  },
}

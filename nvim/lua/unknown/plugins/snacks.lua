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
    bigfile = {
      enabled = true,
      size = 1.5 * 1024 * 1024,
      line_length = 1000, -- also flag files with very long lines (minified bundles under the size cap)
      setup = function(ctx)
        -- treesitter / gitsigns / ufo already opt out of ft=bigfile; also calm matchparen + mini
        if vim.fn.exists ':NoMatchParen' ~= 0 then
          vim.cmd 'NoMatchParen'
        end
        vim.b[ctx.buf].minihipatterns_disable = true
        vim.b[ctx.buf].minianimate_disable = true
        -- cheap regex syntax instead of treesitter highlighting
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
    },
    dashboard = {
      enabled = true,
      preset = {
        header = homer,
        keys = {
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
          { icon = ' ', key = 's', desc = 'Restore Session', action = function() require('persistence').load() end },
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

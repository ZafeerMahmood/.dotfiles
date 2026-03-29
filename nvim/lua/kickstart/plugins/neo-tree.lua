-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = { 'Neotree' },
  keys = {
    { '<leader>e', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
  },
  opts = {
    close_if_last_window = true,
    window = {
      position = 'float',
      mappings = {
        ['<leader>e'] = 'close_window',
      },
    },
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          '.git',
        },
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = false, -- NOTE: change this to true if you need latest changes in neo-tree without 'R'
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)
  end,
}

-- Fuzzy Finder (files, LSP, etc)
-- See: https://github.com/nvim-telescope/telescope.nvim

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  keys = {
    { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', function()
      require('telescope.builtin').find_files {
        find_command = {
          'fd', '--type', 'f', '--hidden', '--no-ignore', '--path-separator', '/',
          '--exclude', '.git',
          '--exclude', 'env',
          '--exclude', 'venv',
          '--exclude', '.venv',
          '--exclude', '.ruff_cache',
          '--exclude', '.pytest_cache',
          '--exclude', '__pycache__',
          '--exclude', '.mypy_cache',
          '--exclude', 'node_modules',
          '--exclude', '.turbo',
          '--exclude', '.next',
          '--exclude', 'dist',
          '--exclude', 'build',
          '--exclude', '.cache',
          '--exclude', 'target',
          '--exclude', '.cargo',
          '--exclude', '.tox',
          '--exclude', 'vendor',
          '--exclude', 'bower_components',
          '--exclude', 'release',
        },
      }
    end, desc = 'Find Files (Ctrl+P)' },
    { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
    { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
    { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
    { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },
    { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
    { '<C-f>', function()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, desc = '[F]uzzily search in current buffer' },
    { '<leader>s/', function()
      require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, desc = '[S]earch [/] in Open Files' },
    { '<leader>sc', function()
      require('telescope.builtin').find_files {
        cwd = vim.fn.stdpath 'config',
        find_command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--path-separator', '/' },
      }
    end, desc = '[S]earch nvim [C]onfig' },
  },
  config = function()
    local actions = require 'telescope.actions'

    -- Center buffer after Telescope selection
    local center_after_select = function(prompt_bufnr)
      actions.select_default(prompt_bufnr)
      vim.schedule(function()
        vim.cmd 'normal! zz'
      end)
    end

    require('telescope').setup {
      defaults = {
        path_display = function(_, path)
          local tail = vim.fn.fnamemodify(path, ':t')
          local dir = vim.fn.fnamemodify(path, ':h')
          if dir == '.' then
            return tail
          end
          return tail .. '  ' .. dir
        end,
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--path-separator', '/',
        },
        mappings = {
          i = {
            ['<CR>'] = center_after_select,
            ['<c-enter>'] = 'to_fuzzy_refine',
            ['<C-v>'] = function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-r>+', true, false, true), 'n', false)
            end,
          },
          n = {
            ['<CR>'] = center_after_select,
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end,
}

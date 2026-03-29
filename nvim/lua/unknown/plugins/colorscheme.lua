-- Colorscheme
-- Saves your colorscheme choice and restores it on startup

local colorscheme_file = vim.fn.stdpath 'data' .. '/colorscheme.txt'

local function save_colorscheme(name)
  local file = io.open(colorscheme_file, 'w')
  if file then
    file:write(name)
    file:close()
  end
end

local function load_saved_colorscheme()
  local file = io.open(colorscheme_file, 'r')
  if file then
    local name = file:read '*a'
    file:close()
    return name
  end
  return nil
end

local function colorscheme_picker()
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values

  -- Filter out default Neovim colorschemes
  local DEFAULT_SCHEMES = {
    'blue', 'darkblue', 'default', 'delek', 'desert', 'elflord', 'evening',
    'habamax', 'industry', 'koehler', 'lunaperche', 'morning', 'murphy',
    'pablo', 'peachpuff', 'quiet', 'retrobox', 'ron', 'shine', 'slate',
    'sorbet', 'torte', 'unokai', 'vim', 'wildcharm', 'zaibatsu', 'zellner',
  }
  local defaults = {}
  for _, s in ipairs(DEFAULT_SCHEMES) do defaults[s] = true end
  local colors = vim.tbl_filter(function(c) return not defaults[c] end, vim.fn.getcompletion('', 'color'))

  -- Store original colorscheme for preview restore on cancel
  local original = vim.g.colors_name or 'default'
  local confirmed = false

  -- Live preview helper
  local function preview_selection()
    local entry = action_state.get_selected_entry()
    if entry then pcall(vim.cmd.colorscheme, entry.value) end
  end

  pickers
    .new({}, {
      prompt_title = 'Select Colorscheme (saves automatically)',
      finder = finders.new_table { results = colors },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        -- Live preview on cursor movement
        actions.move_selection_next:enhance { post = preview_selection }
        actions.move_selection_previous:enhance { post = preview_selection }

        -- Save on confirm
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          confirmed = true
          actions.close(prompt_bufnr)
          if selection then
            vim.cmd.colorscheme(selection.value)
            save_colorscheme(selection.value)
            vim.notify('Colorscheme saved: ' .. selection.value, vim.log.levels.INFO)
          end
        end)

        -- Restore original on cancel
        actions.close:enhance {
          post = function()
            if not confirmed then
              pcall(vim.cmd.colorscheme, original)
            end
          end,
        }
        return true
      end,
    })
    :find()
end

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    opts = {
      flavour = 'mocha',
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
        loops = { 'italic' },
        functions = {},        -- keep normal
        keywords = { 'italic' },
        strings = {},
        variables = {},
        numbers = {},
        booleans = { 'italic' },
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        neo_tree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        gitsigns = true,
        mini = true,
        native_lsp = { enabled = true },
      },
    },
  },
  {
    'ZafeerMahmood/unknown-decay.nvim',
    name = 'unknown-decay',
    lazy = false,
    priority = 1000,
    config = function()
      require('unknown-decay').setup {
        transparent = false,
        italics = {
          comments = true,
          keywords = false,
          parameters = true,
          strings = false,
          variables = false,
        },
      }

      -- Load saved colorscheme or default to unknown-decay
      local saved = load_saved_colorscheme()
      if saved and saved ~= '' then
        local ok, _ = pcall(vim.cmd.colorscheme, saved)
        if not ok then
          vim.cmd.colorscheme 'catppuccin'
        end
      else
        vim.cmd.colorscheme 'catppuccin'
      end
    end,
  },

  

  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    opts = {
      variant = 'auto',
      styles = {
        italic = false,
      },
    },
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    opts = {
      styles = {
        comments = { italic = false },
      },
    },
  },

  {
    'ellisonleao/gruvbox.nvim',
    name = 'gruvbox',
    lazy = false,
    opts = {
      contrast = 'hard',
      italic = {
        strings = false,
        comments = true,
        operators = false,
      },
    },
  },

  {
    'sainnhe/gruvbox-material',
    name = 'gruvbox-material',
    lazy = false,
    config = function()
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_enable_italic = 1
    end,
  },

  {
    'EdenEast/nightfox.nvim',
    name = 'nightfox',
    lazy = false,
    opts = {
      options = {
        styles = {
          comments = 'italic',
          keywords = 'bold',
        },
      },
    },
  },

  -- Colorscheme picker keymap
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    keys = {
      {
        '<leader>cs',
        colorscheme_picker,
        desc = '[C]olor[s]cheme picker (persistent)',
      },
    },
  },
}

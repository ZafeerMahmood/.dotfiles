-- Core options
-- Use pwsh with minimal config for faster startup

vim.o.shell = 'pwsh'
vim.o.shellcmdflag = '-NoLogo -NoProfile -Command'
vim.o.shellquote = ''
vim.o.shellxquote = ''

-- Spell check
vim.opt.spell = true
vim.opt.spelllang = 'en_us'

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Mouse
vim.o.mouse = 'a'

-- Don't show mode (status line handles it)
vim.o.showmode = false

-- Sync clipboard (deferred for startup perf)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Indentation
vim.o.breakindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

-- Undo
vim.o.undofile = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- UI
vim.o.signcolumn = 'yes'
vim.o.foldcolumn = '0'
vim.o.statuscolumn = string.rep(' ', 7) .. '%=%l %s'
vim.o.updatetime = 250
vim.o.winborder = 'rounded'
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.synmaxcol = 240
vim.o.confirm = true

-- Neovide
if vim.g.neovide then
  vim.o.guifont = 'JetBrainsMonoNL Nerd Font Propo:h16:#e-subpixelantialias'
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.cmd 'highlight Cursor guifg=black guibg=#F9E2AF'
  vim.g.neovide_input_use_logo = false

  -- Terminal ANSI colors (match Windows Terminal Catppuccin Mocha)
  vim.g.terminal_color_0 = '#45475A'   -- black
  vim.g.terminal_color_1 = '#F38BA8'   -- red
  vim.g.terminal_color_2 = '#A6E3A1'   -- green
  vim.g.terminal_color_3 = '#F9E2AF'   -- yellow
  vim.g.terminal_color_4 = '#89B4FA'   -- blue
  vim.g.terminal_color_5 = '#F5C2E7'   -- purple
  vim.g.terminal_color_6 = '#94E2D5'   -- cyan
  vim.g.terminal_color_7 = '#BAC2DE'   -- white
  vim.g.terminal_color_8 = '#585B70'   -- bright black
  vim.g.terminal_color_9 = '#F38BA8'   -- bright red
  vim.g.terminal_color_10 = '#A6E3A1'  -- bright green
  vim.g.terminal_color_11 = '#F9E2AF'  -- bright yellow
  vim.g.terminal_color_12 = '#89B4FA'  -- bright blue
  vim.g.terminal_color_13 = '#F5C2E7'  -- bright purple
  vim.g.terminal_color_14 = '#94E2D5'  -- bright cyan
  vim.g.terminal_color_15 = '#A6ADC8'  -- bright white
end

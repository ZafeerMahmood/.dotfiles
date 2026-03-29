-- Core autocommands
-- Extracted from init.lua — autocommands and filetype additions

-- Clean stale shada temp files on startup
local shada_dir = vim.fn.stdpath 'data' .. '/shada'
for _, f in ipairs(vim.fn.glob(shada_dir .. '/main.shada.tmp.*', false, true)) do
  vim.uv.fs_unlink(f)
end

-- Ensure .mjs and other JS variants are recognized correctly
vim.filetype.add {
  extension = {
    mjs = 'javascript',
    cjs = 'javascript',
  },
}

-- Transparent background — :TransparentBg to toggle
local transparent = { enabled = false, saved = {} }
local bg_groups = { 'Normal', 'NormalNC', 'NormalFloat', 'SignColumn', 'EndOfBuffer' }

local function set_transparent(on)
  if on then
    for _, g in ipairs(bg_groups) do
      transparent.saved[g] = vim.api.nvim_get_hl(0, { name = g }).bg
      vim.api.nvim_set_hl(0, g, { bg = 'NONE' })
    end
  else
    for g, bg in pairs(transparent.saved) do
      vim.api.nvim_set_hl(0, g, { bg = bg })
    end
  end
  transparent.enabled = on
end

vim.api.nvim_create_user_command('TransparentBg', function()
  set_transparent(not transparent.enabled)
end, { desc = 'Toggle transparent background' })

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('transparent-bg', { clear = true }),
  callback = function()
    if not vim.g.neovide then set_transparent(true) end
  end,
})
if not vim.g.neovide then set_transparent(true) end

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

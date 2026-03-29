-- Core keymaps
-- Extracted from init.lua — all global keymaps

local map = vim.keymap.set

-- Spell suggest via Telescope
-- map('n', 'z=', function() require('telescope.builtin').spell_suggest() end, { desc = 'Spell suggestions' })

-- Change without yanking
map('n', 'c', '"_c', { desc = 'Change without yanking' })
map('n', 'C', '"_C', { desc = 'Change to EOL without yanking' })
map('v', 'c', '"_c', { desc = 'Change without yanking' })
map('v', 'C', '"_C', { desc = 'Change without yanking' })

-- Windows-style clipboard
map('v', '<C-c>', '"+y', { desc = 'Copy to clipboard' })
map('n', '<C-v>', '"+p', { desc = 'Paste from clipboard' })
map('v', '<C-v>', '"+p', { desc = 'Paste from clipboard' })
map('i', '<C-v>', '<C-r>+', { desc = 'Paste from clipboard' })
map('n', '<C-z>', '<C-r>', { desc = 'Redo' })
map('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Center after scroll/search/jump
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search result and center' })
map('n', '*', '*zz', { desc = 'Search word forward and center' })
map('n', '#', '#zz', { desc = 'Search word backward and center' })
map('n', 'G', 'Gzz', { desc = 'Go to line and center' })
map('n', 'gg', 'ggzz', { desc = 'Go to top and center' })
map('n', "'", "''zz", { desc = 'Jump to mark line and center' })
map('n', '`', '``zz', { desc = 'Jump to mark and center' })
map('n', '<C-o>', '<C-o>zz', { desc = 'Jump back and center' })
map('n', '<C-i>', '<C-i>zz', { desc = 'Jump forward and center' })
map('n', '{', '{zz', { desc = 'Prev paragraph and center' })
map('n', '}', '}zz', { desc = 'Next paragraph and center' })
map('n', '[[', '[[zz', { desc = 'Prev section and center' })
map('n', ']]', ']]zz', { desc = 'Next section and center' })
map('n', '%', '%zz', { desc = 'Match bracket and center' })

-- Diagnostics
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) vim.cmd('normal! zz') end, { desc = 'Next diagnostic' })
map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) vim.cmd('normal! zz') end, { desc = 'Prev diagnostic' })
map('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) vim.cmd('normal! zz') end, { desc = 'Next error' })
map('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) vim.cmd('normal! zz') end, { desc = 'Prev error' })
map('n', ']w', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN }) vim.cmd('normal! zz') end, { desc = 'Next warning' })
map('n', '[w', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN }) vim.cmd('normal! zz') end, { desc = 'Prev warning' })

-- Comments
map('n', '<leader>/', 'gcc', { desc = 'Toggle comment', remap = true })
map('v', '<leader>/', 'gc', { desc = 'Toggle comment', remap = true })

-- Terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-\\>', '<C-\\><C-n>', { desc = 'Exit terminal mode (Ctrl+\\)' })
map('t', '<C-v>', '<C-\\><C-n>"+pi', { desc = 'Paste from clipboard (terminal)' })

-- Window navigation
map('n', '<C-Left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-Right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-Down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-Up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Search and replace
map('n', '<leader>r', function()
  local word = vim.fn.expand '<cword>'
  if word ~= '' then
    word = vim.fn.escape(word, [[/\.*$^~[]])
    vim.fn.feedkeys(':%s/' .. word .. '/', 'n')
  else
    vim.fn.feedkeys(':%s/', 'n')
  end
end, { desc = '[R]eplace word in buffer' })
map('v', '<leader>r', 'y:%s/<C-r>"/', { desc = '[R]eplace selection in buffer' })

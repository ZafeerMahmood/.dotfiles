-- AI-powered coding assistant inside Neovim
-- See: https://github.com/coder/claudecode.nvim

return {
  'coder/claudecode.nvim',
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', mode = { 'n' }, desc = '[A]I [C]laude toggle' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', mode = { 'n' }, desc = '[A]I [F]ocus Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = '[A]I [R]esume session' },
    { '<leader>aR', '<cmd>ClaudeCode --continue<cr>', desc = '[A]I continue (cont[R]ol)' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = '[A]I select [M]odel' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = '[A]I add [B]uffer to context' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = '[A]I [S]end selection' },
  },
  opts = {
    terminal = {
      split_side = 'right',
      split_width_percentage = 0.40,
      snacks_win_opts = {
        env = vim.fn.has('win32') == 1 and { SHELL = 'cmd' } or nil,
      },
    },
  },
  config = function(_, opts)
    require('claudecode').setup(opts)

    -- Disable editor diff view — diffs stay in the Claude terminal only
    local tools = require('claudecode.tools.init')
    tools.tools['openDiff'] = nil
    tools.tools['closeAllDiffTabs'] = nil

    -- Auto-reload buffers when files change on disk (after diff accept/deny)
    vim.o.autoread = true
    vim.api.nvim_create_autocmd({ 'FocusGained' }, {
      callback = function()
        vim.cmd('checktime')
      end,
    })
  end,
}
-- return {}


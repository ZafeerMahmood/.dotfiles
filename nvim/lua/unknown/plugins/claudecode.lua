-- AI-powered coding assistant inside Neovim
-- See: https://github.com/coder/claudecode.nvim

return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' }, -- terminal provider (provider = 'auto')
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = '[A]I [C]laude toggle' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = '[A]I [F]ocus Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = '[A]I [R]esume session' },
    { '<leader>aR', '<cmd>ClaudeCode --continue<cr>', desc = '[A]I continue (cont[R]ol)' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = '[A]I select [M]odel' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = '[A]I add [B]uffer to context' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = '[A]I [S]end selection' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = '[A]I [A]ccept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = '[A]I [D]eny diff' },
  },
  opts = {
    -- NOTE: env vars scoped to the nvim-launched Claude CLI only (standalone terminal / global
    -- default untouched). ANTHROPIC_MODEL pins Sonnet 5 + 1M context ([1m] suffix) as the
    -- default here; switch per-session via <leader>am (press 's' = session-only, won't persist).
    -- SHELL=cmd -> cmd.exe for the Bash tool on Windows. CLAUDE_CODE_NO_FLICKER=1 stops flicker.
    env = {
      SHELL = vim.fn.has('win32') == 1 and 'cmd' or nil,
      ANTHROPIC_MODEL = 'claude-sonnet-5[1m]',
      CLAUDE_CODE_NO_FLICKER = '1',
    },
    -- Right split terminal (auto provider).
    terminal = {
      split_side = 'right',
      split_width_percentage = 0.40,
    },
    -- In-editor diff view for Claude's edits (accept/deny via <leader>aa / <leader>ad).
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = false,
      open_in_current_tab = false,
    },
  },
  config = function(_, opts)
    require('claudecode').setup(opts)

    local group = vim.api.nvim_create_augroup('claudecode', { clear = true })

    -- NOTE: claudecode diff buffers (acwrite) open in insert mode; force normal.
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function()
        if vim.bo.buftype == 'acwrite' then
          vim.schedule(function() vim.cmd('stopinsert') end)
        end
      end,
    })

    -- NOTE: reload buffers changed on disk (e.g. after accepting a diff). FocusGained misses
    -- intra-nvim switches (terminal <-> code buffer), so also reload on enter/idle. autoread
    -- is on by default in Neovim; checktime is what actually triggers the reload.
    vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
      group = group,
      callback = function()
        if vim.bo.buftype == '' then vim.cmd('checktime') end
      end,
    })
  end,
}
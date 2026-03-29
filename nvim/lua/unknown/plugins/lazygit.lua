-- Full git UI inside nvim
-- See: https://github.com/kdheepak/lazygit.nvim

return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'Open LazyGit' },
    { '<leader>gf', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit current file history' },
  },
  config = function()
    -- Let lazygit handle its own keybindings natively
    -- q = quit lazygit, Esc = go back from current view
  end,
}

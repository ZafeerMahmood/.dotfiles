-- Side-by-side git diffs
-- See: https://github.com/sindrets/diffview.nvim

return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [d]iff view' },
    { '<leader>gD', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it file history [D]iff' },
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = '[G]it diff [q]uit' },
  },
  opts = function()
    local actions = require 'diffview.actions'
    return {
      keymaps = {
        view = { q = actions.close },
        file_panel = { q = actions.close },
        file_history_panel = { q = actions.close },
      },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.foldenable = false
          vim.opt_local.foldcolumn = '0'
        end,
        view_closed = function()
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_get_name(buf):match 'diffview://' then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end)
        end,
      },
    }
  end,
}

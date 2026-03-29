-- VS Code-like tabs at the top
-- See: https://github.com/akinsho/bufferline.nvim

return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = 'BufAdd',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      mode = 'buffers',
      separator_style = 'thin',
      show_buffer_close_icons = true,
      show_close_icon = false,
      diagnostics = 'nvim_lsp',
      -- Show a dot for modified/unsaved buffers
      indicator = {
        style = 'icon',
        icon = ' ',
      },
      modified_icon = '●', -- dot for unsaved changes
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'File Explorer',
          text_align = 'center',
          separator = true,
        },
      },
    },
  },
  config = function(_, opts)
    require('bufferline').setup(opts)
    -- Keymaps for switching buffers
    vim.keymap.set('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
    vim.keymap.set('n', '<leader>x', function()
      local buf_to_close = vim.api.nvim_get_current_buf()
      vim.cmd('BufferLineCyclePrev')
      vim.cmd('bdelete ' .. buf_to_close)
    end, { desc = 'Close buffer' })

    vim.keymap.set('n', '<leader>X', function()
      local exclude_ft = { 'neo-tree', 'terminal', 'lazygit', 'fugitive', 'gitcommit', 'diff', 'claudecode' }
      local exclude_bt = { 'terminal', 'nofile', 'prompt', 'quickfix' }
      local bufs_to_close = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
          local ft = vim.bo[buf].filetype
          local bt = vim.bo[buf].buftype
          local name = vim.api.nvim_buf_get_name(buf)
          if name ~= '' and not vim.tbl_contains(exclude_ft, ft) and not vim.tbl_contains(exclude_bt, bt) then
            table.insert(bufs_to_close, buf)
          end
        end
      end
      if #bufs_to_close > 0 then
        vim.cmd('enew')
        for _, buf in ipairs(bufs_to_close) do
          pcall(vim.cmd, 'bdelete ' .. buf)
        end
      end
    end, { desc = 'Close all code buffers' })
  end,
}

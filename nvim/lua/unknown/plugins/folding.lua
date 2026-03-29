  -- Folding
  -- Uses treesitter for smart folding
  -- Standard vim fold commands: za (toggle), zc (close), zo (open), zM (close all), zR (open all)

  return {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    event = 'BufReadPost',
    init = function()
      -- foldcolumn set in init.lua
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- hide the foldcolumn guides/chars
      vim.opt.fillchars:append({
        fold = " ",
        foldopen = " ",
        foldclose = " ",
        foldsep = " ",
      })
    end,
    opts = {
      provider_selector = function(bufnr, filetype, _)
        -- Skip special buffers (diffview, terminals, etc.)
        if vim.bo[bufnr].buftype ~= '' then return '' end
        local indent_filetypes = { 'markdown', 'text', 'txt' }
        if vim.tbl_contains(indent_filetypes, filetype) then
          return { 'indent' }
        end
        return { 'treesitter', 'indent' }
      end,
    },
  }


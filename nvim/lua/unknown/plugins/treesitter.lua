-- Highlight, edit, and navigate code
-- See: https://github.com/nvim-treesitter/nvim-treesitter

return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = ':TSUpdate',
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    -- On the pinned `main` branch, setup() only consumes `install_dir` — `ensure_installed`
    -- is silently ignored, so install any missing parsers explicitly (async, non-blocking).
    local ts = require 'nvim-treesitter'
    ts.setup {}

    local ensure = {
      'bash', 'c', 'cpp', 'c_sharp', 'diff', 'lua', 'luadoc', 'query', 'vim', 'vimdoc',
      'html', 'css', 'scss', 'javascript', 'typescript', 'tsx', 'json', 'json5',
      'python', 'go', 'gomod', 'gosum',
      'markdown', 'markdown_inline', 'yaml', 'toml', 'dockerfile',
      'gitcommit', 'gitignore',
    }
    local installed = {}
    for _, p in ipairs(ts.get_installed 'parsers') do installed[p] = true end
    local missing = vim.tbl_filter(function(p) return not installed[p] end, ensure)
    if #missing > 0 then ts.install(missing) end

    -- Enable treesitter highlighting for all filetypes with a parser
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function()
        if vim.bo.buftype ~= '' then return end
        -- snacks.bigfile flags huge/minified files as ft=bigfile; skip treesitter so it
        -- doesn't attach a full parser to them (mirrors the guard in folding.lua).
        if vim.bo.filetype == 'bigfile' then return end
        pcall(vim.treesitter.start)
      end,
    })
  end,
}

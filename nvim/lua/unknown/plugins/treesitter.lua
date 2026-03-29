-- Highlight, edit, and navigate code
-- See: https://github.com/nvim-treesitter/nvim-treesitter

return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = ':TSUpdate',
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    require('nvim-treesitter').setup {
      ensure_installed = {
        'bash', 'c', 'diff', 'lua', 'luadoc', 'query', 'vim', 'vimdoc',
        'html', 'css', 'scss', 'javascript', 'typescript', 'tsx', 'json', 'json5',
        'python', 'go', 'gomod', 'gosum',
        'markdown', 'markdown_inline', 'yaml', 'toml', 'dockerfile',
        'gitcommit', 'gitignore',
      },

      install = {
        prefer_git = false,
        compilers = { 'zig', 'gcc', 'clang', 'cl' },
      },
    }

    -- Enable treesitter highlighting for all filetypes with a parser
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        local bufftype = vim.bo.buftype
        if bufftype ~= '' then return end
        pcall(vim.treesitter.start)
      end,
    })
  end,
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}

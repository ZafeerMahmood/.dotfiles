-- Auto-close and auto-rename HTML/JSX/TSX tags (the React/Next ergonomic autopairs doesn't do)
-- Complements nvim-autopairs (brackets) — different domains, run together.
-- See: https://github.com/windwp/nvim-ts-autotag

return {
  'windwp/nvim-ts-autotag',
  ft = { 'html', 'xml', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx' },
  -- Modern API: calls require('nvim-ts-autotag').setup(opts) directly; does NOT hook into
  -- nvim-treesitter configs (important on the pinned treesitter `main` branch).
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  },
}

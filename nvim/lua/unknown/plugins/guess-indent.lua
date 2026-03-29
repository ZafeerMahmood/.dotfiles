-- Detect tabstop and shiftwidth automatically
-- See: https://github.com/NMAC427/guess-indent.nvim

return {
  'NMAC427/guess-indent.nvim',
  event = 'BufReadPre',
  opts = {},
}

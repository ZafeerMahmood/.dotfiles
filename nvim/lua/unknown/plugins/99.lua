-- Agentic search/edit workflow driven by an AI CLI (provider = Claude Code)
-- See: https://github.com/ThePrimeagen/99

return {
  'ThePrimeagen/99',
  keys = {
    { '<leader>9v', function() require('99').visual() end, mode = 'v', desc = '99 replace [V]isual selection' },
    { '<leader>9x', function() require('99').stop_all_requests() end, desc = '99 cancel requests' },
    { '<leader>9l', function() require('99').view_logs() end, desc = '99 view [L]ogs' },
    { '<leader>9i', function() require('99').info() end, desc = '99 [I]nfo' },
    -- NOTE: not the telescope model picker -- upstream hardcodes a stale list (no
    -- sonnet-5/opus-5), so picking from it would silently downgrade the model.
    {
      '<leader>9m',
      function()
        local _99 = require('99')
        _99.set_model(_99.get_model() == 'claude-sonnet-5' and 'claude-opus-5' or 'claude-sonnet-5')
        vim.notify('99: model ' .. _99.get_model())
      end,
      desc = '99 toggle [M]odel sonnet/opus',
    } ,
  },
  config = function()
    local _99 = require('99')

    _99.setup {
      -- NOTE: ClaudeCodeProvider shells out to `claude --dangerously-skip-permissions
      -- --model <model> --print <prompt>`. Print mode uses the same OAuth login as the
      -- interactive CLI, so no ANTHROPIC_API_KEY is needed. Careful: if ANTHROPIC_API_KEY
      -- is set in the environment the CLI prefers it over the subscription login.
      provider = _99.Providers.ClaudeCodeProvider,
      model = 'claude-sonnet-5', -- pinned; <leader>9m toggles to opus for the current session

      -- NOTE: no `type` field -> logs stay in memory only (no file spam), which is all
      -- <leader>9l needs. Level must be DEBUG or the cache stays empty.
      logger = {
        level = _99.DEBUG,
        print_on_error = true,
      },

      -- NOTE: prompt + response scratch files. Must live inside cwd or the CLI's own
      -- path rules can block the write. Add `tmp/` to your global gitignore.
      tmp_dir = './tmp',

      completion = {
        -- NOTE: native = plugin drives the popup itself in the prompt buffer (# rules,
        -- @ files, Tab/S-Tab to cycle). 'blink' would need saghen/blink.compat.
        source = 'native',
        custom_rules = {},
        files = {},
      },

      md_files = { 'AGENTS.md', 'CLAUDE.md' },
    }
  end,
}

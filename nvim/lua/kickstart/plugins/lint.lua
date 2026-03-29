return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      local eslint = { fix = 'source.fixAll.eslint', organize = 'source.organizeImports', name = 'ESLint' }
      local ruff = { fix = 'source.fixAll.ruff', organize = 'source.organizeImports.ruff', name = 'Ruff' }
      local default_linter = { fix = 'source.fixAll', organize = 'source.organizeImports', name = 'LSP' }

      local lsp_linters = {
        javascript = eslint,
        javascriptreact = eslint,
        typescript = eslint,
        typescriptreact = eslint,
        python = ruff,
        vue  = eslint,
        -- go = { fix = 'source.fixAll', organize = 'source.organizeImports', name = 'gopls' },
      }

      -----------------------------------------------------------
      -- nvim-lint configuration (for non-LSP linters)
      -----------------------------------------------------------
      lint.linters_by_ft = {
        -- markdown = { 'markdownlint' },
      }

      -- Autocommand for nvim-lint
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      local timer = nil
      -- NOTE: add 'BufEnter' when needed
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if timer then
            timer:stop()
          end
          timer = vim.defer_fn(function()
            if vim.bo.modifiable then
              lint.try_lint()
            end
          end, 100)
        end,
      })

      -----------------------------------------------------------
      -- Commands
      -----------------------------------------------------------
      local function get_linter_config()
        return lsp_linters[vim.bo.filetype] or default_linter
      end

      local function run_code_action(action_key, message)
        local config = get_linter_config()
        vim.lsp.buf.code_action {
          context = { only = { config[action_key] } },
          apply = true,
        }
        vim.notify(config.name .. ': ' .. message, vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command('FixLint', function()
        run_code_action('fix', 'Fixing all auto-fixable issues...')
      end, { desc = 'Fix auto-fixable lint issues' })

      vim.api.nvim_create_user_command('OrganizeImports', function()
        run_code_action('organize', 'Organizing imports...')
      end, { desc = 'Organize imports' })

      -----------------------------------------------------------
      -- Keymaps
      -----------------------------------------------------------
      vim.keymap.set('n', '<leader>lf', '<cmd>FixLint<CR>', { desc = '[L]int [F]ix all auto-fixable' })
      vim.keymap.set('n', '<leader>lo', '<cmd>OrganizeImports<CR>', { desc = '[L]int [O]rganize imports' })
    end,
  },
}

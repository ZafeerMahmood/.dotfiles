-- Python virtual environment selector
-- Auto-discovers and activates venvs, remembers per-project
-- See: https://github.com/linux-cultist/venv-selector.nvim

local is_win = vim.fn.has('win32') == 1
-- . instead of / in regex — fd --full-path uses OS-native separators on Windows
local python_pattern = is_win and 'Scripts.python\\.exe$' or 'bin.python$'

-- Pushes the venv python into pylsp's jedi.environment (which the default hook
-- doesn't touch — it only writes pyright-shape settings). Must return a number;
-- venv-selector does `count = count + hook(...)` and nil throws.
local function pylsp_jedi_hook(venv_python, _env_type, _bufnr)
  if type(venv_python) ~= 'string' or venv_python == '' then return 0 end
  for _, client in ipairs(vim.lsp.get_clients({ name = 'pylsp' })) do
    local new_settings = vim.tbl_deep_extend('force', client.settings or {}, {
      pylsp = { plugins = { jedi = { environment = venv_python } } },
    })
    client.settings = new_settings
    client.notify('workspace/didChangeConfiguration', { settings = new_settings })
  end
  return 1
end

return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  ft = 'python',
  cmd = { 'VenvSelect', 'VenvSelectCache' },
  keys = {
    { '<leader>vs', '<cmd>VenvSelect<cr>', desc = '[V]env [S]elect' },
  },
  opts = function()
    -- Both hooks are required: default handles ruff/pyright/cmd_env, ours adds pylsp.
    -- Setting `hooks` ourselves disables the default auto-add (config.lua:300).
    local default_hook = require('venv-selector.hooks').dynamic_python_lsp_hook
    return {
    hooks = { default_hook, pylsp_jedi_hook },
    options = {
      notify_user_on_venv_activation = true,
      -- Default searches use Unix-only patterns; disable on Windows
      enable_default_searches = not is_win,
      -- NOTE: do NOT add on_venv_activate_callback that stops + :LspStart.
      -- venv-selector's built-in dynamic_python_lsp_hook already restarts
      -- pylsp/ruff with cmd_env.VIRTUAL_ENV + python.pythonPath set.
      -- A manual :LspStart re-reads the original lspconfig spec and wipes those.
    },
    search = {
      -- LSP workspace root — finds venvs in the actual python subproject (monorepo support)
      -- Paths quoted with single quotes to handle spaces (e.g. "C:\Users\First Last\...")
      workspace_venvs = {
        command = "fd " .. python_pattern .. " '$WORKSPACE_PATH' --full-path -a -I --max-depth 4",
      },
      -- CWD with depth — finds venvs in subdirectories when opened from monorepo root
      cwd_venvs = {
        command = "fd " .. python_pattern .. " '$CWD' --full-path -a -I --max-depth 5",
      },
    },
    }
  end,
}

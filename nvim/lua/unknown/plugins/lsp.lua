-- Main LSP Configuration
-- Provides: Go to definition, references, completion, symbol search, and more
-- See: https://github.com/neovim/nvim-lspconfig

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by blink.cmp
    'saghen/blink.cmp',
  },
  config = function()
    -- Per-buffer LSP keymaps, set when a server attaches to a buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- Helper: define a buffer-local LSP mapping with a description.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- LSP hover
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- Convenience aliases (distro-style)
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

        -- Find references for the word under your cursor.
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = false,
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      -- C/C++ (clangd ships its own libclang via Mason; MinGW gcc headers picked up too).
      -- For project-wide indexing, drop a compile_commands.json or a .clangd at project root.
      clangd = {},

      -- C# / .NET (OmniSharp; needs system .NET SDK, present). Works on Neovim 0.11.
      -- Upgrade path: roslyn.nvim is faster but requires Neovim >= 0.12 (you're on 0.11).
      omnisharp = {},

      -- pyright = {},

      -- Go LSP
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      },
      -- rust_analyzer = {},
      -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`ts_ls`) will work just fine

      -- Frontend LSPs
      ts_ls = { -- TypeScript/JavaScript (js, ts, jsx, tsx)
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          completions = {
            completeFunctionCalls = true,
          },
        },
      },
      html = { filetypes = { 'html', 'templ' } },
      cssls = {},
      tailwindcss = {},
      -- emmet_ls = { -- Quick HTML/CSS snippets (disabled - saves one LSP process)
      --   filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact' },
      -- },

      -- Python LSP: pylsp + Jedi (Django/DRF completions). Install: pip install python-lsp-server pylsp-rope
      -- Linting/formatting handled by the standalone ruff LSP + conform, not pylsp.
      pylsp = {
        -- root_markers tiered: a Python marker must beat the monorepo's top-level .git
        -- (last resort), so editing backend/x.py roots pylsp at backend/ = scoped, faster.
        root_markers = {
          { 'manage.py', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' },
          '.git',
        },
        -- Inject the selected venv into jedi.environment on every (re)start so Jedi sees
        -- site-packages. vim.lsp.config skips lspconfig's on_new_config, hence before_init.
        before_init = function(_, config)
          local suffix = vim.fn.has('win32') == 1 and '\\Scripts\\python.exe' or '/bin/python'

          -- 3rd fallback: walk up from root for a venv dir (env/.venv/venv) so the repo root
          -- auto-resolves backend/env without :VenvSelect. Upward-only — relies on root_markers
          -- having scoped the root to backend/.
          local function find_venv_python(start_dir)
            if not start_dir or start_dir == '' then return nil end
            for _, name in ipairs({ 'env', '.venv', 'venv' }) do
              local hit = vim.fs.find(name, { path = start_dir, upward = true, type = 'directory' })[1]
              if hit then
                -- Normalize: vim.fs.find returns '/' paths on Windows but suffix is '\',
                -- so jedi never sees mixed separators (env/Scripts\python.exe).
                local py = vim.fs.normalize(hit .. suffix)
                if (vim.uv or vim.loop).fs_stat(py) then return py end
              end
            end
            return nil
          end

          -- Priority (first non-empty wins): explicit :VenvSelect > activated shell > discovered.
          local ok, vs = pcall(require, 'venv-selector')
          local venv_py = ok and vs.python and vs.python() or nil
          if (venv_py == nil or venv_py == '') and vim.env.VIRTUAL_ENV ~= nil then
            venv_py = vim.env.VIRTUAL_ENV .. suffix
          end
          if venv_py == nil or venv_py == '' then
            venv_py = find_venv_python(config.root_dir or vim.fn.getcwd())
          end

          if venv_py and venv_py ~= '' then
            -- Mutate in place: config.settings IS client.settings (the table pylsp pulls
            -- via workspace/configuration). Reassigning orphans it and drops the env.
            config.settings = config.settings or {}
            config.settings.pylsp = config.settings.pylsp or {}
            config.settings.pylsp.plugins = config.settings.pylsp.plugins or {}
            config.settings.pylsp.plugins.jedi = config.settings.pylsp.plugins.jedi or {}
            config.settings.pylsp.plugins.jedi.environment = venv_py
          end
        end,
        settings = {
          pylsp = {
            -- signature.formatter (top-level, NOT plugins.black) defaults to black, shelling a
            -- ~1s subprocess per signature on Windows -> hover/completion timeouts. '' disables it.
            signature = { formatter = '' },
            plugins = {
              -- Jedi: core completions. eager=false because eager=true resolves docs+signature
              -- for every candidate per keystroke (~15-18s); blink resolves lazily via resolve.
              jedi_completion = {
                enabled = true,
                include_params = true,
                include_class_objects = true,
                include_function_objects = true,
                fuzzy = true,
                eager = false,
              },
              jedi_hover = { enabled = true },
              jedi_references = { enabled = true },
              jedi_signature_help = { enabled = true },
              jedi_symbols = { enabled = true, all_scopes = true, include_import_symbols = true },
              jedi_definition = {
                enabled = true,
                follow_imports = true,
                follow_builtin_imports = true,
              },
              -- Rope off (pip install pylsp-rope): on this ~40k-module monorepo it builds a
              -- multi-GB sqlite index on the request path -> "database is locked"/timeouts;
              -- jedi covers completion. rope_completion is a redundant second source.
              -- TODO: evaluate basedpyright for fast auto-import-on-completion.
              rope_autoimport = { enabled = false },
              rope_completion = { enabled = false },
              -- All off: ruff LSP owns lint/code-actions, conform owns formatting. These are
              -- real default-on pylsp plugins, so they stay disabled to avoid double work.
              ruff = { enabled = false },
              pycodestyle = { enabled = false },
              pylint = { enabled = false },
              pyflakes = { enabled = false },
              mccabe = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
            },
          },
        },
      },

      -- Ruff LSP: fast Python lint + code actions. No lineLength override on purpose — it
      -- shadows the project's ruff.toml (88), desyncing in-editor E501 from CLI/conform/CI.
      ruff = {},

      -- Config files
      jsonls = {},  -- JSON (package.json, tsconfig, etc.)
      yamlls = {},  -- YAML
      taplo = {},   -- TOML (pyproject.toml, Cargo.toml, etc.)

      -- Markdown
      marksman = {},

      -- ESLint LSP - provides diagnostics AND code actions (like VSCode)
      -- Uses project's eslint.config.mjs or .eslintrc
      eslint = {
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        settings = {
          -- Use flat config (eslint.config.mjs)
          experimental = {
            useFlatConfig = true,
          },
          -- Working directory settings
          workingDirectories = { mode = 'auto' },
        },
      },

      lua_ls = {
        -- cmd = { ... },
        -- filetypes = { ... },
        -- capabilities = {},
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
    }

    -- Ensure the servers and tools above are installed
    --
    -- To check the current status of installed tools and/or manually install
    -- other tools, you can run
    --    :Mason
    --
    -- You can press `g?` for help in this menu.
    --
    -- `mason` had to be setup earlier: to configure its options see the
    -- `dependencies` table for `nvim-lspconfig` above.
    --
    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Lua formatter (used by conform)
      'gofumpt', -- Go formatter (used by conform)
      'goimports', -- Go imports formatter (used by conform)
      -- Uncomment formatters below if you want to use them instead of LSP:
      -- 'ruff', -- Python linter + formatter (fast)
      -- 'prettierd', -- Frontend formatter (faster than prettier)
      -- 'eslint_d', -- Fast ESLint daemon for JS/TS linting
    })
    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
      run_on_start = false,
    }

    -- mason-lspconfig v2 + Neovim 0.11 native LSP: register per-server config via
    -- vim.lsp.config, then let mason-lspconfig's automatic_enable run vim.lsp.enable
    -- for installed servers. (The old `handlers`/`automatic_installation` keys are a
    -- v1-only API and are silently ignored by v2.)
    vim.lsp.config('*', { capabilities = capabilities })
    for server_name, server in pairs(servers) do
      vim.lsp.config(server_name, server)
    end

    require('mason-lspconfig').setup {
      ensure_installed = {}, -- installs are driven by mason-tool-installer above
    }
  end,
}

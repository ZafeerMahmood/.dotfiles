# Neovim: Windows to macOS

## Canonical config

- Canonical: `C:\Users\Zafeer Mahmood\AppData\Local\nvim` (real dir, not a symlink). Remote `origin` = `pers:ZafeerMahmood/kickstart.nvim`.
- Working tree clean, but **2 commits unpushed** (`8af5384` 99 plugin, `1d1cd45` gitignore). Push from Windows first:
  `git -C "$env:LOCALAPPDATA\nvim" push origin master`
- `~/.dotfiles/nvim` is a **stale fork** (last commit 2026-03-30, plus uncommitted edits). It still has harpoon, diffview,
  precognition, indent_line, toggleterm removal etc. that the canonical repo dropped on purpose. Do not use it on Mac.
  Suggest deleting `.dotfiles/nvim` later or replacing with a submodule pointing at kickstart.nvim.
- Colorscheme repo `ZafeerMahmood/unknown-decay.nvim` is pulled by lazy.nvim from GitHub, nothing to copy.
  Local dev clone at `AppData\Local\unknown-decay.nvim` has detached HEAD + untracked `CLAUDE.md`, `todo.md`.

## Install

```bash
bash ~/.dotfiles/macos/nvim/install.sh
# with C# support (omnisharp):
INSTALL_DOTNET=1 bash ~/.dotfiles/macos/nvim/install.sh
```

Clones over https (ssh alias `pers:` only exists on Windows). After setting up a GitHub ssh key on Mac:
`git -C ~/.config/nvim remote set-url origin git@github.com:ZafeerMahmood/kickstart.nvim.git`

## Already portable (no change)

Config already guards Windows code with `has('win32')`. On macOS these fall through to the Unix path:

| File:line | Windows behavior | macOS behavior |
|---|---|---|
| `lua/unknown/core/options.lua:5-10` | `shell=pwsh -NoProfile` | `$SHELL` (zsh) |
| `lua/unknown/core/options.lua:33` | `clipboard=unnamedplus` | same, uses `pbcopy`/`pbpaste` natively |
| `lua/unknown/plugins/conform.lua:5-12` | direct `mason/packages/*.exe` paths | plain names from mason bin on PATH |
| `lua/unknown/plugins/lsp.lua:228` | venv `\Scripts\python.exe` | venv `/bin/python` |
| `lua/unknown/plugins/venv-selector.lua:5-7,43` | `Scripts.python.exe`, default searches off | `bin.python$`, default searches on |
| `lua/unknown/plugins/claudecode.lua:24` | `SHELL=cmd` | unset, Claude uses zsh |
| `lua/unknown/plugins/completion.lua:17` | LuaSnip jsregexp skipped | builds via `make` (Xcode CLT) |
| `lua/unknown/plugins/telescope.lua:14-20` | `make` from choco | `make` from Xcode CLT |
| `lua/unknown/plugins/telescope.lua:83-114` | git_status display fix for `C:/` paths | harmless no-op |

Ctrl+C / Ctrl+V / Ctrl+A / Ctrl+Z maps in `keymaps.lua:16-21,60` work the same in a Mac terminal.

**Not portable as-is:** window nav `<C-Left/Right/Up/Down>` (`keymaps.lua:63-66`). macOS binds Ctrl+Left/Right to
"Move a space" and Ctrl+Up/Down to Mission Control / App Expose, so nvim never sees them. Turn these off in
System Settings > Keyboard > Keyboard Shortcuts > Mission Control.

## Suggested patches (one config, both OSes)

### 1. Neovide Cmd key (`lua/unknown/core/options.lua:78`)

Without this, Cmd+C / Cmd+V do nothing in Neovide on Mac.

```lua
-  vim.g.neovide_input_use_logo = false
+  vim.g.neovide_input_use_logo = vim.fn.has('mac') == 1
```

Then in `lua/unknown/core/keymaps.lua` after line 21:

```lua
if vim.fn.has('mac') == 1 then
  map('v', '<D-c>', '"+y', { desc = 'Copy to clipboard' })
  map({ 'n', 'v' }, '<D-v>', '"+p', { desc = 'Paste from clipboard' })
  map({ 'i', 'c' }, '<D-v>', '<C-r>+', { desc = 'Paste from clipboard' })
  map('t', '<D-v>', '<C-\\><C-n>"+pi', { desc = 'Paste from clipboard (terminal)' })
end
```

### 2. Neovide font size (`lua/unknown/core/options.lua:69`)

macOS points render smaller than Windows at display scaling. Tune after first launch, eg:

```lua
-  vim.o.guifont = 'JetBrainsMonoNL Nerd Font Propo:h16:#e-subpixelantialias'
+  local font_size = vim.fn.has('mac') == 1 and 'h15' or 'h16'
+  vim.o.guifont = 'JetBrainsMonoNL Nerd Font Propo:' .. font_size .. ':#e-subpixelantialias'
```

`#e-subpixelantialias` is ignored on Retina, harmless.

### 3. omnisharp only when .NET exists (`lua/unknown/plugins/lsp.lua:162`)

Avoids a broken C# LSP if `dotnet-sdk` is not installed on Mac.

```lua
-      omnisharp = {},
+      omnisharp = vim.fn.executable('dotnet') == 1 and {} or nil,
```

### 4. Comment only (`lua/unknown/plugins/lsp.lua:156`)

Mentions MinGW headers. On Mac clangd uses Xcode CLT headers. Optional wording fix.

## LSPs and tools (via Mason)

`run_on_start = false` (`lsp.lua:379`) means nothing auto-installs on a fresh machine. `install.sh` runs
`:MasonToolsInstallSync` once. Installed on Windows: clangd, omnisharp, gopls, ts_ls, html, cssls, tailwindcss, pylsp, ruff,
jsonls, yamlls, taplo, marksman, eslint, lua_ls, stylua, gofumpt, goimports (+ emmet-ls, prettierd, eslint_d leftovers).

- gopls / gofumpt / goimports build with `go install`: needs `go` (in script).
- pylsp: Windows uses global `pip install python-lsp-server` (1.14.0). On Mac Mason installs it in its own venv. No pip needed.
- ts_ls / html / cssls / eslint / tailwind: need `node` (already on Mac).

## Treesitter

`nvim-treesitter` is on the `main` branch: parsers compile locally and need `tree-sitter` CLI (0.26.3 on Windows) + `cc`.
They install async on first launch. Run `:checkhealth nvim-treesitter` if highlighting is missing.

## Private files (gitignored, copy by export script)

| Windows path | Mac path |
|---|---|
| `AppData\Local\nvim\.claude\CLAUDE.md` | `~/.config/nvim/.claude/CLAUDE.md` |
| `AppData\Local\nvim\.claude\settings.local.json` | `~/.config/nvim/.claude/settings.local.json` |
| `AppData\Local\nvim\.docs\` | `~/.config/nvim/.docs/` |
| `AppData\Local\nvim\todo.md` | `~/.config/nvim/todo.md` |
| `AppData\Local\nvim\spell\en.utf-8.add` | `~/.config/nvim/spell/en.utf-8.add` (rebuild: `:mkspell! %`) |
| `AppData\Local\unknown-decay.nvim\CLAUDE.md`, `todo.md` | `~/code/unknown-decay.nvim/` (if you dev the theme) |

`nvim-data` (undo, shada, sessions, logs) is not worth moving: paths are Windows-specific. Saved colorscheme is
`catppuccin`, which is already the default.

## Gaps

- Neovide font size needs eyeballing on the Mac display.
- Neovide brew cask is `neovide-app` (not `neovide`).
- Ctrl+arrow window nav is eaten by Mission Control until those macOS shortcuts are disabled (see above).
- `99.lua:43` writes prompt files to `./tmp` in each project. Add `tmp/` to the Mac global gitignore
  (Windows has no `core.excludesfile` set, so this is not covered there either).
- omnisharp needs `INSTALL_DOTNET=1` (about 200MB). Skip if no C# work.
- Neovim on Windows is 0.11.4; brew installs latest. `lazy-lock.json` pins plugins, not Neovim itself.

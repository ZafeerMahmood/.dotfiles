# Terminal + Neovim Workflow Enhancement — Design Spec

**Date:** 2026-03-25
**Approach:** Hybrid (Neovim sessions + smarter shell)

## Problem

Daily full-stack development (TS/JS + Python/Go) across 2-3 related repos suffers from:
1. **Slow project switching** — zoxide helps navigate but no session restore, must reopen files manually
2. **Neovim↔terminal friction** — single floating terminal (`<C-\>`) insufficient for managing dev server + tests + general shell
3. **Repetitive commands** — manually typing dev server, test, build commands; navigating to same dirs; opening same files

## Design

### 1. Neovim: Session Management + Project Switcher

#### Auto-session plugin (`rmagatti/auto-session`)
- Automatically saves session (open buffers, cursor positions, folds) per project directory
- Restores session when opening `nvim` in a previously visited project directory
- Exclude special buffer types (neo-tree, terminal, lazygit, diffview) from session
- When no prior session exists (first visit), Neovim opens normally with no side effects
- Suppress snacks dashboard when a session is being restored; show dashboard only when no session exists

#### Project picker (Telescope + Zoxide)
- Keybind: `<leader>sp` — "Switch Project"
- Opens Telescope fuzzy list populated from zoxide history (frequent/recent dirs)
- On selection:
  1. Save current session
  2. Change Neovim working directory to selected project
  3. Restore that project's saved session
- Plugin: `jvgrootveld/telescope-zoxide` extension

#### Named terminal slots
Extend snacks.nvim terminal config with 3 persistent, named terminals using `Snacks.terminal.toggle("key")` with unique key per slot:
- `<leader>t1` — "dev" terminal (run dev server, stays alive)
- `<leader>t2` — "test" terminal
- `<leader>t3` — "general" terminal (git, misc commands)

Note: `<C-1>`/`<C-2>`/`<C-3>` are not deliverable by Windows Terminal to Neovim, so we use `<leader>t` prefix which fits the existing `[T]oggle` which-key group.

Each terminal:
- Persists across buffer switches (not killed on toggle)
- Has its own working directory
- Is a floating window (consistent with current snacks terminal style)
- `<C-\>` remains as a quick toggle for a throwaway terminal
- The existing terminal-mode `<C-\>` remap in keymaps.lua (exit terminal mode) may need adjustment to not conflict with snacks toggle-to-close behavior

### 2. Shell: `workon` function + Smart task commands

#### `workon` PowerShell function
```
workon frontend           # z frontend → nvim
workon frontend --serve   # z frontend → start dev server in bg → nvim
```

Implementation:
- Uses zoxide (`z`) to resolve project name to path
- Opens `nvim` in that directory
- `--serve` flag: starts `dev` function (see below) in a background job before opening nvim

#### Smart task commands (PowerShell functions)
Functions that walk up from current directory, detect project type by config file, and run the appropriate command:

| Command | package.json | go.mod | pyproject.toml |
|---------|-------------|--------|----------------|
| `dev`   | `npm run dev` | `go run .` | `python manage.py runserver` |
| `test`  | `npm test` | `go test ./...` | `pytest` |
| `build` | `npm run build` | `go build ./...` | `python -m build` |
| `lint`  | `npm run lint` | `golangci-lint run` | `ruff check .` |

Detection priority: walk up directories until a known config file is found. If multiple exist (e.g., monorepo), prefer the nearest one. If no config file is found, print an error: "No recognized project file found (package.json, go.mod, pyproject.toml)".

Error handling: `workon nonexistent-project` — if zoxide returns no match, print error and abort. Shell functions should fail fast with clear messages.

### 3. Windows Terminal: Optional startup optimization

- Profile PowerShell startup time
- If slow (>500ms), defer heavy module loads (Terminal-Icons, CompletionPredictor) to async background load after prompt renders
- No changes to pane layouts or profiles — `workon` + Neovim sessions handle orchestration

## Files Changed

### Neovim (new plugin files)
- `lua/unknown/plugins/auto-session.lua` — session management plugin spec
- `lua/unknown/plugins/telescope.lua` — add zoxide extension + `<leader>sp` keybind
- `lua/unknown/plugins/snacks.lua` — add named terminal slot keybinds

### PowerShell
- `Microsoft.PowerShell_profile.ps1` — add `workon`, `dev`, `test`, `build`, `lint` functions

### No changes to
- Windows Terminal settings.json (unless startup optimization needed)
- Git config (user relies on history/suggestions, not aliases)

## Out of scope
- REST client
- Custom snippets
- Markdown Previewer

# Claude Code on macOS

Moves Claude Code config, skills and project memories from the Windows PC to the Mac.

## What's on Windows

| Item | Where | Mac plan |
| --- | --- | --- |
| Global CLAUDE.md | `~/.claude/CLAUDE.md` | copy as-is |
| settings.json | `~/.claude/settings.json` | copy, Windows permission rules dropped, statusline -> bash |
| settings.local.json | `~/.claude/settings.local.json` | same fix (keeps `outputStyle: STE`) |
| keybindings.json | `~/.claude/keybindings.json` | copy (shift+enter newline) |
| Status line | `statusline.ps1` (active), old `statusline.sh` | `statusline.sh` here, port of the ps1 |
| Output styles | `~/.claude/output-styles/{eli5,ste}.md` | copy |
| Skills | `~/.claude/skills/*` (29 dirs) | copy, `synced/` and `.trash` skipped |
| skills CLI store | `~/.agents/skills`, `~/.agent/skills`, `~/skills-lock.json` | copy |
| Junction skills | `claude-memory-files`, `find-skills` -> `~/.agents/skills/*` | recreated as symlinks |
| Plugins | 10 enabled, 2 marketplaces | reinstall, see below |
| MCP servers | none user/project level, no `.mcp.json` in Work | come from plugins + claude.ai connectors |
| Agents, commands, hooks | none | nothing to do |
| Project memories | `~/.claude/projects/<encoded>/memory/` (~950 KB) | renamed to Mac encoding |
| Transcripts | `~/.claude/projects/*/*.jsonl` (~1.8 GB) | skipped, opt in with `INCLUDE_TRANSCRIPTS=1` |
| Repo `.claude` (untracked) | TaxGPT_App, TaxGPT_cowork, TaxGPT_ui_library, TaxGPT_ai_services | copied into cloned repos |

Untracked repo files: `.claude/CLAUDE.md` (App, cowork, ui_library), `TaxGPT_App/.claude/plans/`,
`TaxGPT_cowork/.claude/skills/handoff/`, every `.claude/settings.local.json`.
Tracked (come with `git clone`): `.claude/settings.json`, root `CLAUDE.md` / `AGENTS.md` in cowork and ui_library.

Not migrated: `.credentials.json`, `~/.claude/config.json` (holds an API key, never export it),
`~/.claude.json` (oauth, trust, caches), `history.jsonl`, `cache/`,
`file-history/`, `paste-cache/`, `shell-snapshots/`, `sessions/`, `plugins/cache`, `debug/`, `stats-cache.json`.

## Project dir encoding

Claude Code names `~/.claude/projects/<dir>` from the absolute project path with every
non-alphanumeric character replaced by `-`.

| Windows dir | Mac path | Mac dir |
| --- | --- | --- |
| `C--Users-Zafeer-Mahmood-Desktop-Work-TaxGPT-cowork` | `$HOME/Desktop/Work/TaxGPT_cowork` | `-Users-<name>-Desktop-Work-TaxGPT-cowork` |
| `C--Users-Zafeer-Mahmood--dotfiles` | `$HOME/.dotfiles` | `-Users-<name>--dotfiles` |
| `C--Users-Zafeer-Mahmood-AppData-Local-nvim` | `$HOME/.config/nvim` | `-Users-<name>--config-nvim` |

Windows sometimes writes a lowercase drive (`c--...TaxGPT-App`), the script handles both.
Projects outside `Desktop/Work` map under `$HOME` with the same relative path (e.g. `Desktop/TREE/...`).

## Steps

1. Install Claude Code (native installer) and log in:

   ```sh
   curl -fsSL https://claude.ai/install.sh | bash
   claude   # then /login
   ```

2. Install tools the config expects:

   ```sh
   brew install jq gopls lua-language-server pyright
   npm install -g typescript typescript-language-server
   ```

   Status line branch glyph needs a Nerd Font in the terminal (handled by the terminal/fonts area).

3. Clone the Work repos into `$HOME/Desktop/Work` first, so repo `.claude` files have somewhere to land.

4. Unpack the export bundle and run the import (bundle mirrors the Windows home dir):

   ```sh
   bash ~/.dotfiles/macos/claude/import-claude.sh ~/migration-bundle/home
   # other Work location:   MAC_WORK_DIR=$HOME/code bash ... 
   # keep old transcripts:  INCLUDE_TRANSCRIPTS=1 bash ...
   ```

   Re-runnable. Overwrites with the bundle copy, never deletes.

5. Plugins and marketplaces. `settings.json` already lists `enabledPlugins` and the ponytail marketplace,
   so Claude offers to install them on first start. Manual equivalent:

   ```sh
   claude plugin marketplace add anthropics/claude-plugins-official
   claude plugin marketplace add DietrichGebert/ponytail
   for plugin in frontend-design context7 typescript-lsp pyright-lsp lua-lsp code-simplifier \
       superpowers gopls-lsp atlassian; do
     claude plugin install "$plugin@claude-plugins-official"
   done
   claude plugin install ponytail@ponytail
   ```

6. MCP servers. Nothing to re-add by hand:
   - `context7` and `atlassian` come with their plugins (atlassian asks for OAuth on first use).
   - claude.ai connectors (Slack, Linear, Notion, Figma, TaxGPT dev/stage/prod, etc.) sync from the account after login.
   - If you add a local one later: `claude mcp add <name> -s user -- <command> <args>`.

7. Check: `claude` in a Work repo, then `/memory` (project memory shows), `/status`, `/plugin`, status line renders.

## Notes

- Windows-only permission rules (drive paths, backslashes, `powershell`, `Select-Object`, `winget`, `py manage.py`)
  are dropped. They get re-learned on the Mac as you approve commands.
- `settings.json` keeps `editorMode: vim`, `defaultMode: auto`, voice, effort and model settings unchanged.
- Some memory files mention Windows paths (e.g. nvim `telescope-windows-path-display.md`). Harmless, prune later.
- `skills/synced/` and `plugins/synced/` are claude.ai account sync, they repopulate on login.
- Global git ignore `~/.config/git/ignore` has `**/.claude/settings.local.json`; the git area ports it.
- Transcripts carry Windows `cwd`s, so `--resume` of old sessions may be odd. Mostly useful for search.

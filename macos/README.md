# Windows PC -> MacBook

Master to-do list. Go top to bottom, tick each box. Area details live in `macos/<area>/`.
Assumes Apple Silicon (`/opt/homebrew`), Homebrew, Node, Python, Git already on the Mac. No Docker anywhere.

Shortcut: after step 2.2, `bash ~/.dotfiles/macos/bootstrap.sh ~/Downloads/mac-export-*.zip` runs steps 1-5, services,
clone and import in order (safe to re-run). The list below is the same thing by hand plus the manual bits.

## 0. Prep on Windows

- [ ] 0.1 Push nvim config (2 unpushed commits): `git -C "$env:LOCALAPPDATA\nvim" push origin master`
- [ ] 0.2 Push or save repo work listed in `macos/projects/README.md` section 0. Key ones:
  - TaxGPT_App: commit/stash `frontend/lib/rollbar/RollbarClientProvider.tsx`; push 9 ahead branches, 32 local-only
  - TaxGPT_ai_services: dirty `loader_aa_review.py`, `loader_research.py`; push `data-agent-v2`
  - TaxGPT_cowork: push 4 ahead branches + 7 local-only (`git push -u origin <branch>`)
  - TaxGPT_cowork-formatting: `git push -u origin chore-prettier-setup`
  - chrome-extension: `git checkout package.json`; taxgpt_mobile: `git checkout android/` (Windows junk)
- [ ] 0.3 Confirm DB list (asks postgres password): `psql -U postgres -h localhost -l` and `psql -U postgres -h localhost -c "\du"`
- [ ] 0.4 Optional: re-copy editor settings if changed since export (commands in `macos/git-editors/README.md`)
- [ ] 0.5 Commit + push dotfiles: `git -C ~/.dotfiles add -A; git -C ~/.dotfiles commit -m "macos setup"; git -C ~/.dotfiles push`
- [ ] 0.6 Run export (stashes become patches, add `-IncludeTranscripts` for 1.8 GB of Claude sessions):
  `pwsh ~/.dotfiles/export-for-mac.ps1 -IncludePgDump`
- [ ] 0.7 Check warnings (MISSING/FAILED) and `manifest.txt` in the zip on the Desktop
- [ ] 0.8 Move `Desktop/mac-export-*.zip` to the Mac by AirDrop or USB (holds secrets, avoid shared cloud folders)

## 1. Base tools

- [ ] 1.1 `xcode-select --install`
- [ ] 1.2 Xcode app from App Store, then `sudo xcode-select -s /Applications/Xcode.app && xcodebuild -runFirstLaunch`
- [ ] 1.3 `brew install gh && gh auth login` (personal account, HTTPS)
- [ ] 1.4 `gh repo clone ZafeerMahmood/.dotfiles ~/.dotfiles`
- [ ] 1.5 `brew bundle --file=~/.dotfiles/macos/Brewfile`
- [ ] 1.6 `bash ~/.dotfiles/macos/tools/install-tools.sh` (PATH lines in `~/.zprofile`, uv tools, npm globals, go tools, claude)
- [ ] 1.7 `source ~/.zprofile && node -v` shows v24 (keg-only node@24 must come before the old Node)
- [ ] 1.8 Android Studio > SDK Manager: platforms 31/34/35, build-tools 34, 35.0.1, 36

## 2. Git / gh

- [ ] 2.1 `bash ~/.dotfiles/macos/git-editors/install.sh` (browser login per account; answer No to "Authenticate Git")
- [ ] 2.2 Optional SSH keys + `pers`/`work` aliases: `bash ~/.dotfiles/macos/git-editors/install.sh --ssh`
- [ ] 2.3 `gh auth status` lists ZafeerMahmood + ZafeerTaxGPT, work active
- [ ] 2.4 `git config --global alias.cmt commit` (replaces PSReadLine `git cmt` fix)

## 3. Shell + terminal

- [ ] 3.1 `bash ~/.dotfiles/macos/shell/install.sh`
- [ ] 3.2 Open WezTerm: pwsh, robbyrussell prompt, Catppuccin Mocha, JetBrainsMonoNL Propo semi-bold 16
- [ ] 3.3 Tune `font_size` (14-16) and `initial_cols/rows` in `~/.wezterm.lua` if 195x47 is too big
- [ ] 3.4 In Claude Code, Shift+Enter makes a newline; else run `/terminal-setup`

## 4. Window manager

- [ ] 4.1 `bash ~/.dotfiles/macos/windows/install.sh` (AeroSpace, SketchyBar, JankyBorders, defaults writes)
- [ ] 4.2 System Settings > Privacy & Security > Accessibility: allow AeroSpace
- [ ] 4.3 System Settings > Control Center > Automatically hide and show the menu bar: Always
- [ ] 4.4 Log out and back in (spans-displays)
- [ ] 4.5 Check keys against `macos/windows/KEYBINDINGS.md`

## 5. Neovim

- [ ] 5.1 `bash ~/.dotfiles/macos/nvim/install.sh` (add `INSTALL_DOTNET=1` for C#)
- [ ] 5.2 Open nvim, wait for treesitter, `:checkhealth`
- [ ] 5.3 System Settings > Keyboard > Shortcuts > Mission Control: turn off Ctrl+arrows (nvim window nav)
- [ ] 5.4 Optional: apply `macos/nvim/PORTING.md` edits (Neovide Cmd keys, font size h15, omnisharp guard)
- [ ] 5.5 After SSH keys: `git -C ~/.config/nvim remote set-url origin git@github.com:ZafeerMahmood/kickstart.nvim.git`
- [ ] 5.6 Add `tmp/` to `~/.dotfiles/git/ignore` (99 plugin writes `./tmp` in every project)

## 6. Databases

- [ ] 6.1 `brew services start postgresql@16 && brew services start redis && redis-cli ping`
- [ ] 6.2 Restore dumps: `macos/tools/databases.md` section 3 (from `~/mac-export/pg`), or
- [ ] 6.3 Fresh: create roles `zafeer`, `test`, `postgres` and DBs `taxgpt`, `djangoTest`, `ai` (section 2, passwords from `.env`)

## 7. Projects

- [ ] 7.1 `bash ~/.dotfiles/macos/projects/clone.sh`
- [ ] 7.2 `bash ~/.dotfiles/macos/import-from-windows.sh ~/Downloads/mac-export-*.zip` (envs, notes, Claude, codex, nvim extras)
- [ ] 7.3 Apply stash patches if wanted: `git -C ~/Desktop/Work/<repo> apply ~/mac-export/stashes/<repo>-stash-N.patch`
- [ ] 7.4 TaxGPT_App backend:
  `cd ~/Desktop/Work/TaxGPT_App/backend && python3.11 -m venv env && source env/bin/activate`
  `python scripts/install.py && python scripts/install.py -r requirements.dev.txt && python manage.py migrate`
  Run: `python manage.py runserver` + `celery -A taxGPTbackend worker -l info --pool threads`
- [ ] 7.5 TaxGPT_App frontend: `cd ~/Desktop/Work/TaxGPT_App/frontend && npm run install:env && npm run dev`
- [ ] 7.6 TaxGPT_App pre-commit: `cd ~/Desktop/Work/TaxGPT_App && bash scripts/setup-precommit.sh`
- [ ] 7.7 TaxGPT_App microservices: `document_upload` `go run main.go`, `tax_engine` `go run ./cmd/server`,
  `anthropic_proxy` `npm install && npm run dev` (see projects README section 3)
- [ ] 7.8 TaxGPT_ai_services: `cd ~/Desktop/Work/TaxGPT_ai_services && uv sync && uv run pre-commit install`
  Run: `uv run uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload`
- [ ] 7.9 TaxGPT_cowork: `cd ~/Desktop/Work/TaxGPT_cowork && npm run install:env && npm run dev`
- [ ] 7.10 TaxGPT_ui_library: `cd ~/Desktop/Work/TaxGPT_ui_library && set -a && source .env && set +a && npm install`
  Then `npm run build && npm run storybook`
- [ ] 7.11 chrome-extension: `cd ~/Desktop/Work/chrome-extension && npm install && npm start`
- [ ] 7.12 taxgpt_mobile: `cd ~/Desktop/Work/taxgpt_mobile && corepack enable && yarn install`
  `bundle install && (cd ios && bundle exec pod install) && yarn ios` (and `yarn android`)
- [ ] 7.14 `stripe login`, `vercel login`

## 8. Claude Code

- [ ] 8.1 `claude` then `/login` (import in 7.2 already copied config, skills, memories, statusline)
- [ ] 8.2 Plugins: accept install prompts, or run the commands in `macos/claude/README.md` step 5
- [ ] 8.3 Authenticate atlassian MCP and claude.ai connectors on first use
- [ ] 8.4 Re-accept folder trust per repo (`~/.claude.json` is not migrated)
- [ ] 8.5 Fix Windows paths in `~/.codex/config.toml` (drop `[windows]`, notify exe, project paths)
  and `~/.gemini/extensions/extension-enablement.json` (`/C:/Users/...`)

## 9. macOS system settings

- [ ] 9.1 Check what `windows/install.sh` wrote: menu bar hidden, Dock autohide, Stage Manager + edge tiling off
- [ ] 9.2 Keyboard > Key repeat fast, delay short (match Windows feel)
- [ ] 9.3 Location Services for SketchyBar/Terminal if the wifi SSID shows blank (macOS 15+)
- [ ] 9.4 Optional: Raycast in place of PowerToys Run (`brew install --cask raycast`)
- [ ] 9.4b Raycast hotkey: PowerToys Run was Win+S here; Cmd+Space in Raycast (turn off Spotlight's first).
  Raycast Window Management/Clipboard cover PowerToys FancyZones/AdvancedPaste; AeroSpace already tiles
- [ ] 9.4c Login items (autostart on PC): Slack, Discord, Spotify (minimized), Grammarly. System Settings > General > Login Items
- [ ] 9.5 Cloudflare WARP + Vanta: enroll through work (company managed)

## 10. Verification

- [ ] 10.1 `cd ~/Desktop/Work/TaxGPT_App && git config user.email` shows `zafeer@taxgpt.com`
- [ ] 10.2 `git log` shows delta side-by-side; `ssh -T git@github.com` if using SSH
- [ ] 10.3 `node -v` 24, `python3.11 -V`, `uv -V`, `go version` 1.25, `java -version` 17
- [ ] 10.4 `psql -U zafeer taxgpt -c 'select 1'`, `redis-cli ping`
- [ ] 10.5 Backend `runserver` on :8000, frontend on :3000, ai_services on :8001
- [ ] 10.6 In a Work repo: `claude`, then `/memory` shows project memory, `/plugin` lists 10, status line renders
- [ ] 10.7 alt+1..9 switches AeroSpace workspaces, SketchyBar shows workspaces + clock
- [ ] 10.8 VS Code + Cursor: Catppuccin Mocha, JetBrainsMonoNL Nerd Font Propo 15
- [ ] 10.9 Delete `~/mac-import`, the zip, and `~/mac-export/pg` once all works

## Gaps / decisions

Tools + DB
- Postgres DB/role list inferred from `.env` files only (no password here). Confirm with 0.3.
- Move DB data (pg_dump) or fresh migrate? Undecided.
- `pgaudit` not in brew postgresql@16; only matters for `enable_pgaudit` command.
- `gobang` not in brew; use `pgcli` or `dbeaver-community`.
- `/opt/homebrew` hardcoded in several scripts and `.gitconfig` gh path (Intel Mac needs `/usr/local`).
- luarocks uses lua 5.4 (PC had 5.1). Only matters for 5.1-only rocks.
- .NET SDK and Docker Desktop skipped (unused). Vanta, WARP org enrollment, TaxGPT desktop builds: get from work.

Projects
- Many unpushed/local-only branches and stashes (0.2). Stashes travel as patches only.
- `test-worktree` (broken worktree) and Cursor/Temp worktrees not recreated.
- litellm proxy is Docker-only; only its tests run on Mac.
- tax_engine / document_upload AWS/S3 env settings not checked.
- `clone.sh` runs `gh auth setup-git` when `~/.ssh/work` is missing; may rewrite the symlinked `~/.gitconfig`. Check `git diff` in dotfiles after.

Shell + terminal
- Ctrl+C copy is Cmd+C now; Ctrl+C interrupts.
- Ctrl+Shift+V paste-as-here-string and Ctrl+Shift+J marks don't fire on Mac (same bytes as Ctrl+V/J). Rebind to Alt if wanted.
- zsh has no auto-closing brackets, Ctrl+J marks, or `git cmt` fix (alias in 2.4).
- Padding 10 from Windows Terminal kept (old wezterm used 25/20/25/5). Font size may look bigger on Mac.
- `.gitattributes` forces CRLF on `*.ps1`; pwsh on Mac copes. Could add `.zshrc text eol=lf`.
- Ottosson scheme, WSL/cmd/VS profiles not ported.

Window manager
- No unfocused 90% transparency (needs SIP off).
- alt+space cycle and alt+shift+w redraw have no exact AeroSpace match; floating windows not auto-centered.
- Resize steps 30px not 2%. Tiling-direction icon static. Wifi strength icon always full.
- Weather via wttr.in. Workspace buttons on every monitor. YASB look not ported (broken on PC).
- Battery shows plug icon whenever on AC.

Neovim
- `.dotfiles/nvim` is a stale copy (has removed plugins). Delete it or make it a submodule? Undecided.
- Neovide Cmd keys need PORTING.md patch; font size check by eye.
- Neovim version: brew latest vs 0.11.4 on PC; plugins pinned by lazy-lock.
- unknown-decay.nvim dev clone is detached HEAD; clone fresh if still working on it.

Git + editors
- Not verified that gh picks the right account from `credential.https://github.com.username`. Fallback: `--ssh` or `gh auth switch`.
- Editor keybindings still use ctrl/shift+alt; consider cmd. Windows-only keys left in settings (harmless).
- Shift+Enter sends `\\\r\n` in editor terminals; unverified on Mac.
- Codex, Gemini, Copilot CLIs: configs carry Windows paths (8.5). gh logins redone on Mac.

Claude
- Project dir encoding (non-alphanumeric -> `-`) not checked on a real Mac.
- Projects outside Desktop/Work assumed at the same path under `$HOME`.
- Transcripts skipped by default; old sessions have Windows cwds, `--resume` unreliable.
- `~/.claude.json` and `~/.claude/config.json` (API key) never exported.
- Some memories and repo CLAUDE.md files mention Windows paths/pwsh; not rewritten.

Completeness pass (things found on the PC, not migrated on purpose)
- Secret paths never in git or the zip; redo on Mac: `~/.ssh/{personal,work}` (or `--ssh`), `~/.config/stripe/config.toml`
  (`stripe login`), `~/.codex/auth.json`, `~/.gemini/google_accounts.json` (re-login), `Desktop/TREE/developer_key` (copy by hand if needed).
- `Desktop/TREE/ngrok.exe` was used: `brew install ngrok` + `ngrok config add-authtoken` if still needed.
- `taxgpt_mobile/android/local.properties` (Windows SDK path) not exported; Android Studio writes it on first sync.
- Release signing passwords live in tracked `android/gradle.properties`; nothing extra to move.
- Skipped Windows-only: PowerToys, Rainmeter, AMD/ASUS tasks, `~/.minttyrc`, `.git-*.bash`, `~/.local/bin/lvim.ps1`, gobang config.
- Desktop scratch folders `TMP`, `image-type-test`, `skills-v2-test` not exported (test files).
- `~/.gk`, `~/.codemod`, `~/.expo`, `~/.copilot` caches not moved; regenerate on use.

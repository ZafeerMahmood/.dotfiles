# git-editors (macOS)

Git, gh, SSH, VS Code, Cursor. Run after cloning dotfiles to `~/.dotfiles`.

## Order

1. `brew install gh && gh auth login` (personal account), then `gh repo clone ZafeerMahmood/.dotfiles ~/.dotfiles`
   - Repo origin on Windows is `pers:ZafeerMahmood/.dotfiles.git` (SSH alias), so clone over HTTPS first.
2. `bash ~/.dotfiles/macos/git-editors/install.sh` (HTTPS only, uses gh tokens in keychain)
   - Each gh login opens the browser: sign in there as that account. Answer No to "Authenticate Git".
3. Optional: `bash ~/.dotfiles/macos/git-editors/install.sh --ssh` creates `~/.ssh/personal` + `~/.ssh/work`,
   uploads each to its GitHub account, appends `pers` / `work` host aliases to `~/.ssh/config`.

## Editor settings

Live VS Code / Cursor settings and keybindings (Windows `%APPDATA%/{Code,Cursor}/User/`) are copied into
`vscode/` and `cursor/` here. The older `~/.dotfiles/{vscode,cursor}` copies are not used on Mac.
Re-copy before leaving Windows if you change settings again:

```powershell
cp $env:APPDATA\Code\User\settings.json,$env:APPDATA\Code\User\keybindings.json ~\.dotfiles\macos\git-editors\vscode\
cp $env:APPDATA\Cursor\User\settings.json,$env:APPDATA\Cursor\User\keybindings.json ~\.dotfiles\macos\git-editors\cursor\
```

## Identity switching

| Windows | Mac |
| --- | --- |
| `gitdir:C:/Users/Zafeer Mahmood/Desktop/TREE/` -> personal | `gitdir:~/Desktop/TREE/` |
| `gitdir:C:/Users/Zafeer Mahmood/Desktop/Work/` -> work | `gitdir:~/Desktop/Work/` |
| `credential.helper=manager` (GCM) | `osxkeychain`, github.com via `gh auth git-credential` |
| `sshCommand ssh -i ~/.ssh/work` | same plus `-o IdentitiesOnly=yes` |

- Keep projects at `~/Desktop/Work` and `~/Desktop/TREE` or edit the two `includeIf` lines.
- Work repos use `git@github.com:TaxGPT/...` remotes. They pick the key via `core.sshCommand` from the include.
- Some personal repos use `pers:ZafeerMahmood/...` remotes, which need the SSH alias (`--ssh`).
- HTTPS: include files set `credential.https://github.com.username`, so gh returns that account's token.
- gh active account defaults to work. `gh auth switch` to flip for `gh pr` etc in personal repos.

## Editors

- `~/Library/Application Support/{Code,Cursor}/User/{settings,keybindings}.json` symlink to `vscode/` and `cursor/` in this folder.
- Extension lists: `vscode-extensions.txt`, `cursor-extensions.txt`.
  Dropped: remote-wsl (both), glassit and vscode-docker (Cursor). Vibrancy works on Mac.
- Font `JetBrainsMonoNL Nerd Font Propo` comes from `font-jetbrains-mono-nerd-font` cask.
- Keybindings use `ctrl` / `shift+alt`. They still fire on Mac as ctrl/option. Change to `cmd` if wanted.
- Settings keep `terminal.integrated.defaultProfile.windows`. Harmless on Mac, default shell is used.
- Cursor MCP (`~/.cursor/mcp.json`): only Playwright via npx.

## Not migrated here (paths only, handled by export script)

- `~/.codex/` (auth.json, config.toml, AGENTS.md, memories/, rules/, skills/): Codex CLI. config.toml has Windows paths.
- `~/.gemini/` (commands/simplify.toml, extensions/gemini-cli-prompt-library, google_accounts.json): Gemini CLI.
- `~/.copilot/config.json`: only a timestamp, nothing to move.
- `~/.aws`, `~/.azure`: empty. No `~/.npmrc`. `~/.yarnrc` only has update timestamp.
- gh tokens live in the Windows keyring. Do not move, re-login on Mac.

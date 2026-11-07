# Windows PC tool inventory -> Mac equivalents

Collected 2026-11-08 from `winget list`, `choco list`, `npm -g ls`, PATH, `~/go/bin`, Python Scripts, WSL.
Install everything with `bash ~/.dotfiles/macos/tools/install-tools.sh` (runs `brew bundle` on `Brewfile`).
No scoop, no cargo bins, no pipx on the PC.

## Runtimes

| Tool | Windows version / source | Mac install | Notes |
|---|---|---|---|
| Node | 24.12.0 (winget) | `brew node@24` | Keg-only, PATH line added. Mac Node already present, check `node -v` |
| npm / yarn | npm 10.8.2, yarn 1.22.22 | bundled / `npm i -g yarn` | taxgpt_mobile uses yarn.lock, rest npm |
| Python | 3.11.6 (python.org) | `uv python install 3.11` | All projects pin 3.11 (`.python-version`) |
| uv | 0.9.15 | `brew uv` | TaxGPT_ai_services, litellm use uv.lock |
| Go | 1.25.6 (choco) | `brew go` | document_upload, tax_engine need go 1.25 |
| Java | OpenJDK 17.0.15 (Microsoft) | `cask zulu@17` | Android builds. JAVA_HOME set in .zprofile |
| Ruby | none on PC | `brew ruby` | Needed on Mac for iOS: taxgpt_mobile Gemfile (cocoapods) |
| .NET SDK | 10.0.102 (choco) | skipped | No project uses it. Add `cask dotnet-sdk` if needed |
| Lua | 5.1.5 (choco) | `brew luarocks` (pulls lua) | Neovim plugin builds |
| C toolchain | mingw gcc 13, LLVM 18, VS Build Tools, make 4.4 | `xcode-select --install` | clang + make ship with Xcode CLT |
| zig | 0.15.2 | `brew zig` | Treesitter parser compiler fallback |
| cmake | 4.3.4 | `brew cmake` | |

## Databases

| Tool | Windows | Mac | Notes |
|---|---|---|---|
| PostgreSQL | 16.3, Windows service `postgresql-x64-16`, auto-start | `brew postgresql@16` + `brew services` | See databases.md |
| Redis | 7.0.15 inside WSL Debian (systemd enabled) | `brew redis` + `brew services` | Celery broker `redis://localhost:6379/0` |
| gobang | TUI DB client (winget) | none in brew | Use `brew install pgcli` or `cask dbeaver-community` if wanted |

## CLI tools

| Tool | Windows version / source | Mac install |
|---|---|---|
| git | 2.44 | `brew git` |
| gh | 2.76.1 | `brew gh` (then `gh auth login`) |
| delta | 0.18.0 choco | `brew git-delta` |
| lazygit | 0.41.0 choco | `brew lazygit` |
| zoxide | 0.9.2 choco | `brew zoxide` |
| fzf | 0.50.0 choco | `brew fzf` |
| ripgrep | 14.1.0 choco | `brew ripgrep` |
| fd | 9.0.0 choco | `brew fd` |
| bat | 0.25.0 choco | `brew bat` |
| eza | not on PC | `brew eza` (optional, requested) |
| jq | 1.8.1 choco | `brew jq` |
| oh-my-posh | 29.9.0 winget | `brew jandedobbeleer/oh-my-posh/oh-my-posh` |
| neovim | 0.11.4 choco | `brew neovim` |
| tree-sitter | 0.26.3 npm | `npm i -g tree-sitter-cli` |
| tldr | choco tldr | `brew tlrc` |
| wget | 1.21.4 | `brew wget` |
| sed (GnuWin32) | 4.2.1 | `brew gnu-sed` (as `gsed`) |
| less, gzip, unzip, curl | choco / system | built into macOS |
| cloc | npm 2.6.0 | `brew cloc` |
| poppler | 24.07 (PATH) | `brew poppler` (pdf2image / pdftotext) |
| mupdf | 1.27.0 choco | `brew mupdf-tools` |
| stripe | stripe.exe in ~/Stripe | `brew stripe/stripe-cli/stripe` (then `stripe login`) |
| claude | Claude Code 2.1.319 | `curl -fsSL https://claude.ai/install.sh \| bash` |
| codex | OpenAI Codex app (not npm) | `npm i -g @openai/codex` (CLI) |
| adb | Android SDK platform-tools | via Android Studio SDK Manager |
| watchman | not on PC | `brew watchman` (React Native on Mac) |
| cocoapods | not on PC | `brew cocoapods` or `bundle install` in taxgpt_mobile |

## npm globals

`npm i -g` list: `yarn prettier eslint_d neovim tree-sitter-cli vercel @vscode/vsce @google/gemini-cli @openai/codex ui-ux-pro-max-cli`.
Skipped: `windows-build-tools` (Windows only), `vsce` renamed to `@vscode/vsce`,
`cli-vault` (local `npm link` of `~/Desktop/TREE/Personal_Projects/cli-vault`, re-link after copying that repo).

## Python CLIs (global pip on PC)

Install as uv tools: `poetry ruff pre-commit black`. Projects own the rest (pytest, alembic, uvicorn, gunicorn, faker)
through their own venvs. `pylsp`, `nodeenv`, `pyinstaller`, `vulture` were global on PC, add with `uv tool install` if missed.

## Go bins (~/go/bin)

`gopls gofumpt goimports` via `go install` (in install-tools.sh). Mason in Neovim may also manage these.

## GUI dev apps

| Windows app | Mac cask | Notes |
|---|---|---|
| VS Code | `visual-studio-code` | Settings in `.dotfiles/vscode` |
| Cursor | `cursor` | Settings in `.dotfiles/cursor` |
| Neovide | `neovide` | |
| Postman | `postman` | |
| Android Studio | `android-studio` | SDKs on PC: platforms 31/34/35, build-tools 34/35.0.1/36 |
| GitHub Desktop | `github` | |
| Xcode | App Store | Needed for taxgpt_mobile iOS |
| Windows Terminal + pwsh | other area (terminal) | |
| GlazeWM 3.9.1 + Zebar 1.1 | other area (window manager) | |
| PowerToys | `raycast` (optional) | Launcher / run menu equivalent |
| Docker Desktop (choco) | skipped | Not used |
| WSL Debian | skipped | Only hosted Redis, brew redis replaces it |

## Everyday apps (casks)

claude, chatgpt, obsidian, notion, slack, discord, spotify, google-chrome, firefox, whatsapp, cloudflare-warp,
libreoffice, grammarly-desktop, the-unarchiver (replaces WinRAR). Optional: `opera`, `microsoft-teams`, `qbittorrent`.

## Skipped (Windows only)

AMD/ASUS/Armoury Crate/Corsair/SteelSeries/MSI Afterburner, CPU-Z, HWMonitor, FurMark, Rainmeter, Cheat Engine,
DroidCam, games, Windows runtimes and codecs, VC++ redists, Phone Link, Game Bar.
Vanta Device Monitor and TaxGPT desktop builds: get from work (company-managed installers).

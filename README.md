# Dotfiles

Personal dotfiles for Windows 11 and Linux Mint. Managed with git + symlinks.

## What's included

| Folder | Config for | Platform |
|---|---|---|
| `git/` | Git (conditional work/personal profiles, delta pager) | Both |
| `bash/` | Bash profile (oh-my-posh, zoxide, fzf, aliases) | Both |
| `nvim/` | Neovim (kickstart-based, 27+ plugins) | Both |
| `wezterm/` | WezTerm terminal (rose-pine, Mica, JetBrains Mono) | Both |
| `ssh/` | SSH config (no keys) | Both |
| `github-cli/` | GitHub CLI config (no auth tokens) | Both |
| `oh-my-posh/` | oh-my-posh theme (robbyrussell) | Both |
| `vscode/` | VS Code settings + keybindings | Both |
| `cursor/` | Cursor IDE settings + keybindings | Both |
| `powershell/` | PowerShell 7 profile (PSReadLine, oh-my-posh) | Windows |
| `windows-terminal/` | Windows Terminal settings | Windows |
| `glazewm/` | GlazeWM tiling window manager | Windows |
| `yasb/` | YASB status bar (config + styles) | Windows |
| `mintty/` | Git Bash / Mintty terminal | Windows |
| `fonts/` | JetBrains Mono Nerd Font (6 variants) | Both |

## Quick start

### Windows

Requires **admin PowerShell** (symlinks need elevation or Developer Mode enabled).

```powershell
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
pwsh -ExecutionPolicy Bypass -File install-windows.ps1

# Preview first without making changes:
pwsh -ExecutionPolicy Bypass -File install-windows.ps1 -DryRun
```

### Linux (Mint / Ubuntu / Debian)

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
chmod +x install-linux.sh
./install-linux.sh

# Preview first:
./install-linux.sh --dry-run
```

## Tool dependencies

These are the CLI tools that the configs depend on. Install them **before** running the install script.

### Core tools (both platforms)

These tools are required for the configs to work properly.

| Tool | What needs it | Windows install | Linux install |
|---|---|---|---|
| **git** | Everything | `winget install Git.Git` | `sudo apt install git` |
| **Neovim** (0.11+) | `nvim/` | `choco install neovim` | [Build from source](https://github.com/neovim/neovim/wiki/Building-Neovim) or `snap install nvim --classic` |
| **ripgrep** | Neovim (telescope, grep) | `choco install ripgrep` | `sudo apt install ripgrep` |
| **fd** | Neovim (telescope file finder) | `choco install fd` | `sudo apt install fd-find` (binary is `fdfind`, alias to `fd`) |
| **fzf** | bash profile, Neovim | `choco install fzf` | `sudo apt install fzf` |
| **delta** | git (diff pager) | `choco install delta` | [GitHub releases](https://github.com/dandavison/delta/releases) or `cargo install git-delta` |
| **zoxide** | bash profile, pwsh profile | `choco install zoxide` | `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \| sh` |
| **oh-my-posh** | bash profile, pwsh profile (robbyrussell theme) | `winget install JanDeDobbeleer.OhMyPosh` | `curl -s https://ohmyposh.dev/install.sh \| bash -s` |
| **lazygit** | Neovim (lazygit.nvim plugin) | `choco install lazygit` | [GitHub releases](https://github.com/jesseduffield/lazygit/releases) |
| **bat** | General use | `choco install bat` | `sudo apt install bat` (binary is `batcat`, alias to `bat`) |
| **tree-sitter CLI** | Neovim (treesitter parsers) | `npm install -g tree-sitter-cli` | `npm install -g tree-sitter-cli` |
| **Node.js** (v18+) | Neovim LSPs, npm, tree-sitter-cli | `winget install OpenJS.NodeJS.LTS` | `curl -fsSL https://deb.nodesource.com/setup_lts.x \| sudo -E bash - && sudo apt install nodejs` |
| **Python** (3.11+) | Bash aliases (Django), pip | `winget install Python.Python.3.11` | `sudo apt install python3 python3-pip` |
| **Go** (1.21+) | Neovim LSP (gopls) | `choco install golang` | `sudo snap install go --classic` |
| **GitHub CLI** | `github-cli/` | `winget install GitHub.cli` | `sudo apt install gh` |

### Neovim build tools

These are needed for treesitter parsers to compile and for some LSP servers.

| Tool | Purpose | Windows install | Linux install |
|---|---|---|---|
| **zig** | Treesitter parser compilation | `choco install zig` | [ziglang.org/download](https://ziglang.org/download/) |
| **gcc** | Fallback C compiler for parsers | `choco install mingw` (includes gcc) | `sudo apt install build-essential` |
| **make** | Build tool for some plugins | `choco install make` | `sudo apt install build-essential` |

### Windows-only tools

| Tool | What needs it | Install |
|---|---|---|
| **PowerShell 7** | `powershell/` profile | `winget install Microsoft.PowerShell` |
| **PSReadLine** | pwsh profile (ships with PS7) | Built-in with PowerShell 7 |
| **Terminal-Icons** | pwsh `Enable-Icons` function | `Install-Module -Name Terminal-Icons -Scope CurrentUser` |
| **CompletionPredictor** | pwsh inline predictions | `Install-Module -Name CompletionPredictor -Scope CurrentUser` |
| **WezTerm** | `wezterm/` | `winget install wez.wezterm` |
| **Windows Terminal** | `windows-terminal/` | Microsoft Store or `winget install Microsoft.WindowsTerminal` |
| **GlazeWM** | `glazewm/` | `winget install glzr-io.glazewm` |
| **YASB** | `yasb/` | [github.com/da-rth/yasb](https://github.com/da-rth/yasb) |
| **Rainmeter** | Desktop widgets (not in this repo) | `winget install Rainmeter.Rainmeter` |

### Linux-only notes

| Tool | Notes |
|---|---|
| **fd-find** | On Debian/Ubuntu, the binary is `fdfind`. Create an alias: `ln -s $(which fdfind) ~/.local/bin/fd` |
| **bat** | On Debian/Ubuntu, the binary is `batcat`. Create an alias: `ln -s $(which batcat) ~/.local/bin/bat` |
| **WezTerm** | [wezfurlong.org/wezterm/install/linux](https://wezfurlong.org/wezterm/install/linux.html) |
| **oh-my-posh** | Theme is bundled in this repo (`oh-my-posh/`). No system theme path needed. |
| **Fonts** | The install script copies fonts to `~/.local/share/fonts/` and runs `fc-cache`. |

## One-liner installs

### Windows (Chocolatey)

```powershell
choco install neovim ripgrep fd fzf delta lazygit bat zoxide zig mingw make lua jq -y
```

### Windows (winget)

```powershell
winget install Git.Git OpenJS.NodeJS.LTS Python.Python.3.11 GoLang.Go GitHub.cli JanDeDobbeleer.OhMyPosh Microsoft.PowerShell wez.wezterm Microsoft.WindowsTerminal glzr-io.glazewm Neovide.Neovide
```

### Linux Mint / Ubuntu

```bash
# Core packages
sudo apt update && sudo apt install -y git neovim ripgrep fd-find fzf bat build-essential python3 python3-pip jq curl wget unzip

# Node.js (LTS via nodesource)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Go
sudo snap install go --classic

# Tools installed via other methods
npm install -g tree-sitter-cli

# oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# delta (download .deb from GitHub releases)
# https://github.com/dandavison/delta/releases

# lazygit (download binary from GitHub releases)
# https://github.com/jesseduffield/lazygit/releases

# zig (download from ziglang.org)
# https://ziglang.org/download/

# GitHub CLI
sudo apt install gh

# fd alias (Debian/Ubuntu names it fdfind)
mkdir -p ~/.local/bin
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat
```

## Post-install

### Neovim

On first launch after linking, Neovim (via lazy.nvim) will automatically:
1. Install all plugins
2. Download treesitter parsers (needs `zig` or `gcc`)
3. Install LSP servers via Mason

Just open `nvim` and wait for it to finish. Run `:checkhealth` to verify everything is working.

### Git config

The `.gitconfig` uses conditional includes based on directory:
- Repos under `~/Desktop/TREE/` use `.gitconfig-personal`
- Repos under `~/Desktop/Work/` use `.gitconfig-work`

On Linux, update these paths in `.gitconfig` to match your directory structure.

### oh-my-posh theme

The theme file (`robbyrussell.omp.json`) is stored in `oh-my-posh/` and referenced via `~/.dotfiles/oh-my-posh/`. This works on both Windows and Linux with no path changes needed.

### SSH

The install script links `ssh/config` only. **Keys are never stored in this repo.** Copy your SSH keys manually:
```bash
# On the new machine, copy keys from a secure source
cp /path/to/keys ~/.ssh/
chmod 600 ~/.ssh/personal ~/.ssh/work
chmod 644 ~/.ssh/*.pub
```

## What's NOT in this repo

- SSH private keys
- GitHub CLI auth tokens (`hosts.yml`)
- `.bash_history`
- Neovim plugin cache / compiled parsers (auto-generated on first run)
- Docker credentials
- Cloud credentials (AWS, Azure)
- Any `.env` files or secrets

## Repo structure

```
~/.dotfiles/
├── git/                     # Git configs
├── bash/                    # Bash profile
├── nvim/                    # Neovim (full config)
│   ├── init.lua
│   ├── lua/unknown/core/    # Core settings (options, keymaps, autocmds)
│   └── lua/unknown/plugins/ # Plugin configs (27 files)
├── wezterm/                 # WezTerm terminal
├── ssh/                     # SSH config (no keys!)
├── powershell/              # PowerShell 7 profile [Windows]
├── windows-terminal/        # Windows Terminal [Windows]
├── glazewm/                 # GlazeWM tiling WM [Windows]
├── yasb/                    # YASB status bar [Windows]
├── vscode/                  # VS Code settings [Both]
├── cursor/                  # Cursor IDE settings [Both]
├── mintty/                  # Git Bash terminal [Windows]
├── github-cli/              # gh CLI config [Both]
├── oh-my-posh/              # oh-my-posh theme [Both]
├── fonts/                   # JetBrains Mono Nerd Font [Both]
├── install-windows.ps1      # Windows symlink installer
├── install-linux.sh         # Linux symlink installer
├── .gitattributes           # Line ending rules
└── .gitignore
```

# Setup Instructions

## Prerequisites

- **Neovim** 0.10+ (stable) — [neovim.io](https://neovim.io)
- **git**

## Required Tools

| Tool | Purpose | Link |
|------|---------|------|
| **ripgrep** (`rg`) | Telescope live grep | [github](https://github.com/BurntSushi/ripgrep) |
| **fd** | Telescope find files | [github](https://github.com/sharkdp/fd) |
| **zig** | Treesitter parser compiler (preferred) | [ziglang.org](https://ziglang.org) |
| **Nerd Font** | Icons everywhere (e.g. JetBrainsMono NF) | [nerdfonts.com](https://www.nerdfonts.com) |

> Treesitter also supports `gcc`, `clang`, or `cl` (MSVC) as compilers. Zig is preferred because it works out of the box on all platforms.

## Recommended Tools

| Tool | Purpose |
|------|---------|
| **lazygit** | Git UI inside nvim (`<leader>gg`) |
| **fzf** | Speeds up Telescope fuzzy matching (telescope-fzf-native) |
| **make** | Builds telescope-fzf-native and LuaSnip jsregexp (Linux/macOS) |
| **tree-sitter-cli** | Optional — manual grammar installs via `:TSInstallFromGrammar` |

## Install Commands

### Windows (scoop — recommended)

```
scoop install neovim git ripgrep fd fzf lazygit zig
```

### Windows (chocolatey)

```
choco install -y neovim git ripgrep fd fzf lazygit zig
```

### macOS (Homebrew)

```
brew install neovim git ripgrep fd fzf lazygit zig
```

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y git ripgrep fd-find fzf make gcc
# Neovim 0.10+ — use snap, appimage, or build from source
# https://github.com/neovim/neovim/blob/master/INSTALL.md

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit && sudo install lazygit /usr/local/bin

# zig — download from https://ziglang.org/download/
```

### Fedora

```bash
sudo dnf install -y neovim git ripgrep fd-find fzf make gcc
# lazygit and zig — install manually (see links above)
```

### Arch

```bash
sudo pacman -S neovim git ripgrep fd fzf lazygit zig make
```

## Clone the Config

| OS | Command |
|----|---------|
| Linux / macOS | `git clone <repo-url> ~/.config/nvim` |
| Windows (PowerShell) | `git clone <repo-url> "$env:LOCALAPPDATA\nvim"` |
| Windows (cmd) | `git clone <repo-url> "%localappdata%\nvim"` |

## Post-Install

1. Run `nvim`
2. **Lazy** auto-installs all plugins on first launch
3. **Mason** auto-installs LSP servers and formatters — check with `:Mason`
4. Run `:checkhealth` to verify everything is working

## LSP Servers & Formatters

### Auto-installed by Mason (no action needed)

| Server | Languages |
|--------|-----------|
| `lua_ls` | Lua |
| `gopls` | Go |
| `ts_ls` | JavaScript, TypeScript, JSX, TSX |
| `html` | HTML |
| `cssls` | CSS |
| `tailwindcss` | Tailwind CSS |
| `pylsp` | Python (Jedi completions, hover, refs) |
| `ruff` | Python (linting, code actions) |
| `eslint` | JS/TS (linting, code actions) |
| `jsonls` | JSON |
| `yamlls` | YAML |
| `taplo` | TOML |
| `marksman` | Markdown |
| `stylua` | Lua formatter |

### Manual Setup Per Language

**Python**

```bash
pip install python-lsp-server pylsp-rope
```

- `pylsp` provides completions, hover, go-to-definition via Jedi
- `pylsp-rope` adds refactoring and auto-import support
- `ruff` LSP (Mason-installed) handles linting and code actions
- Formatter: `ruff_format` via conform.nvim
- Use `<leader>vs` (VenvSelect) to activate your project's virtual environment

**Go**

- Install [Go](https://go.dev/dl/)
- Mason handles `gopls`, `gofumpt`, `goimports`

**JavaScript / TypeScript**

- Install [Node.js + npm](https://nodejs.org/)
- Mason handles `ts_ls`, `eslint`

**General**

- Mason manages all LSP servers and formatters automatically
- Run `:Mason` to view status, install, or update tools
- Run `:LspInfo` to see active servers for the current buffer

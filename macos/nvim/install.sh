#!/usr/bin/env bash
# Neovim setup for macOS. Idempotent: safe to re-run.
# Usage: bash install.sh            (INSTALL_DOTNET=1 bash install.sh to also get .NET SDK for omnisharp)
set -euo pipefail

config_repo_url="${NVIM_REPO_URL:-https://github.com/ZafeerMahmood/kickstart.nvim.git}"
config_dir="$HOME/.config/nvim"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew missing. Install from https://brew.sh first." >&2
  exit 1
fi

# NOTE: make + cc needed by telescope-fzf-native, LuaSnip jsregexp and treesitter parser builds
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools. Re-run this script after the dialog finishes."
  xcode-select --install || true
  exit 1
fi

# NOTE: "formula:binary". Skips anything already on PATH (eg node from nvm, git from Xcode)
brew_formulae=(neovim:nvim git:git ripgrep:rg fd:fd fzf:fzf lazygit:lazygit tree-sitter-cli:tree-sitter node:node go:go)
# NOTE: Neovide cask is "neovide-app" ("neovide" is a from-source formula, no cask by that name)
brew_casks=(font-jetbrains-mono-nerd-font neovide-app)

for formula_and_binary in "${brew_formulae[@]}"; do
  formula="${formula_and_binary%%:*}"
  binary="${formula_and_binary##*:}"
  command -v "$binary" >/dev/null 2>&1 || brew install "$formula"
done

for cask in "${brew_casks[@]}"; do
  brew list --cask "$cask" >/dev/null 2>&1 || brew install --cask "$cask"
done

if [[ "${INSTALL_DOTNET:-0}" == "1" ]]; then
  brew list --cask dotnet-sdk >/dev/null 2>&1 || brew install --cask dotnet-sdk
fi

mkdir -p "$HOME/.config"

if [[ -d "$config_dir/.git" ]]; then
  git -C "$config_dir" pull --ff-only || echo "Skipped pull: local changes or diverged history in $config_dir"
elif [[ -e "$config_dir" ]]; then
  backup_dir="$config_dir.backup.$(date +%Y%m%d%H%M%S)"
  echo "Moving existing $config_dir to $backup_dir"
  mv "$config_dir" "$backup_dir"
  git clone "$config_repo_url" "$config_dir"
else
  git clone "$config_repo_url" "$config_dir"
fi

git -C "$config_dir" remote get-url upstream >/dev/null 2>&1 \
  || git -C "$config_dir" remote add upstream https://github.com/nvim-lua/kickstart.nvim.git

# NOTE: restore = install plugins at the exact commits in lazy-lock.json (same versions as Windows)
nvim --headless "+Lazy! restore" +qa

# NOTE: lsp.lua sets run_on_start = false, so LSPs/formatters never auto-install. Force once here.
nvim --headless "+Lazy load nvim-lspconfig" "+MasonToolsInstallSync" +qa \
  || echo "Mason install incomplete. Open nvim and run :MasonToolsInstall"

echo "Done. Open nvim, wait for treesitter parsers to compile, then run :checkhealth"

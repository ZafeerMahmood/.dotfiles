#!/usr/bin/env bash
# Shell + terminal setup for macOS: pwsh, zsh, WezTerm, fonts, prompt, CLI tools.
# Safe to re-run. Existing non-symlink configs are moved to <file>.backup.
set -euo pipefail

shell_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotfiles_directory="$(cd "$shell_directory/../.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first: https://brew.sh" >&2
  exit 1
fi

brew_formulae=(
  jandedobbeleer/oh-my-posh/oh-my-posh
  zoxide
  fzf
  bat
  git-delta
  ripgrep
  fd
  lazygit
  neovim
  zsh-autosuggestions
  zsh-syntax-highlighting
)

brew_casks=(
  wezterm
  powershell
  font-jetbrains-mono-nerd-font
)

brew install "${brew_formulae[@]}"
for cask_name in "${brew_casks[@]}"; do
  if ! brew list --cask "$cask_name" >/dev/null 2>&1; then
    # NOTE: fails if the app was installed outside brew, keep going so the configs still get linked
    brew install --cask "$cask_name" || echo "WARN: cask $cask_name failed, install it manually" >&2
  fi
done

link_file() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    echo "ok      $target_path"
    return
  fi

  if [[ -e "$target_path" && ! -L "$target_path" ]]; then
    mv "$target_path" "$target_path.backup"
    echo "backup  $target_path.backup"
  fi

  ln -sfn "$source_path" "$target_path"
  echo "linked  $target_path -> $source_path"
}

link_file "$shell_directory/.zshrc" "$HOME/.zshrc"
link_file "$shell_directory/.wezterm.lua" "$HOME/.wezterm.lua"
link_file "$shell_directory/lazygit.yml" "$HOME/Library/Application Support/lazygit/config.yml"
link_file "$shell_directory/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"

if [[ ! -f "$dotfiles_directory/oh-my-posh/robbyrussell.omp.json" ]]; then
  echo "WARN: $dotfiles_directory/oh-my-posh/robbyrussell.omp.json missing, prompt theme will fail" >&2
fi

pwsh -NoProfile -Command '
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  foreach ($moduleName in "CompletionPredictor", "Terminal-Icons") {
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
      Install-Module -Name $moduleName -Scope CurrentUser -Force
    }
  }
'

echo
echo "Done. Open WezTerm (it starts pwsh). Plain zsh uses ~/.zshrc."

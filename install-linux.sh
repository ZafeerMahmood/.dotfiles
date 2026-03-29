#!/usr/bin/env bash
# Symlinks dotfiles from this repo to their expected locations on Linux.
#
# Usage:
#   chmod +x install-linux.sh
#   ./install-linux.sh          # apply symlinks
#   ./install-linux.sh --dry-run  # preview only

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

link_item() {
    local src="$1"   # file/dir inside this repo
    local dest="$2"  # where the tool expects it

    if [[ ! -e "$src" ]]; then
        echo "SKIP (source missing): $src"
        return
    fi

    local dest_parent
    dest_parent="$(dirname "$dest")"
    if [[ ! -d "$dest_parent" ]]; then
        if $DRY_RUN; then echo "[DRY RUN] mkdir -p $dest_parent"; return; fi
        mkdir -p "$dest_parent"
    fi

    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink -f "$dest")"
        if [[ "$current_target" == "$(readlink -f "$src")" ]]; then
            echo "OK (already linked): $dest"
            return
        fi
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        if $DRY_RUN; then echo "[DRY RUN] backup $dest -> $dest.backup"; return; fi
        echo "BACKUP: $dest -> $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    if $DRY_RUN; then echo "[DRY RUN] link $dest -> $src"; return; fi
    ln -sf "$src" "$dest"
    echo "LINKED: $dest -> $src"
}

echo ""
echo "=== Dotfiles Installer (Linux) ==="
echo "Repo: $DOTFILES_DIR"
echo ""

# --- Git ---
link_item "$DOTFILES_DIR/git/.gitconfig"          "$HOME/.gitconfig"
link_item "$DOTFILES_DIR/git/.gitconfig-personal"  "$HOME/.gitconfig-personal"
link_item "$DOTFILES_DIR/git/.gitconfig-work"      "$HOME/.gitconfig-work"
link_item "$DOTFILES_DIR/git/ignore"               "$HOME/.config/git/ignore"

# --- Bash ---
link_item "$DOTFILES_DIR/bash/.bash_profile"       "$HOME/.bash_profile"

# --- Neovim ---
link_item "$DOTFILES_DIR/nvim"                     "$HOME/.config/nvim"

# --- WezTerm ---
link_item "$DOTFILES_DIR/wezterm/.wezterm.lua"     "$HOME/.wezterm.lua"

# --- SSH config (NOT keys) ---
link_item "$DOTFILES_DIR/ssh/config"               "$HOME/.ssh/config"

# --- GitHub CLI ---
link_item "$DOTFILES_DIR/github-cli/config.yml"    "$HOME/.config/gh/config.yml"

# --- VS Code ---
if [[ -d "$HOME/.config/Code/User" ]] || command -v code &>/dev/null; then
    mkdir -p "$HOME/.config/Code/User"
    link_item "$DOTFILES_DIR/vscode/settings.json"    "$HOME/.config/Code/User/settings.json"
    link_item "$DOTFILES_DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
fi

# --- Cursor ---
if [[ -d "$HOME/.config/Cursor/User" ]] || command -v cursor &>/dev/null; then
    mkdir -p "$HOME/.config/Cursor/User"
    link_item "$DOTFILES_DIR/cursor/settings.json"    "$HOME/.config/Cursor/User/settings.json"
    link_item "$DOTFILES_DIR/cursor/keybindings.json" "$HOME/.config/Cursor/User/keybindings.json"
fi

# --- Fonts ---
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
for font in "$DOTFILES_DIR"/fonts/*.ttf; do
    [[ -e "$font" ]] || continue
    fname="$(basename "$font")"
    if [[ ! -e "$FONT_DIR/$fname" ]]; then
        if $DRY_RUN; then echo "[DRY RUN] copy font $fname"; continue; fi
        cp "$font" "$FONT_DIR/$fname"
        echo "COPIED font: $fname"
    else
        echo "OK (font exists): $fname"
    fi
done
if ! $DRY_RUN && command -v fc-cache &>/dev/null; then
    fc-cache -f "$FONT_DIR"
    echo "Font cache refreshed."
fi

echo ""
echo "=== Done! ==="
echo "Run with --dry-run to preview changes without applying them."
echo ""
echo "NOTE: Windows-only configs (PowerShell, Windows Terminal, GlazeWM, YASB,"
echo "      Mintty) are not linked on Linux."
echo ""
echo "IMPORTANT: The WezTerm config defaults to 'pwsh' as the shell."
echo "On Linux, remove or change the 'config.default_prog' line in .wezterm.lua"
echo ""

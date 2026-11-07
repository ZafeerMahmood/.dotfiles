#!/usr/bin/env bash
# Installs AeroSpace + SketchyBar + JankyBorders (macOS stand-ins for GlazeWM + Zebar)
# and links configs from this folder. Safe to re-run.
set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
    mv "$target_path" "$target_path.backup.$(date +%Y%m%d%H%M%S)"
  fi

  ln -sfn "$source_path" "$target_path"
  echo "linked $target_path -> $source_path"
}

echo "==> Installing packages"
brew tap FelixKratz/formulae
brew tap nikitabobko/tap
brew install FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
brew install --cask nikitabobko/tap/aerospace font-jetbrains-mono-nerd-font

echo "==> Linking configs"
chmod +x "$script_directory/sketchybar/sketchybarrc" "$script_directory/sketchybar/plugins/"*.sh
link_path "$script_directory/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link_path "$script_directory/sketchybar" "$HOME/.config/sketchybar"

echo "==> macOS settings for tiling"
# Hide native menu bar (SketchyBar replaces it) and auto-hide the Dock
defaults write NSGlobalDomain _HIDE_MENU_BAR -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# AeroSpace recommendations: one Space across displays, grouped Mission Control, fixed Space order
defaults write com.apple.spaces spans-displays -bool true
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.dock mru-spaces -bool false

# Turn off built-in macOS window tiling / Stage Manager so they do not fight AeroSpace
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Drag any window with ctrl+cmd+click (handy for floating windows)
defaults write -g NSWindowShouldDragOnGesture -bool true

killall Dock || true
killall SystemUIServer || true

echo "==> Starting"
if pgrep -xq AeroSpace; then
  aerospace reload-config
  if pgrep -xq sketchybar; then
    sketchybar --reload
  else
    nohup sketchybar >/dev/null 2>&1 &
  fi
  if ! pgrep -xq borders; then
    nohup borders active_color=0xff8dbcff inactive_color=0xffa1a1a1 width=2.0 style=square >/dev/null 2>&1 &
  fi
else
  # NOTE: first launch runs after-startup-command, which starts sketchybar + borders
  open -a AeroSpace
fi

cat <<'NEXT'

Done. Manual steps left:
  1. System Settings > Privacy & Security > Accessibility: allow AeroSpace.
  2. System Settings > Control Center > "Automatically hide and show the menu bar": Always.
  3. Log out and back in so "Displays have separate Spaces" (spans-displays) takes effect.
  4. If alt+enter terminal is not WezTerm, edit alt-enter in aerospace.toml.
NEXT

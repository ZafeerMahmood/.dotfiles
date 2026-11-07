#!/bin/bash
# Pulls dotfiles and re-applies AeroSpace + SketchyBar + borders. Safe to re-run.
set -u

windows_directory="$HOME/.dotfiles/macos/windows"

git -C "$HOME/.dotfiles" pull --ff-only

# NOTE: files committed from Windows lose the x flag, set it again every time
chmod +x "$windows_directory"/*.sh "$windows_directory/sketchybar/sketchybarrc" \
  "$windows_directory"/sketchybar/plugins/*.sh "$windows_directory/borders/bordersrc"

mkdir -p ~/.config/aerospace ~/.config/borders
ln -sfn "$windows_directory/aerospace.toml" ~/.config/aerospace/aerospace.toml
ln -sfn "$windows_directory/sketchybar" ~/.config/sketchybar
ln -sfn "$windows_directory/borders/bordersrc" ~/.config/borders/bordersrc

aerospace reload-config
brew services restart sketchybar
brew services restart borders

echo "Applied. Run: bash $windows_directory/doctor.sh"

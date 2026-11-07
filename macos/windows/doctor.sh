#!/bin/bash
# Prints the state of AeroSpace + SketchyBar + borders. Read-only, paste the output back.

section() { printf '\n=== %s\n' "$1"; }

section "versions"
sw_vers -productVersion
aerospace --version 2>&1 | head -1
sketchybar --version 2>&1
borders --version 2>&1 | head -1

section "services"
brew services list | grep -E 'sketchybar|borders'
pgrep -xl AeroSpace || echo "AeroSpace NOT running"

section "links"
ls -la ~/.config/aerospace/aerospace.toml ~/.config/sketchybar ~/.config/borders/bordersrc 2>&1

section "executable flags (need x)"
ls -l ~/.dotfiles/macos/windows/sketchybar/sketchybarrc ~/.dotfiles/macos/windows/sketchybar/plugins/*.sh \
  ~/.dotfiles/macos/windows/borders/bordersrc | awk '{print $1, $NF}'

section "screens (reserved top px = space macOS keeps above windows)"
osascript -l JavaScript -e '
ObjC.import("AppKit");
var screens = $.NSScreen.screens, lines = [];
for (var index = 0; index < screens.count; index++) {
  var screen = screens.objectAtIndex(index), frame = screen.frame, visible = screen.visibleFrame;
  var reserved = (frame.origin.y + frame.size.height) - (visible.origin.y + visible.size.height);
  lines.push(screen.localizedName.js + " | " + frame.size.width + "x" + frame.size.height + " | reserved top " + reserved);
}
lines.join("\n");'
aerospace list-monitors

section "gaps in config"
grep -n 'outer.top' ~/.config/aerospace/aerospace.toml

section "bar items"
sketchybar --query bar 2>&1 | grep -E '"height"|"items"' -A12 | head -20
for item in date battery cpu memory network space.1 space.2; do
  printf '%-10s label=%s drawing=%s\n' "$item" \
    "$(sketchybar --query "$item" 2>/dev/null | grep -m1 '"value"' | cut -d'"' -f4)" \
    "$(sketchybar --query "$item" 2>/dev/null | grep -m1 '"drawing"' | cut -d'"' -f4)"
done

section "workspace sync test"
focused_workspace="$(aerospace list-workspaces --focused)"
echo "focused: $focused_workspace"
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$focused_workspace" && echo "trigger ok"
sleep 1
sketchybar --query "space.$focused_workspace" | grep -m1 '"color"' -A0
bash -x ~/.dotfiles/macos/windows/sketchybar/plugins/workspaces.sh 2>&1 | tail -3

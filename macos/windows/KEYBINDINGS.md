# Tiling keybindings: GlazeWM (Windows) -> AeroSpace (Mac)

`alt` = Option key on Mac. Same physical keys on both machines.
Source: `~/.glzr/glazewm/config.yaml` -> `macos/windows/aerospace.toml`.

## Main mode

| Windows key | Mac key | Action | Notes |
|---|---|---|---|
| alt+h/j/k/l, alt+arrows | alt-h/j/k/l, alt-arrows | Focus window left/down/up/right | Same |
| alt+shift+h/j/k/l, alt+shift+arrows | alt-shift-h/j/k/l, alt-shift-arrows | Move window | Same |
| alt+u / alt+p | alt-u / alt-p | Width -/+ | 2% -> 30px |
| alt+o / alt+i | alt-o / alt-i | Height +/- | 2% -> 30px |
| alt+r | alt-r | Enter resize mode | Bar shows "resize" |
| alt+shift+p | alt-shift-p | Pause/resume WM | `enable toggle` |
| alt+v | alt-v | Toggle tiling direction | `layout tiles horizontal vertical` |
| alt+space | alt-space | Cycle focus | No tiling/floating cycle on Mac; cycles windows |
| alt+shift+space | alt-shift-space | Toggle floating | Not auto-centered |
| alt+t | alt-t | Make window tiling | Same |
| alt+m | alt-m | Minimize | Same |
| alt+shift+q | alt-shift-q | Close window | Same |
| alt+shift+e | alt-shift-e | Quit WM | Quits AeroSpace app |
| alt+shift+r | alt-shift-r | Reload config | Also reloads SketchyBar |
| alt+shift+w | alt-shift-w | Redraw | No redraw on Mac; flattens layout tree |
| alt+enter | alt-enter | Open terminal | `wt` -> WezTerm |
| alt+s / alt+a | alt-s / alt-a | Next / prev workspace | Wraps around |
| alt+d | alt-d | Last used workspace | `workspace-back-and-forth` |
| alt+1..9 | alt-1..9 | Go to workspace N | Same |
| alt+shift+1..9 | alt-shift-1..9 | Move window to workspace N and follow | Same |
| alt+shift+a / alt+shift+f | alt-shift-a / alt-shift-f | Move workspace to monitor left / right | Same |
| alt+shift+d / alt+shift+s | alt-shift-d / alt-shift-s | Move workspace to monitor up / down | Same |

## Resize mode

| Windows key | Mac key | Action |
|---|---|---|
| h / left | h / left | Width -30px |
| l / right | l / right | Width +30px |
| k / up | k / up | Height +30px |
| j / down | j / down | Height -30px |
| escape / enter | esc / enter | Back to main mode |

## Mouse

| Mac | Action |
|---|---|
| Click workspace number in SketchyBar | Go to workspace |
| Click tiling icon in SketchyBar | Toggle tiling direction |
| ctrl+cmd+drag | Move any window (set by install.sh) |

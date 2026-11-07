#!/bin/bash
# Same rules as Zebar workspace buttons: show workspaces that have windows or are on screen,
# lighter background when displayed, blue when focused.

focused_workspace="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
non_empty_workspaces=" $(aerospace list-workspaces --monitor all --empty no | tr '\n' ' ') "
visible_workspaces=" $(aerospace list-workspaces --monitor all --visible | tr '\n' ' ') "

set_arguments=()
for workspace_id in 1 2 3 4 5 6 7 8 9; do
  drawing=off
  background_color=0x0dffffff

  case "$non_empty_workspaces" in *" $workspace_id "*) drawing=on ;; esac

  case "$visible_workspaces" in
    *" $workspace_id "*)
      drawing=on
      background_color=0x26ffffff
      ;;
  esac

  if [ "$workspace_id" = "$focused_workspace" ]; then
    drawing=on
    background_color=0x804b73ff
  fi

  set_arguments+=(--set "space.$workspace_id" drawing="$drawing" background.color="$background_color")
done

sketchybar "${set_arguments[@]}"

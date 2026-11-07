#!/bin/bash
# Total CPU usage across all cores. Turns red above 85% like the Zebar widget.

core_count=$(sysctl -n hw.ncpu)
cpu_percent=$(ps -A -o %cpu= | awk -v cores="$core_count" '{ total += $1 } END { printf "%d", total / cores }')

label_color=0xe6ffffff
if [ "$cpu_percent" -gt 85 ]; then
  label_color=0xff900029
fi

sketchybar --set "$NAME" label="${cpu_percent}%" label.color=$label_color

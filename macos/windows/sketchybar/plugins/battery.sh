#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
battery_info=$(pmset -g batt)
charge_percent=$(echo "$battery_info" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')

if [ -z "$charge_percent" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$charge_percent" -gt 90 ]; then
  battery_icon=
elif [ "$charge_percent" -gt 70 ]; then
  battery_icon=
elif [ "$charge_percent" -gt 40 ]; then
  battery_icon=
elif [ "$charge_percent" -gt 20 ]; then
  battery_icon=
else
  battery_icon=
fi

charging_icon=""
if echo "$battery_info" | grep -q "AC Power"; then
  charging_icon="󰚥"
fi

sketchybar --set "$NAME" drawing=on icon="$charging_icon$battery_icon" label="${charge_percent}%"

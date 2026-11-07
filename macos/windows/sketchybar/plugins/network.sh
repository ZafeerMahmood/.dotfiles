#!/bin/bash
# Wifi / ethernet / offline icon plus SSID.
# NOTE: macOS has no CLI for wifi signal strength anymore, so the icon is always full strength.
# NOTE: macOS 15+ may redact the SSID unless Location Services is allowed; then only the icon shows.

wifi_interface=$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')
default_interface=$(route -n get default 2>/dev/null | awk '/interface:/ { print $2 }')

network_icon=󰤮
network_label=""

if [ -n "$default_interface" ] && [ "$default_interface" = "$wifi_interface" ]; then
  network_icon=󰤨
  network_label=$(ipconfig getsummary "$wifi_interface" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / { print $2 }')
  if [ "$network_label" = "<redacted>" ]; then
    network_label=""
  fi
elif [ -n "$default_interface" ]; then
  network_icon=󰈁
fi

sketchybar --set "$NAME" icon="$network_icon" label="$network_label"

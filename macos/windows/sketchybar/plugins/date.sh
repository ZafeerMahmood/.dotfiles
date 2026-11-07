#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
sketchybar --set "$NAME" label="$(date '+%a %-d %b %-I:%M %p')"

#!/bin/bash
memory_percent=$(memory_pressure | awk '/System-wide memory free percentage/ { printf "%d", 100 - $5 }')
sketchybar --set "$NAME" label="${memory_percent}%"

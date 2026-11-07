#!/bin/bash
# IP-based weather like Zebar's weather provider, via wttr.in (no API key).
# %x is wttr's plain-text condition symbol, %t the temperature in C (because of &m).

weather=$(curl -sf --max-time 10 'https://wttr.in/?format=%x|%t&m') || exit 0
condition=${weather%%|*}
temperature=${weather#*|}
temperature=${temperature#+}

current_hour=$(date +%-H)
is_night=false
if [ "$current_hour" -lt 6 ] || [ "$current_hour" -ge 19 ]; then
  is_night=true
fi

case "$condition" in
  '/!/' | '!/' | '*!*') day_icon=; night_icon= ;;
  '**' | '*' | '*/*' | '*/' | 'x' | 'x/') day_icon=; night_icon= ;;
  '///' | '//') day_icon=; night_icon= ;;
  '/' | '.') day_icon=; night_icon= ;;
  'm' | 'mm' | 'mmm' | '=') day_icon=; night_icon= ;;
  *) day_icon=; night_icon= ;;
esac

weather_icon=$day_icon
if [ "$is_night" = true ]; then
  weather_icon=$night_icon
fi

sketchybar --set "$NAME" icon="$weather_icon" label="$temperature"

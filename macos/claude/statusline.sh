#!/usr/bin/env bash
# Claude Code status line, port of the Windows statusline.ps1 (Catppuccin Mocha).
# Line 1: model · folder  branch
# Line 2: context bar pct% · Xm Xs
# Needs jq. Branch glyph needs a Nerd Font in the terminal.

input=$(cat)

MAUVE=$'\033[38;2;203;166;247m'
TEXT=$'\033[38;2;205;214;244m'
BLUE=$'\033[38;2;137;180;250m'
LAVENDER=$'\033[38;2;180;190;254m'
GREEN=$'\033[38;2;166;227;161m'
SUBTEXT0=$'\033[38;2;166;173;200m'
OVERLAY2=$'\033[38;2;147;153;178m'
PEACH=$'\033[38;2;250;179;135m'
SURFACE2=$'\033[38;2;88;91;112m'
RESET=$'\033[0m'

# NOTE: UTF-8 bytes, macOS /bin/bash 3.2 has no \u escapes
dot=$'\xc2\xb7'
bar_char=$'\xe2\x94\x81'
branch_glyph=$'\xee\x82\xa0'

model=$(jq -r '.model.display_name // "Unknown"' <<<"$input")
directory=$(jq -r '.workspace.current_dir // "."' <<<"$input")
percent=$(jq -r '(.context_window.used_percentage // 0) | round' <<<"$input")
duration_ms=$(jq -r '(.cost.total_duration_ms // 0) | floor' <<<"$input")

folder=$(basename "$directory")
minutes=$((duration_ms / 60000))
seconds=$(((duration_ms % 60000) / 1000))

bar_width=12
filled=$((percent * bar_width / 100))
[ "$filled" -gt "$bar_width" ] && filled=$bar_width
[ "$filled" -lt 0 ] && filled=0
empty=$((bar_width - filled))

repeat() {
    local count=$1 character=$2 output=""
    for ((index = 0; index < count; index++)); do output+="$character"; done
    printf '%s' "$output"
}

branch_name=$(git -C "$directory" --no-optional-locks branch --show-current 2>/dev/null)

line1="${TEXT}${model} ${MAUVE}${dot} ${BLUE}${folder}"
[ -n "$branch_name" ] && line1+=" ${SURFACE2}${branch_glyph} ${LAVENDER}${branch_name}"
line1+="$RESET"

line2="${GREEN}$(repeat "$filled" "$bar_char")${SURFACE2}$(repeat "$empty" "$bar_char")"
line2+=" ${SUBTEXT0}${percent}% ${OVERLAY2}${dot} ${PEACH}${minutes}m ${seconds}s${RESET}"

printf '%s\n%s\n' "$line1" "$line2"

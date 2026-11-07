#!/usr/bin/env bash
# Import Claude Code config, skills and project memories from the Windows export bundle.
#
# Usage: import-claude.sh <bundle_home>
#   <bundle_home> mirrors the Windows home dir (C:/Users/Zafeer Mahmood) and holds:
#     .claude/{CLAUDE.md,settings.json,settings.local.json,keybindings.json,output-styles,skills,projects}
#     .agents/  .agent/  skills-lock.json
#     Desktop/Work/<repo>/.claude/   (untracked project files: CLAUDE.md, plans, skills, settings.local.json)
#
# Env:
#   MAC_WORK_DIR=$HOME/Desktop/Work   where the Work repos live on the Mac
#   INCLUDE_TRANSCRIPTS=1             also copy session transcripts (*.jsonl), not only memory/
#
# Safe to re-run: files are overwritten with the bundle copy, nothing is deleted.

set -euo pipefail

bundle_home="${1:?usage: import-claude.sh <bundle_home>}"
bundle_home="$(cd "$bundle_home" && pwd)"
script_dir="$(cd "$(dirname "$0")" && pwd)"
mac_work_dir="${MAC_WORK_DIR:-$HOME/Desktop/Work}"
mac_work_dir="${mac_work_dir%/}"
include_transcripts="${INCLUDE_TRANSCRIPTS:-0}"
source_claude="$bundle_home/.claude"
target_claude="$HOME/.claude"

command -v jq >/dev/null || brew install jq

mkdir -p "$target_claude"

# Claude Code project dir name: every non-alphanumeric char of the absolute path becomes "-".
encode_path() {
    printf '%s' "$1" | sed 's/[^a-zA-Z0-9]/-/g'
}

# Drops permission rules that only make sense on Windows, and points the status line at the bash port.
fix_settings() {
    local settings_file=$1
    # NOTE: drive letter must not follow a letter, else "https://" counts as a Windows path
    local windows_rule='(^|[^A-Za-z])[A-Za-z]:[\\/]|(^|[ "(/])/[a-z]/|\\|powershell|pwsh|Select-String|Select-Object|Get-ChildItem|Format-Table|ConvertTo-Json|\$env:|where python|wmic|winget|wgpu-info|\bpy |\.exe'
    local temporary_file
    temporary_file="$(mktemp)"

    jq --arg windows_rule "$windows_rule" '
        if .permissions.allow then
            .permissions.allow |= map(select(test($windows_rule; "i") | not))
        else . end
        | if .statusLine then
            .statusLine = {"type": "command", "command": "bash ~/.claude/statusline.sh"}
        else . end
    ' "$settings_file" >"$temporary_file"

    mv "$temporary_file" "$settings_file"
}

echo "==> Global files"
for file_name in CLAUDE.md settings.json settings.local.json keybindings.json; do
    if [ -f "$source_claude/$file_name" ]; then
        cp "$source_claude/$file_name" "$target_claude/$file_name"
    fi
done

for settings_name in settings.json settings.local.json; do
    if [ -f "$target_claude/$settings_name" ]; then
        fix_settings "$target_claude/$settings_name"
    fi
done

cp "$script_dir/statusline.sh" "$target_claude/statusline.sh"
chmod +x "$target_claude/statusline.sh"

echo "==> Output styles"
if [ -d "$source_claude/output-styles" ]; then
    mkdir -p "$target_claude/output-styles"
    cp -R "$source_claude/output-styles/." "$target_claude/output-styles/"
fi

echo "==> Skills (.agents, .agent, ~/.claude/skills)"
for agents_dir in .agents .agent; do
    if [ -d "$bundle_home/$agents_dir" ]; then
        mkdir -p "$HOME/$agents_dir"
        cp -R "$bundle_home/$agents_dir/." "$HOME/$agents_dir/"
    fi
done

if [ -f "$bundle_home/skills-lock.json" ]; then
    cp "$bundle_home/skills-lock.json" "$HOME/skills-lock.json"
fi

mkdir -p "$target_claude/skills"
for skill_path in "$source_claude/skills"/*; do
    [ -e "$skill_path" ] || continue
    skill_name="$(basename "$skill_path")"

    # NOTE: synced/ is re-pulled from claude.ai on login, .trash is junk
    case "$skill_name" in synced | .trash) continue ;; esac

    rm -rf "$target_claude/skills/$skill_name"
    cp -RL "$skill_path" "$target_claude/skills/$skill_name"
done

# NOTE: on Windows these two are junctions into ~/.agents/skills; keep them as symlinks
for linked_skill in claude-memory-files find-skills; do
    if [ -d "$HOME/.agents/skills/$linked_skill" ]; then
        rm -rf "$target_claude/skills/$linked_skill"
        ln -s "$HOME/.agents/skills/$linked_skill" "$target_claude/skills/$linked_skill"
    fi
done

echo "==> Project memories"
mac_home_encoded="$(encode_path "$HOME")"
mac_work_encoded="$(encode_path "$mac_work_dir")"
mac_nvim_encoded="$(encode_path "$HOME/.config/nvim")"

map_project_name() {
    local windows_name=$1
    local remainder

    # NOTE: drive letter shows up as both C-- and c-- depending on how the session started
    remainder="$(printf '%s' "$windows_name" | sed -E 's/^[cC]--Users-Zafeer-Mahmood//')"

    case "$remainder" in
        -Desktop-Work*) printf '%s%s' "$mac_work_encoded" "${remainder#-Desktop-Work}" ;;
        -AppData-Local-nvim*) printf '%s%s' "$mac_nvim_encoded" "${remainder#-AppData-Local-nvim}" ;;
        *) printf '%s%s' "$mac_home_encoded" "$remainder" ;;
    esac
}

for project_path in "$source_claude/projects"/*/; do
    [ -d "$project_path" ] || continue
    windows_name="$(basename "$project_path")"
    mac_name="$(map_project_name "$windows_name")"
    target_project="$target_claude/projects/$mac_name"

    if [ "$include_transcripts" = "1" ]; then
        mkdir -p "$target_project"
        rsync -a --exclude sessions-index.json "$project_path" "$target_project/"
        echo "  $windows_name -> $mac_name (full)"
        continue
    fi

    if [ -d "$project_path/memory" ] && [ -n "$(ls -A "$project_path/memory")" ]; then
        mkdir -p "$target_project/memory"
        cp -R "$project_path/memory/." "$target_project/memory/"
        echo "  $windows_name -> $mac_name"
    fi
done

echo "==> Untracked project .claude files in $mac_work_dir"
if [ -d "$bundle_home/Desktop/Work" ]; then
    for repo_claude in "$bundle_home/Desktop/Work"/*/.claude; do
        [ -d "$repo_claude" ] || continue
        repo_name="$(basename "$(dirname "$repo_claude")")"
        target_repo="$mac_work_dir/$repo_name"

        if [ ! -d "$target_repo" ]; then
            echo "  skip $repo_name: clone it to $target_repo first, then re-run"
            continue
        fi

        mkdir -p "$target_repo/.claude"
        rsync -a --exclude worktrees --exclude projects --exclude scheduled_tasks.lock \
            "$repo_claude/" "$target_repo/.claude/"

        if [ -f "$target_repo/.claude/settings.local.json" ]; then
            fix_settings "$target_repo/.claude/settings.local.json"
        fi

        echo "  $repo_name"
    done
fi

echo "Done. Run 'claude' and log in, then see README.md for plugins."

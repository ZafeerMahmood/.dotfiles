#!/usr/bin/env bash
# Unpacks the zip made by export-for-mac.ps1 into the right Mac places. Safe to re-run (overwrites, never deletes).
#
# Usage: bash ~/.dotfiles/macos/import-from-windows.sh ~/Downloads/mac-export-YYYYMMDD.zip
#   MAC_WORK_DIR=$HOME/Desktop/Work   where the Work repos live
#   INCLUDE_TRANSCRIPTS=1             passed through to claude/import-claude.sh
#
# Run after projects/clone.sh and nvim/install.sh, so repos and ~/.config/nvim already exist.
set -euo pipefail

export_zip="${1:?usage: import-from-windows.sh <mac-export.zip>}"
macos_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mac_work_dir="${MAC_WORK_DIR:-$HOME/Desktop/Work}"
staging_directory="$HOME/mac-import"
bundle_home="$staging_directory/home"

# NOTE: not git repos, so clone.sh never creates them; copy even when missing
standalone_work_folders="claude-code-leaked"

rm -rf "$staging_directory"
mkdir -p "$staging_directory"
unzip -q "$export_zip" -d "$staging_directory"
echo "Unpacked to $staging_directory (manifest: $staging_directory/manifest.txt)"

echo "==> Work repo files (.env, .docs, notes, ...) into $mac_work_dir"
if [ -d "$bundle_home/Desktop/Work" ]; then
  for bundle_folder in "$bundle_home/Desktop/Work"/*/; do
    folder_name="$(basename "$bundle_folder")"
    target_folder="$mac_work_dir/$folder_name"

    if [ ! -d "$target_folder" ] && [[ " $standalone_work_folders " != *" $folder_name "* ]]; then
      echo "  skip $folder_name: clone it first (projects/clone.sh), then re-run"
      continue
    fi

    mkdir -p "$target_folder"
    rsync -a "$bundle_folder" "$target_folder/"
    echo "  $folder_name"
  done
fi

echo "==> Home files (nvim extras, .codex, .gemini, Desktop/TREE, mac-export)"
rsync -a \
  --exclude '/.claude' --exclude '/.agents' --exclude '/.agent' --exclude '/skills-lock.json' \
  --exclude '/Desktop/Work' \
  "$bundle_home/" "$HOME/"

# NOTE: .env files hold secrets, keep them private
find "$mac_work_dir" -maxdepth 6 -name '.env*' -type f -not -path '*/node_modules/*' -exec chmod 600 {} + 2>/dev/null || true

echo "==> Claude Code"
MAC_WORK_DIR="$mac_work_dir" bash "$macos_directory/claude/import-claude.sh" "$bundle_home"

if [ -d "$HOME/.config/nvim/spell" ] && command -v nvim >/dev/null; then
  nvim --headless "+mkspell! ~/.config/nvim/spell/en.utf-8.add" +qa || true
fi

cat <<NEXT

Done. Left to do by hand:
  - Postgres dumps (if exported): $HOME/mac-export/pg, restore per macos/tools/databases.md section 3
  - Stash patches (if any): $HOME/mac-export/stashes, apply with: git -C <repo> apply <patch>
  - Fix Windows paths in ~/.codex/config.toml (drop [windows], notify exe) and ~/.gemini/extensions/extension-enablement.json
  - cli-vault: cd ~/Desktop/TREE/Personal_Projects/cli-vault && npm install && npm link
  - Delete $staging_directory and the zip once everything works (they hold secrets)
NEXT

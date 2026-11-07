#!/usr/bin/env bash
# Sets up the Mac to match the Windows PC. Runs every area script in order. Safe to re-run.
#
# Usage: bash ~/.dotfiles/macos/bootstrap.sh [path/to/mac-export-*.zip]
#   SETUP_SSH=1   also create + upload ~/.ssh/personal and ~/.ssh/work (git-editors --ssh)
#   With a zip, private files are imported at the end (import-from-windows.sh).
set -uo pipefail

macos_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export_zip="${1:-}"
failed_steps=()

run_step() {
  local step_name="$1"
  shift
  echo
  echo "################ $step_name"
  if ! "$@"; then
    echo "!! $step_name failed, continuing. Fix and re-run bootstrap.sh"
    failed_steps+=("$step_name")
  fi
}

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools. Re-run this script when the dialog finishes."
  xcode-select --install || true
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew missing. Install from https://brew.sh, then re-run." >&2
  exit 1
fi
eval "$(brew shellenv)"

# NOTE: keep going past one bad cask (eg app already in /Applications outside brew)
run_step "brew bundle" brew bundle --file="$macos_directory/Brewfile"

ssh_flag=()
[ "${SETUP_SSH:-0}" = "1" ] && ssh_flag=(--ssh)
run_step "git + gh + editors" bash "$macos_directory/git-editors/install.sh" ${ssh_flag[@]+"${ssh_flag[@]}"}

run_step "tools + runtimes" bash "$macos_directory/tools/install-tools.sh"
# shellcheck disable=SC1091
[ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile"

run_step "shell + terminal" bash "$macos_directory/shell/install.sh"
run_step "neovim" bash "$macos_directory/nvim/install.sh"
run_step "window manager" bash "$macos_directory/windows/install.sh"

run_step "postgres service" brew services start postgresql@16
run_step "redis service" brew services start redis

run_step "clone work repos" bash "$macos_directory/projects/clone.sh"

if [ -n "$export_zip" ]; then
  run_step "import private files" bash "$macos_directory/import-from-windows.sh" "$export_zip"
fi

echo
echo "################ summary"
if [ "${#failed_steps[@]}" -gt 0 ]; then
  printf 'FAILED: %s\n' "${failed_steps[@]}"
else
  echo "All steps ran."
fi

cat <<'MANUAL'

Still manual (details in ~/.dotfiles/macos/README.md):
  - Accessibility permission for AeroSpace; log out/in for spans-displays
  - Xcode app from App Store, then: sudo xcode-select -s /Applications/Xcode.app && xcodebuild -runFirstLaunch
  - Android Studio SDK Manager: platforms 31/34/35, build-tools 34/35.0.1/36
  - Postgres roles + databases (macos/tools/databases.md section 2 or 3)
  - Per project setup (macos/projects/README.md sections 3-9)
  - claude /login, plugins (macos/claude/README.md step 5)
  - stripe login; vercel login; gh auth status
  - Fix Windows paths in ~/.codex/config.toml and ~/.gemini/extensions/extension-enablement.json
MANUAL

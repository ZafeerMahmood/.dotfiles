#!/usr/bin/env bash
# Git, gh, SSH and editor setup for macOS. Safe to re-run.
# Usage: bash install.sh [--ssh]   (--ssh also creates keys and uploads them via gh)
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
AREA_DIR="$DOTFILES_DIR/macos/git-editors"
SETUP_SSH=false
[[ "${1:-}" == "--ssh" ]] && SETUP_SSH=true

WORK_ACCOUNT="ZafeerTaxGPT"
PERSONAL_ACCOUNT="ZafeerMahmood"

link_file() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    return
  fi

  if [[ -e "$target_path" && ! -L "$target_path" ]]; then
    mv "$target_path" "$target_path.backup"
    echo "backed up $target_path"
  fi

  ln -sfn "$source_path" "$target_path"
  echo "linked $target_path"
}

gh_has_account() {
  local status_output
  status_output="$(gh auth status --hostname github.com 2>&1 || true)"
  grep -q "account $1 " <<< "$status_output"
}

echo "== brew packages"
brew install git gh git-delta git-lfs
brew install --cask visual-studio-code cursor font-jetbrains-mono-nerd-font

echo "== git config"
link_file "$AREA_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"
git lfs install --skip-repo >/dev/null
mkdir -p "$HOME/Desktop/Work" "$HOME/Desktop/TREE"

echo "== gh"
# NOTE: copied not linked, gh rewrites this file on `gh config set`
if [[ ! -f "$HOME/.config/gh/config.yml" ]]; then
  mkdir -p "$HOME/.config/gh"
  cp "$AREA_DIR/gh-config.yml" "$HOME/.config/gh/config.yml"
fi

for account in "$PERSONAL_ACCOUNT" "$WORK_ACCOUNT"; do
  if ! gh_has_account "$account"; then
    echo "Log in as $account (switch the browser to that GitHub account; answer No to 'Authenticate Git', .gitconfig already does it)"
    gh auth login --hostname github.com --git-protocol https --web
  fi
done
gh auth switch --hostname github.com --user "$WORK_ACCOUNT"

# NOTE: skipping `gh auth setup-git`, the linked .gitconfig already wires gh as the github.com helper

if $SETUP_SSH; then
  echo "== ssh keys"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if ! grep -q "^Host pers" "$HOME/.ssh/config" 2>/dev/null; then
    cat "$AREA_DIR/ssh-config" >> "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
  fi

  for key_pair in "personal:$PERSONAL_ACCOUNT:zafeer7460@gmail.com" "work:$WORK_ACCOUNT:zafeer@taxgpt.com"; do
    IFS=":" read -r key_name account email <<< "$key_pair"
    key_path="$HOME/.ssh/$key_name"

    if [[ ! -f "$key_path" ]]; then
      ssh-keygen -t ed25519 -C "$email" -f "$key_path"
      ssh-add --apple-use-keychain "$key_path"
    fi

    gh auth switch --hostname github.com --user "$account"
    uploaded_keys="$(gh ssh-key list 2>/dev/null || true)"
    if ! grep -qF "$(awk '{print $2}' "$key_path.pub")" <<< "$uploaded_keys"; then
      gh auth refresh --hostname github.com --scopes admin:public_key
      gh ssh-key add "$key_path.pub" --title "MacBook $key_name"
    fi
  done

  gh auth switch --hostname github.com --user "$WORK_ACCOUNT"
fi

echo "== editors"
vscode_user_dir="$HOME/Library/Application Support/Code/User"
cursor_user_dir="$HOME/Library/Application Support/Cursor/User"

for file_name in settings.json keybindings.json; do
  link_file "$AREA_DIR/vscode/$file_name" "$vscode_user_dir/$file_name"
  link_file "$AREA_DIR/cursor/$file_name" "$cursor_user_dir/$file_name"
done
link_file "$AREA_DIR/cursor-mcp.json" "$HOME/.cursor/mcp.json"

install_extensions() {
  local editor_command="$1"
  local list_file="$2"
  local installed_extensions

  installed_extensions="$("$editor_command" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"

  while read -r extension_id; do
    [[ -z "$extension_id" ]] && continue
    if ! grep -qx "$(echo "$extension_id" | tr '[:upper:]' '[:lower:]')" <<< "$installed_extensions"; then
      "$editor_command" --install-extension "$extension_id" || echo "failed: $extension_id"
    fi
  done < "$list_file"
}

install_extensions code "$AREA_DIR/vscode-extensions.txt"
install_extensions cursor "$AREA_DIR/cursor-extensions.txt"

echo "== done. Check: git config user.email (inside ~/Desktop/Work repo), gh auth status, ssh -T git@github.com"

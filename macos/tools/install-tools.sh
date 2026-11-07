#!/usr/bin/env bash
# Installs CLI tools and runtimes to match the Windows PC. Safe to re-run.
set -euo pipefail

tools_directory="$(cd "$(dirname "$0")" && pwd)"

brew update
# NOTE: one failed cask (e.g. app already in /Applications) should not stop the rest
brew bundle --file="$tools_directory/Brewfile" || echo "brew bundle had failures, re-run: brew bundle check --verbose"

# NOTE: node@24 and ruby are keg-only, put them ahead of system versions
shell_profile="$HOME/.zprofile"
touch "$shell_profile"
for keg_path_line in \
  'export PATH="/opt/homebrew/opt/node@24/bin:$PATH"' \
  'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' \
  'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' \
  'export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"' \
  'export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"' \
  'export ANDROID_HOME="$HOME/Library/Android/sdk"' \
  'export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"' \
  'export EDITOR="nvim"'; do
  grep -qxF "$keg_path_line" "$shell_profile" || echo "$keg_path_line" >> "$shell_profile"
  eval "$keg_path_line"
done

# Claude Code (native installer, auto-updates)
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

# Python 3.11 (all projects pin 3.11) and Python CLI tools
uv python install 3.11
for python_tool in poetry ruff pre-commit black; do
  uv tool install "$python_tool"
done

# Global npm packages from the PC
npm install -g yarn prettier eslint_d neovim tree-sitter-cli vercel @vscode/vsce @google/gemini-cli @openai/codex ui-ux-pro-max-cli

# Go tools used by Neovim
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest

echo "Done. Next: Xcode from App Store, then: sudo xcode-select -s /Applications/Xcode.app && xcodebuild -runFirstLaunch"

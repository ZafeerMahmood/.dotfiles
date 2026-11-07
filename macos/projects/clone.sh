#!/usr/bin/env bash
# Clone work repos into ~/Desktop/Work with the same branches as the Windows PC.
# Idempotent: existing repos are fetched, not re-cloned.
#
# Auth: uses SSH with ~/.ssh/work when it exists, else HTTPS via gh (run `gh auth setup-git` first).
# Remotes stay plain github.com URLs. No `pers:` / `work:` alias remotes.
#
# Usage: bash ~/.dotfiles/macos/projects/clone.sh
set -euo pipefail

work_directory="$HOME/Desktop/Work"
work_ssh_key="$HOME/.ssh/work"
mkdir -p "$work_directory"

if [ -f "$work_ssh_key" ]; then
  export GIT_SSH_COMMAND="ssh -i $work_ssh_key -o IdentitiesOnly=yes"
  remote_prefix="git@github.com:"
else
  command -v gh >/dev/null || { echo "need gh or ~/.ssh/work"; exit 1; }
  gh auth setup-git
  remote_prefix="https://github.com/"
fi

# folder | github repo | branch to check out
repositories=(
  "TaxGPT_App|TaxGPT/TaxGPT_App|dev"
  "TaxGPT_ai_services|TaxGPT/TaxGPT_ai_services|dev"
  "TaxGPT_cowork|TaxGPT/TaxGPT_cowork|EN-9044-harness-connect-card"
  "TaxGPT_ui_library|TaxGPT/TaxGPT_ui_library|main"
  "chrome-extension|TaxGPT/chrome-extension|dev"
  "taxgpt_mobile|TaxGPT/taxgpt_mobile|main"
  "taxgpt_prompts|TaxGPT/taxgpt_prompts|main"
  "document-upload|TaxGPT/document-upload|main"
)

checkout_branch() {
  local repository_path="$1" branch="$2"

  if git -C "$repository_path" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$repository_path" checkout "$branch"
  elif git -C "$repository_path" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$repository_path" checkout -b "$branch" --track "origin/$branch"
  else
    echo "  branch $branch not on origin yet (push it from Windows), staying on default"
  fi
}

for entry in "${repositories[@]}"; do
  IFS='|' read -r folder_name github_repository branch <<< "$entry"
  repository_path="$work_directory/$folder_name"
  echo "== $folder_name"

  # NOTE: only pick the Windows branch on first clone, so reruns don't move you off your current Mac branch
  if [ -d "$repository_path/.git" ]; then
    git -C "$repository_path" fetch --all --prune
  else
    git clone "${remote_prefix}${github_repository}.git" "$repository_path"
    checkout_branch "$repository_path" "$branch"
  fi
done

# TaxGPT_cowork-formatting is a git worktree of TaxGPT_cowork on Windows, not its own clone.
formatting_path="$work_directory/TaxGPT_cowork-formatting"
formatting_branch="chore-prettier-setup"
cowork_path="$work_directory/TaxGPT_cowork"
if [ ! -e "$formatting_path" ]; then
  if git -C "$cowork_path" show-ref --verify --quiet "refs/remotes/origin/$formatting_branch"; then
    git -C "$cowork_path" worktree add "$formatting_path" "$formatting_branch"
  else
    echo "== skip TaxGPT_cowork-formatting: push $formatting_branch from Windows first"
  fi
fi

# Third-party assignment repo under review (not a TaxGPT repo).
assignment_path="$work_directory/review-assignments/taxgpt-assignment"
if [ ! -d "$assignment_path/.git" ]; then
  mkdir -p "$work_directory/review-assignments"
  git clone https://github.com/Usamaraoo/taxgpt-assignment.git "$assignment_path"
fi

echo
echo "Not cloned (copy via export bundle if still needed):"
echo "  claude-code-leaked/ (no git), review-assignments/taxgpt-assignment-review.md"
echo "  test-worktree (stale TaxGPT_App worktree, recreate with: git -C TaxGPT_App worktree add ../test-worktree <branch>)"

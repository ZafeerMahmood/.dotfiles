# zsh port of the pwsh profile + Windows .bash_profile
# Linked to ~/.zshrc by install.sh

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export EDITOR=nvim
export VISUAL=nvim

# History (PSReadLine keeps a big shared history, match it)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=20000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY

# Completion, case insensitive with a menu like PSReadLine
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

bindkey -e

# Up/Down search history by the typed prefix (PSReadLine HistorySearchBackward/Forward)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# Aliases
alias ..='cd ..'
alias c='clear'
alias g='git'
alias dmm='python manage.py makemigrations'
alias dm='python manage.py migrate'
alias dr='python manage.py runserver'
alias ds='python manage.py shell'
alias nr='npm run dev'

# Prompt, jump, fuzzy finder
eval "$(oh-my-posh init zsh --config "$HOME/.dotfiles/oh-my-posh/robbyrussell.omp.json")"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Inline suggestions (PSReadLine PredictionViewStyle Inline)
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# RightArrow at end of line accepts the next suggestion word, like the pwsh profile
forward_char_or_accept_word() {
  if (( CURSOR == ${#BUFFER} )); then
    zle forward-word
  else
    zle forward-char
  fi
}
zle -N forward_char_or_accept_word
# NOTE: unwrapped so the suggestion is still visible when forward-word runs inside it
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(forward_char_or_accept_word)
bindkey '^[[C' forward_char_or_accept_word
bindkey '^[OC' forward_char_or_accept_word

# NOTE: must be sourced last
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

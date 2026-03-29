eval "$(oh-my-posh init bash --config ~/.dotfiles/oh-my-posh/robbyrussell.omp.json)"
eval "$(zoxide init bash)"
eval "$(fzf --bash)"

# Aliases (matching PowerShell profile)
alias dmm='python manage.py makemigrations'
alias dm='python manage.py migrate'
alias dr='python runserver'
alias ds='python manage.py shell'
alias nr='npm run dev'
alias c='clear'
alias g='git'
alias ..='cd ..'

search_history() {
    local query="$readline_line"
    local selected_command
    selected_command=$(cat ~/.bash_history | grep -v "^#" | sort -u | fzf --query="$query" --height=40% --reverse)
    buffer="$selected_command"
    readline_line="$selected_command"
    readline_point=${#selected_command}
}

bind -x '"\C-r": search_history'

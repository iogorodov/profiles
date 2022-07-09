export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

export PATH="/opt/homebrew/opt/node@16/bin:$PATH"

alias ll='ls -alF'
alias ..='cd ..'
alias ...='cd ../..'
alias ff='find . -name'

set -o AUTO_CD
set -o NO_CASE_GLOB
set -o SHARE_HISTORY
set -o APPEND_HISTORY
set -o INC_APPEND_HISTORY
set -o HIST_IGNORE_ALL_DUPS

eval "$(/opt/homebrew/bin/brew shellenv)"
autoload -Uz compinit && compinit

PROMPT='%F{2}%3/%f %# '

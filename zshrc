setopt NO_CASE_GLOB
setopt AUTO_CD

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST 
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' %F{yellow}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b%u%c|%a)%f'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' enable git

export PATH="/usr/local/opt/node@16/bin:$PATH"
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export PROMPT='%F{green}%2~%f$vcs_info_msg_0_ %# '

alias ll='ls -Galh'
alias ..='cd ..'
alias ...='cd ../..'

autoload -Uz compinit && compinit

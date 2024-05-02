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

x() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            # *.rar)       rar x $1      ;;
            # *.7z)        7z x $1       ;;
            *)           echo "'$1' cannot be extracted via x()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

export PATH="/opt/homebrew/opt/node@20/bin:/opt/homebrew/bin:$PATH"
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export PROMPT='%F{green}%2~%f$vcs_info_msg_0_ %# '

alias ll='ls -Galh'
alias ..='cd ..'
alias ...='cd ../..'
alias g=git

autoload -Uz compinit && compinit

export PS1="\[$(tput bold)\]\[$(tput setaf 2)\]\w \\$ \[$(tput sgr0)\]\[$(tput sgr0)\]"

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

alias ll='ls -alF'
alias ..='cd ..'
alias ...='cd ../..'
alias ff='find . -name'

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

vm() 
{
    case $# in
    0) 
        runningvms=`VBoxManage list runningvms`
        if [ -z "$runningvms" ]; then
            VBoxManage list vms | sed 's/^/  /'
        else
            echo "$runningvms" | sed 's/^/* /'
            VBoxManage list vms | grep -Fxv "$runningvms" | sed 's/^/  /'
        fi
        ;;
    1)
        if [ "$1" == "help" ]; then
            echo "Usage vm [help|start|stop] [<vmname>]"
        else
            VBoxManage startvm $1 --type headless
        fi
        ;;
    2)
        case "$1" in
        "start")
            VBoxManage startvm $2 --type headless
            ;;
        "stop")
            VBoxManage controlvm $2 acpipowerbutton
            ;;
        *)
            echo "Invalid command '$1'. Run 'vm help' to show command's ussage"
            ;;
        esac
        ;;
    *) 
        echo "Run 'vm help' to show command's ussage"
        ;;
    esac
}

_vm() 
{
    COMPREPLY=()
    current="${COMP_WORDS[COMP_CWORD]}"

    runningvms=`VBoxManage list runningvms`
    if [ -z "$runningvms" ]; then
        stoppedvms=`VBoxManage list vms | sed -e 's/^"\(.*\)"[[:space:]].*/\1/' | tr '\n' ' '`
    else
        stoppedvms=`VBoxManage list vms | grep -Fxv "$runningvms" | sed -e 's/^"\(.*\)"[[:space:]].*/\1/' | tr '\n' ' '`
    fi
    runningvms=`echo "$runningvms" | sed -e 's/^"\(.*\)"[[:space:]].*/\1/' | tr '\n' ' '`


    if [[ ${COMP_CWORD} == 1 ]] ; then
        COMPREPLY=( $(compgen -W "help start stop ${stoppedvms}" -- ${current}) )
        return 0
    elif [[ ${COMP_CWORD} == 2 ]] ; then
        case "${COMP_WORDS[1]}" in
        "start")
            COMPREPLY=( $(compgen -W "${stoppedvms}" -- ${current}) )
            return 0
            ;;
        "stop")
            COMPREPLY=( $(compgen -W "${runningvms}" -- ${current}) )
            return 0
            ;;
        esac
    fi

    return 1
}

complete -F _vm vm

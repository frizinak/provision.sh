#! /bin/bash
log () {
    echo -en "\033[1m$*\033[0m"
}

logf () {
    local f="$1"
    shift
    printf "\033[1m${f}\033[0m" $@
}

list () {
    local f="$1"
    shift
    echo -en "\033[1;32m${f}\033[0m $*"
}

err () {
    echo -en "\033[1;31m$*\033[0m"
}

prompt () {
    echo -en "\033[3;32m$*\033[0m "
}


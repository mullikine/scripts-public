#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# DWIM -- function

# cd -- force. if it's a file, cd to it
# if it's something else which I can't do

fp="$1"

if test -f "$fp"; then
    dn="$(dirname "$fp")"
    zcd "$dn"
    exit $?
fi

if test -d "$fp"; then
    zcd "$fp"
    exit $?
fi

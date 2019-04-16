#!/bin/bash
export TTY

( hs "$(basename "$0")" "$(ps -o comm= $PPID)" "-->" "$@" 0</dev/null ) &>/dev/null

line="$1"
col="$2"
fp="$3"
shift
shift
shift

export DISPLAY=:0

# vim + "$line" "$column" "$fp"

# xterm -ls -e "TERM=xterm-256color TMUX= tmux new $(aqf "v +$line:$col $(aqf "$fp")")"

PARENT_COMMAND="$(ps -o comm= $PPID)"

case "$PARENT_COMMAND" in
    firefox) {
        vimopts+=" -c $(aqf "set ft=html") "
    }
    ;;

    *)
esac

set -m

export TMUX= 
xt -b tmux new -s pentadactyl "v +$line:$col $vimopts $(aqf "$fp")" &

sleep 0.5

case "$PARENT_COMMAND" in
    firefox) {
        tmux splitw -t pentadactyl "elinks-dump $(aqf "$fp") | vs"
    }
    ;;

    *)
esac

wait

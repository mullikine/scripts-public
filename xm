#!/bin/bash

cmd="$1"

case "$cmd" in
    ws1) {
        xm-sendcommand 1
        xdotool keyup Super_L
        sleep 0.2
        xdotool key F13
    }
    ;;
esac
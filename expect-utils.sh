#!/bin/bash
export TTY

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    control-char) {
        letter="$2"
        num="$(p "$letter" | c lc | ord)"
        # "send \003"
        shift
        shift
    }
    ;;

    *) break;
esac; done

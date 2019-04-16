#!/bin/bash
export TTY

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -d) {
        delay="$2"
        shift
        shift
    }
    ;;

    *) break;
esac; done

CMD="$(cmd "$@")"

while true; do
    echo "$CMD" | udl
    eval "$CMD"
    if [ -n "$delay" ]; then
        sleep "$delay"
    fi
done

#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    aq "$ARG"
    printf ' '
done
eval ARG=\${$i}
aq "$ARG"
)"

eval "ssh bbox@localhost $CMD"
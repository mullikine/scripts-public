#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    aq "$ARG"
    printf '\n'
done
eval ARG=\${$i}
aq "$ARG"
)"

# echo "$@"
# eval echo "$@"
# eval echo "$CMD"
echo "$CMD"

#!/bin/bash
CMD=''
for (( i = 1; i <= $#; i++ )); do
    eval ARG=\${$i}
    CMD="$CMD $(printf -- "%s" "$ARG" | q)"
done
cmd="/usr/bin/xterm -ls -en en_US.UTF-8 $CMD"



notify-send "$0"
eval "$cmd"

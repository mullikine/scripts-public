#!/bin/bash
CMD=''
for (( i = 1; i <= $#; i++ )); do
    eval ARG=\${$i}
    CMD="$CMD $(printf -- "%s" "$ARG" | q)"
done
cmd="e -D spacemacs c $CMD"
eval "$cmd"
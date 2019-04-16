#!/bin/bash

# This is run by 'ge' in vim.

CMD=''
for (( i = 1; i <= $#; i++ )); do
    eval ARG=\${$i}
    CMD="$CMD $(printf -- "%s" "$ARG" | q)"
done
cmd="ge $CMD"

ns "$cmd"
tm -f nw "$cmd"

#!/bin/bash
export TTY

exec 2>/dev/null

awk 1 | while IFS=$'\n' read -r line; do
    if [ -e "$line" ]; then
        printf -- "%s\n" "$line"
    fi
done | xargs -L20 $HOME/scripts/ssdeep

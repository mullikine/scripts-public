#!/bin/bash
export TTY

# resolve paths

awk 1 | while IFS=$'\n' read -r fp; do
    if [ -e "$fp" ]; then
        rp="$(realpath "$fp")"
        printf -- "%s\n" "$rp"
    else
        wp="$(which "$fp")"
        if test "$?" -eq 0; then
            printf -- "%s\n" "$wp"
        fi
    fi
done

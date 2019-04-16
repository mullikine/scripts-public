#!/bin/bash
export TTY

awk 1 | while IFS=$'\n' read -r line; do
    fn=$(basename "$line")
    ext="${fn##*.}"
    mant="${fn%.*}"

    printf -- "%s\n" "$mant"
done

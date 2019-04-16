#!/bin/bash
export TTY

last_arg="${@: -1}"

if ! [ -n "$last_arg" ]; then
    echo "provide a path or url to a html file or page"
    exit 1
fi

wget --spider --force-html -i "$@"

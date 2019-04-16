#!/bin/bash
export TTY

fp="$1"

long_lines="$(perl -nle 'print if length$_>100' "$fp")"
test -n "$long_lines"
ret="$?"

if ! test "$?" -eq "0"; then
    echo "long lines: $long_lines"
fi

exit "$ret"
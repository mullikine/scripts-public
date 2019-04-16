#!/bin/bash
export TTY

# This gets a global variable

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    "") { shift; }; ;;
    -q) {
        QUERY_ONLY=y
        shift
    }
    ;;

    *) break;
esac; done

varname="$1"
varname="$(printf -- "%s" "$varname" | slugify)"

if [ -z "$varname" ]; then
    exit 0
fi

vars_dir="$NOTES/vars"
mkdir -p "$vars_dir"

fp="$NOTES/vars/$varname"

if [ -s "$fp" ]; then
    if test "$QUERY_ONLY" = "y"; then
        echo "$fp"
    else
        cat "$fp"
    fi
else
    {
        echo "Not found:" 
        echo "$fp" 
    } 1>&2
fi

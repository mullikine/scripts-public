#!/bin/bash
export TTY

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -f) {
        expression="$2"
        shift
        shift
    }
    ;;

    *) break;
esac; done

: ${expression:="q"}

if test "$#" -eq 0; then
	exit 0
fi

printf -- "%s" "$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    if test -z "$ARG"; then
	    printf '""'
    else
	    printf -- "%s" "$ARG" | eval "$expression"
    fi
    printf ' '
done
eval ARG=\${$i}
if test -z "$ARG"; then
    printf '""'
else
    printf -- "%s" "$ARG" | eval "$expression"
fi
)"

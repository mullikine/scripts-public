#!/bin/bash
export TTY

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    printf -- "%s" "$ARG" | q
    printf ' '
done
eval ARG=\${$i}
printf -- "%s" "$ARG" | q
)"

cmd="/usr/bin/clojure $CMD"

eval "$cmd"
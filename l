#!/bin/bash
export TTY

# Script for locating things

# examples
# l -u l -r 'wikifil.pl'

METHOD=locate

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -u|u) {
        sudo updatedb
        shift

        [ $# -eq 0 ] && exit 0
    }
    ;;

    *) break;
esac; done

opt="$1"
case "$opt" in
    l) { METHOD=locate; shift; } ;;
    r) {
        METHOD=locate;
        shift;

        set -- -r "$@" # This properly preserves quotes
    } ;;
    *)
esac

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    aq "$ARG"
    printf ' '
done
eval ARG=\${$i}
aq "$ARG"
)"

case "$METHOD" in
    locate) {
        eval "/usr/bin/locate $CMD"
    }
    ;;

    *)
esac

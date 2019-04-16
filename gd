#!/bin/bash
export TTY

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    "") { shift; }; ;;
    -e) {
        v ~/.strings.sh
        exit 0
        shift
    }
    ;;

    *) break;
esac; done

varname="$1"
shift

source ~/.strings.sh

eval "printf -- \"%s\" \"\$$varname\""

# OLD # This will cd to the repo and then diff it
# OLD # This script is just shorthand for "g d" (git diff)
# OLD # Although, in future it could also be about graphics
# OLD # g d "$@"
#!/bin/bash
export TTY

# I'm not sure yet what 'g' should be for.

# Google? General? Global? Git?

# Maybe a combination of all of these things, depending on the
# combination.

# External search? And application.

# This file should be about 'global' things.
# Run commands that affect lots of things ?

# For all things gui look at 'win' instead.

opt="$1"
shift

case "$opt" in
    s|search) {
        googler "$@"
    }
    ;;

    chrome) {
        :
    }
    ;;

    d) { # git/vc diff
        vc d "$@"
    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac

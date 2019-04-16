#!/bin/bash
export TTY

last_arg="${@: -1}"

opt="$1"
case "$opt" in
    list) {
        # Suppress messages for emacs
        # M-m m i a
        exec 2>/dev/null # this has no effect when ci is used because ci redirects to &1

        ci quiet /usr/local/go/bin/go "$@" "$url"
        exit 0
    }
    ;;

    get) {
        url="$last_arg"
        set -- "${@:1:$(($#-1))}" # shift last arg

        url="$(p "$url" | sed 's=^https\?://==')"
        url="$(p "$url" | sed 's=#.*$==')"

        /usr/local/go/bin/go "$@" "$url"
        exit 0
    }
    ;;

    *)
esac

/usr/local/go/bin/go "$@"
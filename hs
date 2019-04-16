#!/bin/bash
export TTY

# Add a sort -k to this

# This script creates logs of things
# Should be used to both record the history and to query the history

topdir="$HOME/notes/programs/hs"
mkdir -p "$topdir"

if [ -z "$1" ]; then
    # help
    wfind "$topdir" | xargs -l1 basename

    exit 0
fi

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    "") { shift; }; ;;
    -q) {
        IS_QUERY=y
        shift
    }
    ;;

    *) break;
esac; done


CMD="$(cmd "$@")"
parameters="$CMD"

category="$1"
dir="$topdir/$category"
shift

if test "$IS_QUERY" = "y"; then
    echo "$dir"
    exit 0
fi

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

sn="$(basename "$0")"
case "$sn" in
    hsq) {
        if ! test -d "$dir"; then
            echo "$sn: $dir does not exist" 1>&1
            exit 1
        fi

        wfind "$dir" | sort -n -t . -k3,3 -k2,2 -k1,1 | {
            if is_tty; then
                ifilter
            else
                cat
                # sync
            fi
        }
        
        # query the history
        exit 0
    }
    ;;

    *)
esac

stdin_exists() {
    ! [ -t 0 ]
}

if stdin_exists; then
    content="$(cat)"
fi

mkdir -p "$dir"
wd="$(pwd)"

cd "$dir"
fp="$dir/$(date +%d.%m.%y).sh"

(
printf -- "%s" "cd "$(aqf "$wd")"; "

    if [ -n "$content" ]; then
        content="$(p "$content" | qne)"
        printf -- "%s" "lit \"$content\" | "
    fi

    # This include the category
    printf -- "%s" "$parameters"

    #printf -- "%s" "$category"

    #if [ -n "$parameters" ]; then
    #    printf -- "%s" " $parameters"
    #fi
    echo
) &>/dev/null >> "$fp"

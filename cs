#!/bin/bash
export TTY

# Everything to do with code search

opt="$1"
shift
case "$opt" in
    g|google) {
        LITERAL=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -l) {
                LITERAL=y
                shift
            }
            ;;

            *) break;
        esac; done

        ext="$1"

        # IFS= read -rd '' input < <(cat /dev/stdin)
        # I don't want trailing newlines

        input="$(cat)"

        # If not a tty but TTY is exported from outside, attach the tty
        if test "$mytty" = "not a tty" && ! [ -z ${TTY+x} ]; then
            lit "Attaching tty"
            exec 0<"$TTY"
            exec 1>"$TTY"
        else
            # Otherwise, this probably has its own tty and only needs normal
            # reattachment (maybe stdin was temporarily redirected)
            exec </dev/tty
        fi

        if test "$LITERAL" = "y"; then
            input="$(p "$input" | q -ftln)"
        fi

        if [ -n "$ext" ]; then
            gr -n 5 -- "$input" "filetype:$ext"
        else
            gr -n 5 -w github.com -- "$input"
        fi
    }
    ;;

    rc|rosetta-code) {
        CMD="$(
        for (( i = 1; i < $#; i++ )); do
            eval ARG=\${$i}
            printf -- "%s" "$ARG" | q
            printf ' '
        done
        eval ARG=\${$i}
        printf -- "%s" "$ARG" | q
        )"

        cd "$HOME$MYGIT/acmeism/RosettaCodeData"; eval "eack -d 5 \"$CMD\""
    }
    ;;

    sc|searchcode) {
        input="$(cat)"
        lit "$input" | searchcode | less
    }
    ;;

    gh|github) {
        # pipe into this
        gh search
        # IFS= read -rd '' input < <(cat /dev/stdin)
        # lit "$input" | gh search
    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac

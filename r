#!/bin/bash

# remember: $HOME/scripts/nix 
# This file is where I should put commands that ranger hotkeys link to
# e.g. Deleting and copying paths
# I can therefore use this script with other programs such as dired or
# org-mode

# dp - delete path/s
# yp - yank path/s

cmd="$1"

# tm -tout nw v
# notify-send hi
# exit 0

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

pager() {
    if is_tty; then
        v
    else
        cat
    fi
}

is_multiline() {
    NL="\n"
    case "$1" in
      *"$NL"*) true ;;
            *) false ;;
    esac
}

line_deliminate() {
    input="$(cat)"
    # xargs is actually a limiting factor with %s
    linedelimited="$(lit "$input" | xargs lit)"
    lit "$linedelimited"

    return 0
}

# ranger's %s
# %s doesn't work well
from_s() {
    # line_deliminate | 
    ( xargs -L 20 printf -- '%s\n' ) | sed "s#^#$(pwd)/#"

    # line_deliminate | sed "s#^#$(pwd)/#"

    return 0
}

if [ $# -eq 0 ]; then
    ranger
    exit 0
fi

export FAST=y
case "$cmd" in
    t|tree) {
        # If I put tout here I don't need unbuffer here: map t shell -f
        # unbuffer r tree

        tm -tout spv "tree | less"
    }
    ;;

    e|edit) {
        tm -S nw "tm -S split \"v $HOME/.config/ranger/rifle.conf\"; v $HOME/.config/ranger/rc.conf"
    }
    ;;

    tp) { # excects list of paths. Path as appears.
        path="$(from_s | umn | nix -t logtee tp | soak)"

        p "$path" | tm tp
        # tm -d nw -fa open "$path"
    }
    ;;

    ts) { # excects list of paths. Path as appears.
        path="$(from_s | umn | nix -t logtee tp | soak)"

        tm -d sph -fa open "$path"
    }
    ;;

    th) { # excects list of paths. Path as appears.
        path="$(from_s | umn | nix -t logtee tp | soak)"

        tm -d spv -fa open "$path"
    }
    ;;

    yp) { # excects list of paths. Path as appears.
         # | nix -t logtee yp 
        from_s | umn | ns | soak | nix -t logtee yp | xc -n
        # from_s | ns | xc
        # soak | xc
    }
    ;;

    yg) { # yank git
        from_s | umn | soak | nix -t logtee yg | xa git-file-to-url | xc -n -i
    }
    ;;

    yP|YP) { # excects list of paths. copies as arguments
        from_s | umn | ns | soak | nix -t logtee yp | qargs | xc -n
    }
    ;;

    yap) { # excects list of paths. Path as appears.
        # Don't use xc here because we appending
        from_s | umn | nix -t logtee yp | soak | xc -a
        # soak | xc
    }
    ;;

    yr) { # excects list of paths. Real/Canonical path
        from_s | tp vipe | ( mnm | nix -t logtee yp | umn ) | nix rp | ( mnm | tp vipe | xc -n )
    }
    ;;

    yd) { # excects list of paths. converts file paths to parent dir
        #from_s | mnm | wrl q | xargs -I {} -L1 dirname "{}" | s uniq | xc
        from_s | umn | s chomp | wrl q | xargs -L1 dirname | s uniq | xc -n

        # from_s | mnm | s uniq | xc

        # This is too slow
        # from_s | ( mnm | nix -t logtee yd | umn ) | ( nix rp ) | (
        #     input="$(cat)"
        #     lines="$(lit "$input" | wc -l)"

        #     if test "$lines" -eq 1; then
        #         # tm dv "$input"
        #         # tm dv "$lines"

        #         lit "$input" | awk 1 | xargs -l1 dirname | mnm | xc
        #     else
        #         lit "$input" | nix dn | mnm | tp vipe | xc
        #     fi
        # )
    }
    ;;

    yF|yB) {
        from_s | umn | xargs -L1 basename | ns | soak | nix -t logtee yp | qargs | xc -n
    }
    ;;

    # Dirname basename
    yD) {
        from_s | umn | xargs -L1 dirname | xargs -L1 basename | ns | soak | nix -t logtee yp | qargs | xc -n
    }
    ;;

    yf|yb) { # excects list of paths. copy the filename only
        # This should only open vim if there is only 1 line

        IFS= read -rd '' paths < <(from_s | umn | xargs -L1 basename | ns | soak | nix -t logtee yp)

        # Don't trim if it's multiline
        # TODO This isn't working though. It's always trimming
        if is_multiline "$paths"; then
            ns "It's multiline!"
            printf -- "%s" "$paths" | xc
        else
            printf -- "%s" "$paths" | xc -n
        fi

        # from_s | mnm | s chomp | wrl q | xargs -L1 basename | s uniq | s chomp | xc

        # from_s | ( mnm | nix -t logtee yf | umn ) | nix bn | (
        #     input="$(cat)"
        #     lines="$(lit "$input" | wc -l)"

        #     # tm dv "$lines"

        #     if test "$lines" -eq 1; then
        #         lit "$input" | mnm | xc
        #     else
        #         lit "$input" | mnm | tp vipe | xc
        #     fi
        # )
    }
    ;;

    yt) { # excects list of files or paths and puts into vim
        # exec 1>&-
        
        # input="$(cat)"
        # ns "$(tty)" # This isn't a tty when run from 
        
        # printf -- '%s\n' "$input" | tm -tout nw "vim -"

        from_s | ( mnm | nix -t logtee yd | umn ) | nix rp | nix dn | xc

        tm -tout nw -n "ranger copy test" v
        #printf -- "%s\n" "$input" | line_deliminate | nix -t logtee yt | tm -tout nw v
    }
    ;;

    preview) {
        shift

        $HOME/versioned/git/config/ranger/scope.sh "$@" | pager
    }
    ;;

    dp) { # excects list of paths
        dirs="$(
        from_s | awk 1 | while IFS=$'\n' read -r line; do
            if [ -f "$line" ]; then
                rm -f "$line"
            else
                lit "$line"
            fi
        done; )"

        if [ -n "$dirs" ]; then
            lit "$dirs" | tm -tout nw "nix dp"
        fi
        #from_s | nix -t logtee dp | yn "Really delete?" && tm -tout nw "vim -"
        # from_s | nix -t logtee dp | tm -tout nw -n "ranger copy test" v
        # exit 0

        #from_s | nix -t logtee dp | tm -tout nw -pakf "nix dp"
        #from_s | tm -tout nw -pakf "nix dp"
        # from_s | tm -tout nw "nix dp"
    }
    ;;

    open) {
        open "$1"
    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac

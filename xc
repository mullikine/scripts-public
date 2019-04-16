#!/bin/bash

export DISPLAY=:0

set -m

# -silent does nothing
# I want to suppress this
# Error: target STRING not available
# 2>/dev/null works

# exec 2>/dev/null

#(
#while [ $# -gt 0 ]; do; opt="$1"; case "$opt" in
#    -r) {
#        register="$2"
#
#        tf_register="$(nix tf register || echo /dev/null)"
#        shift
#        shift
#    }
#    ;;
#
#    *) break;
#esac; done
#) 0</dev/null


#trap func_trap HUP
#func_trap() {
#}

input=

tag=
NOTIFY=n
FORCE_OUT=n
MINIMISE_IT=n
UNMINIMISE_IT=n
APPEND=n
TRIM=n
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -p) {
        USE_PAGER=y
        shift
    }
    ;;

    -ub) {
        shift
        unbuffer $0 "$@"
        exit $?
    }
    ;;

    -i) {
        NOTIFY=y
        shift
    }
    ;;

    -t) {
        tag="$2"
        shift
        shift
    }
    ;;

    -a) {
        APPEND=y
        shift
    }
    ;;

    -) {
        FORCE_OUT=y
        shift
    }
    ;;

    -n) {
        # This should work for both when setting the clipboard and when
        # retrieving it
        TRIM=y
        shift
    }
    ;;

    -m) {
        MINIMISE_IT=y
        shift
    }
    ;;

    -u) {
        UNMINIMISE_IT=y
        shift
    }
    ;;

    -s) {
        SILENT=y
        shift
    }
    ;;

    *) break;
esac; done

# IFS= read -rd '' input < <(timeout 0.1 cat /dev/stdin)
# exec < <(printf -- "%s" "$input")

## This works. Actually, it breaks yp.
#stdinexists() {
#    IFS= read -t0.1 -rd '' input < <(cat /dev/stdin)
#    exec < <(printf -- "%s" "$input")
#    [ -n "$input" ]
#}

# This is actually if it's a terminal or not
# This breaks typeclip in tm
stdinexists() {
    ! [ -t 0 ]
}

# This breaks yp in ranger
#stdinexists() {
#    ! [ -t 0 ] && read -t 0.1
#}

## This works more often. But often misses the first line of input. Once
## it's read it can't be prepended to stdin. So this won't work.
#stdinexists() {
#    ! [ -t 0 ] && read -t 0.1 $line
#}

# Keep in mind that when I get the following error:
# Error: target STRING not available
# That just means that the clipoard is empty. It happens when you clear
# explicitly also.
# xsel -c

# tf_in=/tmp/cliptest.txt
# tf_in="$(nix tf in || echo /dev/null)"
# trap "rm \"$tf_in\" 2>/dev/null" 0

copytoboth() {
    # cat > "$tf_in"

    # IMPORTANT
    # I was correct
    # It's not a problem with the script. 
    # It's a bug in xsel causing frozen pasting in vim.
    # Use xclip instead

    # DISCARD -- still having problems
    # Interestingly, this works well when I have a temporary file but is
    # prone to errors in copying, adding control and null characters in
    # long input such as when copying ranger paths, when I copy stdin to
    # a variable.

    #input="$(cat)"
    # xsel -i
    # return 0
    IFS= read -rd '' input < <(cat /dev/stdin)

    # xclip -i

    #printf -- "%s" "$input" $'\0' | buffer | xsel -i # null byte does not fix the issue


    # xsel has a bug. Use xclip.
    ##cat "$tf_in" | xsel -i
    # cat "$tf_in" | xclip -i
    ##cat "$tf_in" | xsel -i -b | tmux load-buffer -
    # cat "$tf_in" | xclip -i -selection clipboard | tmux load-buffer -

    # xclip hangs if it doesn't use -f

    # printf -- "%s" "$input" | buffer | xsel -i
    printf -- "%s" "$input" | ( xclip -i -f &>/dev/null ) & disown

    # printf -- "%s" "$input" | buffer | xsel -i -b | tmux load-buffer -
    printf -- "%s" "$input" | ( xclip -i -selection clipboard -f | tmux load-buffer - ) & disown

    if [ -n "$tag" ]; then
        mkdir -p "$NOTES/clipboard/"
        printf -- "%s" "$input" | awk 1 >> "$NOTES/clipboard/${tag}.txt"
    else
        # -f is needed if I'm going to pipe
        printf -- "%s" "$input" | awk 1 >> $NOTES/clipboard.txt
    fi

    # xclip -f -i -selection primary &>1 | tmux load-buffer -
}

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

is_stdout_pipe() {
    # If stout is a pipe
    [[ -p /dev/stdout ]]
}

if test "$1" = "min"; then
    MINIMISE_IT=y
fi

if test "$1" = "umn"; then
    UNMINIMISE_IT=y
fi

if test "$1" = "notify"; then
    NOTIFY=y
fi

if test "$SILENT" = "y"; then
    exec &>/dev/null
fi

if stdinexists; then
    # Read without losing trailing newlines
    IFS= read -rd '' input < <(cat /dev/stdin)

    if test "$APPEND" = "y"; then
        IFS= read -rd '' old < <(xc)
        # old="$(xc)"
        input="$old$input"
    fi

    # printf -- "%s" "$input"
    # exit

    if test "$TRIM" = "y"; then
        input="$(printf -- "%s" "$input" | s chomp)"
    fi
    if test "$MINIMISE_IT" = "y"; then
        input="$(printf -- "%s" "$input" | mnm)"
    fi
    if test "$UNMINIMISE_IT" = "y"; then
        input="$(printf -- "%s" "$input" | umn)"
    fi
    if test "$NOTIFY" = "y"; then
        ns "$input" &>/dev/null
    fi
    printf -- "%s" "$input" | copytoboth

    if test "$USE_PAGER" = "y" || test "$FORCE_OUT" = "y" || is_stdout_pipe; then
        if test "$USE_PAGER" = "y"; then
            printf -- "%s" "$input" | pager
        else
            printf -- "%s" "$input"
        fi
    fi
else
    if [ -n "$tag" ]; then
        mkdir -p "$NOTES/clipboard/"
        xclip -o 2>/dev/null | awk 1 >> "$NOTES/clipboard/${tag}.txt"
    else
        xclip -o 2>/dev/null | awk 1 >> $NOTES/clipboard.txt
    fi

    {
        if test "$TRIM" = "y"; then
            xclip -o 2>/dev/null | soak | s chomp
        else
            xclip -o 2>/dev/null
        fi
    } | {
        if test "$USE_PAGER" = "y"; then
            pager
        else
            cat
        fi
    }
fi

# if target STRING not available
if [ $? -ne 0 ]; then
    printf -- "%s" "" | copytoboth
fi

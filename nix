#!/bin/bash

# must be bash and not zsh
source $HOME/scripts/u.f.sh

# Also known as 'u'

# export the TTY into this. That way it can accept input and then
# redirect output to the tty.
# echo "$TTY"

# Related:
# $HOME/scripts/tp
# $HOME/scripts/r

# notify-send "$SHELL"
# exit 0

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -f) {
        FAST=y
        shift
    }
    ;;

    *) break;
esac; done
export FAST


while getopts -- tv name &>/dev/null; do
case $name in
    t)  TIMESTAMP=y;;
    v)  set -xv;;
    *)  ((OPTIND--)); break ;;
esac
done
shift "$((OPTIND-1))"
OPTIND=1


stdin_exists() {
    # this makes it so the first key pressed in the terminal is a
    # dead key. it's broken
    # IFS= read -t0.1 -rd '' input < <(cat /dev/stdin)
    # exec < <(printf -- "%s" "$input")
    # [ -n "$input" ]

    ! [ -t 0 ]
    # ! [ -t 0 ] && read -t 0
}


cmd="$1"
shift

filter() {
    if test "$TIMESTAMP" = "y"; then
        ts
    else
        cat
    fi

    return 0
}

case "$cmd" in
    p) # print
        printf -- "%s" "$1"
    ;;

    delete-temp-files|free-space) {
        set -v
        # Delete temporary files

        # Not sure if deleting the .cache/bazel directory removes
        # application files
        rm -rf ~/.cache/bazel/_bazel_shane
    }
    ;;

    mt|mimetype) # 
        # u mt "notes.txt"

        mt "$@"
    ;;

    lx|list-executables)
        list-executables "$1"

        # Examples
        # u lx $HOME/scripts:$HOME/local/bin
        # u lx $HOME/scripts:$HOME/local/bin
    ;;
    

    rp)
        # u nodirsuffix | xargs --no-run-if-empty -l1 realpath | u dirsuffix

        u nodirsuffix | awk 1 | while read -r line; do
            realpath "$line"
        done | u dirsuffix
    ;;

    ext)
        if test "$FAST" = "y"; then
            sed -n 's/.*\(\.[^.]\+\)$/\1/p'
        else
            u bn | sed -n 's/.*\(\.[^.]\+\)$/\1/p'
        fi
    ;;

    find-latest-files) {
        find . -type f -printf "%C@ %p\n" | sort -rn | head -n 10
    }
    ;;

    tf|mktemp|nf|new-file|nt|ntf|named-tf) { # Named temporary file
        template="$1"; : ${template:="tmp"}
        ext="$2"; : ${ext:="bin"}
        dir="$3"
        test -n "$dir" && export TMPDIR="$dir"
        
        mktemp -t "file_${template}_XXXXXX_rand-${RANDOM}_pid-$$.$ext"
    }
    ;;

    ff|mkfifo) {
        template=$1; : ${template:="tmp"}
        tmpfifo_name="$(mktemp -u -t "fifo_${template}_XXXXXX_rand-${RANDOM}_pid-$$")";
        mkfifo "$tmpfifo_name"
        lit "$tmpfifo_name"
    }
    ;;

    logtee) {
        name="$1"

        if [ -z "$name" ]; then
            name=tmp
        fi
        
        slogdir="$LOGDIR/$name"
        mkdir -p  "$slogdir"
        
        fp="$slogdir/$(date-ts).log"
        # lit "$fp" >&2

        tee >(filter >> "$fp")
    }
    ;;

    is-executable|isx) {
        fp="$1"
        getfacl "$1" 2>/dev/null | grep user:: | grep -q x
        exit $?
    }
    ;;

    # It casts, so call it that
    dn|drn|dirname|cast-dirname) {
        # awk 1 | xargs --no-run-if-empty -l1 dirname; exit # This way is more stable

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -f) {
                FORCE_DIRNAME=y
                shift
            }
            ;;

            *) break;
        esac; done

        awk 1 | u nodirsuffix | while read -r line; do
            dirtest="$(p "$line" | umn)"

            # tm -te dv "$dirtest"
            # exit 0
            # lit "$dirtest" | tv

            if test -d "$dirtest" && ! test "$FORCE_DIRNAME" = "y"; then
                lit "$line"
            else
                newpath="$(dirname "$dirtest")"
                if [ -d "$newpath" ]; then
                    lit "$newpath"
                fi
            fi
        done
        exit 0
    }
    ;;

    mkimmutable) {
        sudo chattr +i -V "$@"
    }
    ;;

    ummkimmutable) {
        sudo chattr -i -V "$@"
    }
    ;;

    fn|bn) {
        # I don't know how to use parallel
        # awk 1 | parallel 'ext="{/}" ; mv -- {} foo/{/.}.bar.${ext##*.}'

        # awk 1 | xargs --no-run-if-empty -l1 basename

        # I just want something that works with lines that have spaces.

        awk 1 | while read -r line; do
            basename "$line"
        done
    }
    ;;

    wn|wrn|whichname) {
        awk 1 | while read -r line; do
            newpath="$(which "$line")"
            if test $? -eq 0; then
                lit "$newpath"
            else
                lit "$line"
            fi
        done
    }
    ;;

    ks|kill-string) {
        string="$1"
        ps -ef | grep "$string" | grep -v grep | s c 2 | xargs --no-run-if-empty kill
    }
    ;;

    nodirsuffix) { # Ensures final / is removed but not if it's /
        awk 1 | sed 's/\(.\)\/\+$/\1/'
    }
    ;;

    lgpe|list-grep-process-environments) { # Can search through all processes' environments.
        # lit "$(u list-grep-process-environments $(:) | fzf -m)" | vim -
        # u list-grep-processes SPACE

        COLUMNS=10000 ps -ef e |grep -i "$1"
    }
    ;;

    ps) { # ps needs some defaults
        COLUMNS=10000 ps "$@"
        exit 0
    }
    ;;

    append-histfile) {
        input="$(cat)"
        # $HOME/notes2018/programs/hs
    }
    ;;

    lgpe-fzf-vim) {
        tm nw "lit \"$(u list-grep-process-environments $(:) | fzf -m)\" | vim -"
    }
    ;;

    dirsuffix) { # Ensures directories and only directories (excluding symbolic links) show a slash at the end
        awk 1 | sed 's/\/\+$//' | while read -r line; do
            testline="$(lit "$line" | umn)"
            if ! [ -h "$testline" ] && [ -d "$testline" ]; then
                lit "$line/"
            else
                lit "$line"
            fi
        done
    }
    ;;

    rmdirsuffix) {
        sed 's/\/$//'
    }
    ;;

    dp|delete-paths) {
        # This is a simply alias. Put terminal programs into tp
        tp dp
    }
    ;;

    when-cd) {
        . $HOME/scripts/libraries/when-cd.sh
    }
    ;;

    dirinfo) {
        tm n "$f :: NOT IMPLEMENTED"

        # Describe a directory.

        # Need:
        # Frequency of file paths

        # Perform some kind of statistical analysis on all the stuff and
        # put it into a database of some kind.

        # Use python mainly

        # dirinfo.sh
    }
    ;;

    getprefix) {
        if stdin_exists; then
            args="$(qargs)"
            export -f longest_common_prefix
            
            # printf -- "%s\n" $args | parallel longest_common_prefix
            printf -- "%s\n" $args | xargs longest-common-prefix
            # printf -- "%s\n" "$args" | parallel longest_common_prefix
             # | xargs -n 1 -P 10 -I {} bash -c 'echo_var "$@"' _ {}
        else
            longest-common-prefix "$@"
        fi
    }
    ;;

    *)
        cat
esac

#!/bin/bash

. $HOME/scripts/libraries/bash-library.sh

# Use vim 8.0
# 8.0 has much slower syntax rendering
bin="$(which "vim")"
# bin="/usr/local/bin/vim"

# No-op
extra_commands="silent! echom"

ANSI=n
bn="$(basename "$0")"
case "$bn" in
    avim|ansivim) {
        ANSI=y
    }
    ;;

    *)
esac

# If this is '' then it's allowed to be decided. If it's n or y then
# it's final
GLOBAL_SYNTAX_HIGHLIGHTING=
NOAUTOCHDIR=
LOCATE_IT=
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    "") { shift; }; ;;
    -p) {
        bin="vimpager"
        shift
    }
    ;;

    -2) {
        export TERM=screen-2color
        shift
    }
    ;;

    -l) {
        LOCATE_IT=y
        shift
    }
    ;;

    -ka|-kill-all) {
        {
            ps -ef | grep -P "[0-9][0-9]:[0-9][0-9]:[0-9][0-9] vim" | grep -v grep
            ps -ef | grep "/local/bin/vim$" | grep -v grep
            ps -ef | grep -P "\b/scripts/v\b" | grep -v grep
            ps -ef | grep "/local/bin/vim -c" | grep -v grep
        } | field 2 | xargs kill
        exit 0
    }
    ;;

    -d) { # vimdiff
        bin="vd"
        shift
    }
    ;;

    -compile) {
        cd $HOME/source/git/vim-ace

        ./configure --prefix=$HOME/local --with-features=huge --enable-cscope --enable-multibyte --with-x --enable-rubyinterp=yes --enable-perlinterp=yes --enable-pythoninterp=yes

        # I have to choose between
        # --enable-pythoninterp=yes
        # --enable-python3interp=yes
        # I have chosen python2

        make -j8
        sudo make install
        exit 0
    }
    ;;

    -nc|-nocolor) {
        extra_commands+="|hi Normal term=NONE ctermbg=NONE ctermfg=NONE"
        shift
    }
    ;;

    -ns|-noswap) {
        extra_commands+="|set noswapfile"
        shift
    }
    ;;

    -ft) {
        extra_commands+="|set ft=$2"
        shift
        shift
    }
    ;;

    -rt) {
        rt_cmd="$2"
        # rt_cmd="$(p "$rt_cmd" | esc '$')"
        extra_commands+="|call RTCmdSetup($(aqf "$rt_cmd"))"
        # echo "$extra_commands" > /tmp/extra_commands.txt
        shift
        shift
    }
    ;;

    -nad|-noautochdir) {
        NOAUTOCHDIR=y
        shift
    }
    ;;

    -a|-A|-ansi) {
        ANSI=y
        shift
    }
    ;;

    -s) {
        GLOBAL_SYNTAX_HIGHLIGHTING=y
        shift
    }
    ;;

    -nsyn) {
        GLOBAL_SYNTAX_HIGHLIGHTING=n
        shift
    }
    ;;

    +*:*) {
        GOTO_LINE="$(p "$opt" | mcut -d'[+:]' -f2)"
        GOTO_COLUMN="$(p "$opt" | mcut -d'[+:]' -f3)"

        shift
    }
    ;;

    +[0-9]*) {
        GOTO_LINE="$(p "$opt" | mcut -d+ -f2)"
        shift
    }
    ;;

    +/*) { # pattern
        pattern="$(p "$opt" | mcut -d+/ -f2 | s chomp)"

        shift
    }
    ;;

    +*) {
        normal_commands+="$(p "$opt" | sed 's/^.//' | s chomp | qne)"
        shift
    }
    ;;

    *) break;
esac; done

if [ -n "$normal_commands" ]; then
    normal_commands="$(p "$normal_commands" | qne | qne)"
    opts+=" -c $(aqf "normal $normal_commands") "
fi

if [ -n "$GOTO_LINE" ] && test -n "$GOTO_COLUMN"; then
    # GOTO_COLUMN="$(a- bc "$GOTO_COLUMN + 1")"

    GOTO_COLUMN="$(a- "awk 1 | bc" "$GOTO_COLUMN + 1")"

    opts+=" -c $(aqf "cal cursor($GOTO_LINE, $GOTO_COLUMN)") "
elif [ -n "$GOTO_LINE" ]; then
    opts+=" -c $(aqf "exe $GOTO_LINE") "
fi

if [ -n "$pattern" ]; then
    # this only goes to the line, not the column
    # opts+=" -c \"silent! /$pattern\" "


    ncmd="/$pattern"
    ncmd="$(p "$VAR" "normal! $ncmd" | qne)"
    ncmd="$(p "$VAR" "exe \"$ncmd\r\"" | q)"
    opts+=" -c $ncmd "

    # opts+=" -c $(a- q "exe $(a- qne "normal! $(a- q "/$pattern")")\r") "
    # lit " -c $(a- q "exe $(a- q "normal! $(a- q "/$pattern")")\r") " | tv &>/dev/null
fi

last_arg="${@: -1}"
ext="${fp##*.}"

bn="$(basename "$fp")"

# if test "$ext" = "clql" || test "$ext" = "yaml"; then
#     if yn "Use highlighing?"; then
#         extra_commands+="|call GeneralSyntax()|au BufEnter * call GeneralSyntax()"
#     fi
# fi

if test "$GLOBAL_SYNTAX_HIGHLIGHTING" = "y" || { test "$GLOBAL_SYNTAX_HIGHLIGHTING" = "" && { test "$bn" = "glossary.txt" || test "$ext" = "clql"; }; }; then
    extra_commands+="|silent! call GeneralSyntax()|au BufEnter * call GeneralSyntax()"
fi

if test "$ANSI" = "y"; then
    extra_commands+="|AnsiEsc"
fi

if test "$NOAUTOCHDIR" = "y"; then
    extra_commands+="|set noautochdir"
fi

# not sure where foldcolumn=2 is coming from
# cd "$HOME$VIMCONFIG"; eack -d 10 foldcolumn=2
# extra_commands+="|set foldcolumn=0"

# lit "$cmd"
# exit 0


# exec </dev/tty
#
# if ! stdout_capture_exists; then
#     exec </dev/tty
# else
#     echo yo
# fi

CMD="$(cmd "$@")"

cmd=" -c $(aqf "$extra_commands") $opts $CMD"

if stdin_exists; then
    input="$(cat)"

    printf -- "%s\n" "$input" | eval "$bin $cmd -"

    # printf -- "%s\n" "$input" | eval "$bin -"
    exit $?
fi

if test "$LOCATE_IT" = "y"; then
    w="$(locate "$1" | head -n 1)"
    r="$?"

    if [ "$r" -eq 0 ]; then

        shift

        # Recalculate after removing

        CMD="$(cmd "$@")"

        cmd=" -c $(aqf "$extra_commands") $opts $CMD"

        # $bin "$w"
        # echo "$bin $cmd $w"
        eval "$bin $cmd $w"
    fi
    exit $?
fi

if [ $# -eq 1 ]; then
    if ! [ -f "$1" ]; then
        w="$(which "$1")"
        r="$?"

        if [ "$r" -eq 0 ]; then

            shift

            # Recalculate after removing

            CMD="$(cmd "$@")"

            cmd=" -c $(aqf "$extra_commands") $opts $CMD"

            # $bin "$w"
            # echo "$bin $cmd $w"
            cmd="$bin $cmd $w"
        else
            last_arg="${@: -1}"
            fp="$last_arg"
            
            if pl "$fp" | grep -q -P ':[^/].*$'; then
                fp="$(p "$last_arg" | cut -d : -f 1)"
                GOTO_LINE="$(p "$last_arg" | cut -d : -f 2)"
                GOTO_COLUMN=0
                opts+=" -c $(aqf "cal cursor($GOTO_LINE, $GOTO_COLUMN)") "
            fi

            ext="${fp##*.}"
            fn="${fp%.*}"

            if printf -- "%s\n" "$last_arg" | grep -q -P '^file:///'; then
                last_arg="$(printf -- "%s" "$last_arg" | replace 'file://' '')"
                set -- "${@:1:$(($#-1))}" # shift last arg
                set -- "$@" "$last_arg"

                cmd="$(cmd "$@")"

                # lit "$cmd" | tv &>/dev/null
            fi

            if lit "$last_arg" | grep -q -P '^http.?://github.com'; then
                gc -notty "$last_arg" &>/dev/null
                last_arg="$(p "$last_arg" | sed "s=^http.\?://github.com=$MYGIT=" | sed "s=/\(blob\|tree\)/[a-z]\+==")"
                set -- "${@:1:$(($#-1))}" # shift last arg

                CMD="$(cmd "$@")"

                cmd=" -c $(aqf "$extra_commands") $opts $CMD"

                cmd="$bin $cmd $last_arg"
            else
                if lit "$last_arg" | grep -q -P '^http.?:'; then
                    tf_webpage="$(make-path-for-uri "$last_arg")"

                    set -- "${@:1:$(($#-1))}" # shift last arg

                    CMD="$(cmd "$@")"

                    cmd=" -c $(aqf "$extra_commands") $opts $CMD"

                    cmd="$bin $cmd $tf_webpage"
                else
                    # set -- "${@:1:$(($#-1))}" # shift last arg
                    # CMD="$(cmd "$@")"
                    # echo "$bin $cmd $opts $fp"
                    # exit 0

                    cmd="$bin $cmd $opts $fp"
                fi
            fi
        fi
    else
        # $1 is evidently a file. so find the real path
        rp="$(realpath "$1")"
        shift

        CMD="$(cmd "$@")"

        cmd=" -c $(aqf "$extra_commands") $opts $CMD"

        # lit "$bin $cmd"
        cmd="$bin $(aq "$rp") $cmd"
    fi
else
    cmd=" -c $(aqf "$extra_commands") $opts $CMD"

    # lit "$bin $cmd"
    # eval "$bin $(aq "$rp") $cmd"

    cmd="$bin $cmd"
fi

# echo "$cmd" 1>&2
eval "$cmd"

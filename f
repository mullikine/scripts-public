#!/bin/bash
export TTY

# See also: 'F' find commands

# Filter commands

# This should take care of:
# fzf
# tmux-capture

# TODO f should be filter
# TODO F should be find

# Need
# - Find non-binary files
# - Find binary files (binary != executable)

# If stout is a tty
is_stdout_tty() {
    [[ -t 1 ]]
}

stdin_exists() {
    ! [ -t 0 ]
}

sn="$(basename "$0")"
case "$sn" in
    ffzf) {
        opt=filter-with-fzf
    }
    ;;

    *) {
        opt="$1"
        shift
    };;
esac

HAS_STDIN=
if stdin_exists; then
    HAS_STDIN=y
    tf_input="$(nix tf input || echo /dev/null)"
    trap "rm \"$tf_input\" 2>/dev/null" 0
fi

case "$opt" in
    cat|cat-file)
        file="$1"
        cat "$file"
    ;;

    filter-things) {
        fp="$1"

        if test "$HAS_STDIN" = "y"; then
            cat > "$tf_input"
        fi

        if ! [ -f "$fp" ] && [ -s "$tf_input" ]; then
            fp="$tf_input"
        fi

        set pipefail
        filter="filter-things.sh"
        
        ret="$?" # catches fzf cancel exit = 130

        if [ -n "$filter" ]; then
            cat "$fp" | eval "$filter" | {
                if is_stdout_tty; then
                    v -nad
                else
                    cat
                fi
            }
        fi

        exit "$ret"
    }
    ;;

    filter-with-fzf) {
        fp="$1"

        if test "$HAS_STDIN" = "y"; then
            cat > "$tf_input"
        fi

        if ! [ -f "$fp" ] && [ -s "$tf_input" ]; then
            fp="$tf_input"
        fi

        # I actually need new options so I can use the preview command
        # separate of the {}.

        # {} is surrounded by single quotes
        # Should I allow multiple filters? No. -nm.
        # The 'timeout 2' here is not super important but it will prevent
        # things like org clink from hanging the preview

        set pipefail
        filter="$(cat "$HOME/notes2018/ws/filters/filters.sh" | fzf -C -nm -p -pscript "true; eval 'cat $fp | ' timeout 4 {}" -pcomplete)"
        ret="$?" # catches fzf cancel exit = 130
        # echo "$ret"

        # I don't need this (-pinputfile), or do I? I will get the
        # command to be executed from the currently selected
        # filter="$(cat "$HOME/notes2018/ws/filters/filters.sh" | hls -i -r -f white '\.org' | fzf -A -p -pinputfile "cat \"$fp\"" -pscript "eval 'cat $fp | ' {}" -pcomplete)"

        # this method is ok, but its drawbacks are:
        # doesn't use fzf's pcomplete
        # runs the preview command twice. once for the preview, once for
        # the result

        if [ -n "$filter" ]; then
            cat "$fp" | eval "$filter" | {
                if is_stdout_tty; then
                    v -nad
                else
                    cat
                fi
            }
        fi

        exit "$ret"
    }
    ;;

    urls|urls-only) {
        # Not implemented yet

        cat
    }
    ;;

    d|donly|dirs|dirs-only) {
        scrape-dirs-fast.sh

        # awk 1 | s cc | s uniq | while read -r line; do
        #     if test -d "$line"; then
        #         printf "%s\n" "$line"
        #     fi
        # done
    }
    ;;

    f|fonly|files|files-only) {
        scrape-files-fast.sh

        #awk 1 | sed 's=[^A-Za-z 0-9_./-]= =g' | while IFS=$'\n' read -r line; do
        #    if test -f "$line"; then
        #        printf "%s\n" "$line"
        #    fi
        #done

        ## | s cc | s uniq | while read -r line; do
        ##     if test -f "$line"; then
        ##         printf "%s\n" "$line"
        ##     fi
        ## done
    }
    ;;

    xonly|executables|exes-only) {
        awk 1 | s cc | s uniq | while read -r line; do
            if which "$line" &>/dev/null; then
                printf "%s\n" "$line"
            fi
        done
    }
    ;;

    which) {
        if stdin_exists; then
            input="$(cat)"
        else
            input="$1"
        fi
        which -a "$input" | v

        exit 0
    }
    ;;

    amp|awk-match-pipe) {
        # Find something in the file, put *part* of the match through an
        # external program

        # AWK regular expression engine does not capture its groups
        # Therefore, might need to use perl for this.

        # Make something to double the values of a field in here:
        # $HOME/.local/share/endless-sky/saves/Shane Master.txt
        # shields 17500

        # example
        # The thing that's going through must not have buffering
        # cat $HOME/scripts/c | soak | c avp python "sed -u -e 's/\(.*\)/\U\1/'"
        # cat $HOME/scripts/c | c avp printf theannotation cat|less
        # cat $HOME/scripts/c | c avp printf cat|less

        pattern="$1"
        shift
        # annotation="$1"
        # shift

        lit -s "$@" >> /tmp/cmd.sh

        # hls -c 1 '.*'

        CMD="$(cmd "$@")"

        #gawk -v cmd="$CMD" "/$pattern/ { print \$0; print \"\t$annotation\" |& cmd; cmd |& getline; } { print; system(\"\") }"
        gawk -v cmd="$CMD" "/$pattern/ { print \$0 |& cmd; cmd |& getline; } { print; system(\"\") }"
    }
    ;;

    bind1-with-fzf) {
        file="$1"

        cat "$HOME/notes2018/ws/filters/filters.sh" | f z

        exit 0
    }
    ;;

    # I should use this often
    z|fzf-if-tty) {
        # echo hi | f z
        # echo hi | f z | cat

        if is_stdout_tty; then
            fzf
        else
            cat
        fi
    }
    ;;

    *) { # If it doesn't work, try it in 'F' (find)
        F "$@"
    }
    ;;
esac
#!/bin/bash
export TTY

# Turn all my filters into lisp.

# String and stream operations.
# Especially manipluations.
# Related: $HOME/scripts/c

sn="$(basename "$0")"

stdin_exists() {
    # IFS= read -t0.1 -rd '' input < <(cat /dev/stdin)
    # exec < <(printf -- "%s" "$input")
    # [ -n "$input" ]

    ! [ -t 0 ]
    # ! [ -t 0 ] && read -t 0
}
case "$sn" in
    quote.pl) {
        notify-send "$sn is deprecated"
        f=q
    }
    ;;

    uniqnosort) {
        f=uniq
    }
    ;;

    soak) {
        f=soak
    }
    ;;

    field|all-caps|caps|uppercase|uc|lc|wrl|wrla|awrl) {
        f="$sn"
    }
    ;;

    repeat-string) {
        f=rs
    }
    ;;

    template) {
        :
    }
    ;;

    *) {
        f="$1"
        shift
    }
esac

case "$f" in
    indent) {
        level="$1"; : ${level:="1"}
        # printf -- "%s\n" "$level"
        r="$(zsh -c "printf '\t%.0s' {1..$level}")"

        sed -u "s/^/${r}/"
    }
    ;;

    all-caps|caps|uppercase|uc) {
        tr '[:lower:]' '[:upper:]'
    }
    ;;

    join) {
        delim="$1"
        : ${delim:=" "}

        sed -z "s~\n~$delim~g" | sed "s/$delim\$//"
        # tr '\n' ' '
    }
    ;;

    joinq) {
        qargs
    }
    ;;

    titlecase) {
        # sudo pip2 install titlecase
        titlecase
    }
    ;;

    one-of) {
        input="$(cat)"
        finds="$1"

        matches="$(p -- "%s\n" "$input" | sed -n "/^$finds\$/p")"
        [ -n "$matches" ]

        exit $?
    }
    ;;

    lc) {
        tr '[:upper:]' '[:lower:]'
    }
    ;;

    random_line) {
        # awk 'BEGIN { "date +%N" | getline seed; srand(seed); print rand(); }'; 

        # awk 'BEGIN { srand() } { l[NR]=$0 } END { print l[int(rand() * NR + 1)] }'

        awk 'BEGIN { "date +%N" | getline seed; srand(seed) } { l[NR]=$0 } END { print l[int(rand() * NR + 1)] }'
    }
    ;;

    # echo -n hi | s rs 2
    # s rs 2 hi
    rs) { # repeat string
        count="$1"
        shift

        : ${count:="1"}

        if stdin_exists; then
            IFS= read -rd '' input < <(cat /dev/stdin)
        else
            input="$1"
        fi

        for (( i = 0; i < count; i++ )); do
            printf -- "%s" "$input"
        done
    }
    ;;

    cap|capitalize) {
        sed 's/[^ _-]*/\u&/g'
    }
    ;;

    ef|efs|efws) {
        remove-starting-and-trailing-whitespace.sh
    }
    ;;

    rl) { # repeat lines
        n="$1"; : ${n:="1"}

        # remove_field

        
        awk 1 | awk '{while (c++<'$n') printf $0}'

        #awk 1 | while read -r line; do
        #    printf -- "%s\n" "$n"
        #    printf -- "h%.0s" {1..$n}
        #done
    }
    ;;
 
    q|quote) {
        q
    }
    ;;

    # Use this for searching for directories
    cc|consecutive-combinations) {
        consecutive-combinations.py
    }
    ;;

    soak) {
        IFS= read -rd '' input < <(cat /dev/stdin)
        printf -- "%s" "$input"
    }
    ;;

    awrl) {
        # Works
        # cat $HOME/scripts/s | s awrl "q -c"
        # cat $HOME/scripts/s | s awrl "q -l | uq -l"

        # Running a single sed subprocess on each line is much faster
        # cat $HOME/scripts/s | s awrl "sed -u 's/[a-z]/ /g'"
        # cat $HOME/scripts/s | s awrl "stdbuf -i0 -o0 -e0 sed 's/[a-z]/ /g'"
        # Does not work
        # cat $HOME/scripts/s | s awrl "stdbuf -i0 -o0 -e0 q"
        # unbuffer is not the problem, because this works
        # cat $HOME/scripts/s | s awrl "unbuffer -p cat"


        CMD="$(cmdne "$@")"


        # lit "$CMD"
        # exit 0

        # gawk "BEGIN{ cmd=\"$CMD\" } { print \$0 |& cmd; close(cmd); cmd |& getline; } { print; system(\"\") }"

        # Works but it keeps restarting the process
        # gawk -v cmd="$CMD" '{ print $0 |& cmd; close(cmd, "to"); cmd |& getline; close(cmd); print; fflush(); }'

        # gawk -v cmd="$CMD" 'BEGIN { PROCINFO[cmd, "pty"] = 1 } { print $0 |& cmd; cmd |& getline; print; fflush(); }'

        gawk -v cmd="$CMD" '{ print $0 |& cmd; cmd |& getline; print; fflush(); }'
    }
    ;;

    # while read line arg
    wrla) {
        awk1 | while IFS=$'\n' read -r line; do
            exec </dev/tty `# see etty`
            eval "$@" "$line" 
        done
    }
    ;;

    wrla1) {
        awk1 | while IFS=$'\n' read -r line; do
            "$@" "$line" | awk 1
        done
    }
    ;;

    wrl) {
        # This is much slower than
        # cat $HOME/scripts/s | s wrl "q -f"
        # cat $HOME/scripts/s | s awrl "q -lf"

        newline=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -n) {
                newline=n
                shift
            }
            ;;

            *) break;
        esac; done

        # cat $HOME/scripts/fpvd | c wrl q

        if test "$newline" = "y"; then
            awk 1 | while IFS=$'\n' read -r line; do
                printf "%s" "$line" | "$@"
                echo
            done
        else
            awk 1 | while IFS=$'\n' read -r line; do
                printf "%s" "$line" | "$@"
            done
        fi
    }
    ;;

    chomp|chomp-last-line)
        perl -pe 'chomp if eof'
    ;;

    tabulate) {
        tm n "$f :: NOT IMPLEMENTED"
        # http://search.cpan.org/~arif/Text-Tabulate-1.1.1/lib/Text/Tabulate.pm
    }
    ;;

    second) {
        :
    }
    ;;
    
    sed) { # http://backreference.org/2009/12/09/using-shell-variables-in-sed/
        opt="$1"
        shift
        case "$opt" in
            lhs) {
                sed 's/[[\.*/]/\\&/g; s/$$/\\&/; s/^^/\\&/'
            }
            ;;

            
            ere) { # lhs extended regex
                # EREs are less problematic, since the circumflex and
                # the dollar are always considered anchors except when
                # in bracket expressions; since we escape square
                # brackets, then by the same logic described above for
                # dot and star it's safe to escape them anywhere.

                sed 's/[[\.*^$(){}?+|/]/\\&/g'
            }
            ;;

            rhs) {
                sed 's/[\&/]/\\&/g'
            }
            ;;

            *)
        esac
    }
    ;;

    lf|last_field) {
        awk '{print $NF}'
    }
    ;;

    field|col|column) {
        #field="$1"
        #awk '{print $'$field'}'

        delim='[ \t\n]+'

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -d) {
                delim="$2"
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        field="$1"
        awk -F "$delim" '{print $'$field'}'
    }
    ;;

    sort-anum|sort-alphanumeric) {
        sort -b -d
    }
    ;;

    append-history-file) {
        file="$1"
        new_entry="$2"
        safe_pattern=$(printf '%s\n' "$new_entry" | s sed lhs)
        {
            cat "$file" | sed "/^$safe_pattern\$/d"
            lit "$new_entry"
        } | sponge "$file"
    }
    ;;
            
    uniq) {
        # This makes it uniq, rather than get the 'set difference'

        # without reordering / sorting
        # awk '!x[$0]++' # holds all in memory

        awk '!seen[$0] {print} {++seen[$0]}'

        # This appears to be reordering incorrectly.
        # awk '{print(NR"\t"$0)}' | sort -t$'\t' -k2,2 | uniq --skip-fields 1 | sort -k1,1 -t$'\t' | cut -f2 -d$'\t'
    }
    ;;

    bin2ascii) {
        uuencode
    }
    ;;
    
    dedup) { # without reordering / sorting
        awk '{print(NR"\t"$0)}' | sort -t$'\t' -k2,2 | uniq -u --skip-fields 1 | sort -k1,1 -t$'\t' | cut -f2 -d$'\t'
    }
    ;;

    rf|remove_field) {
        field="$1"
        ofs=" \t "
        awk -F' *\t *' -v myofs="$ofs" 'BEGIN{OFS=myofs}{$'$field' = ""; print $0}'
    }
    ;;

    summarize) {
        zsh -c "sumy lex-rank --length=10 --file=<(cat)"
    }
    ;;

    testf|test_function) {
        opt="$1"
        shift
        case "$opt" in
            rf|remove_field) {
                echo -e "Apple\tBanana\tCantaloupe" | s rf 2
            }
            ;;
            *)
        esac
    }
    ;;
    
    *)
esac
# $HOME/dump

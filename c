#!/bin/bash
export TTY

sn="$(basename "$0")"
case "$sn" in
    *) {
        opt="$1"
        shift
    }
    ;;
esac

# Text operations. c stands for character
# More mathy. Not limited to normal string manipulations.
# Related: $HOME/scripts/s
# vim +/"testf|test_function) {" "$HOME/scripts/c"



case "$opt" in
    lll|longest-line-length) {
        awk ' { if ( length > x ) { x = length } }END{ print x }'
    }
    ;;

    file-strings) {
        tm -t nw "strings \"$1\" | less"
    }
    ;;

    remove-n-fields) {
        python -c "import sys;[sys.stdout.write(' '.join(line.split(' ')[$1:])) for line in sys.stdin]"
    }
    ;;
    
    py-sub) {
        pattern="$1"
        substitution="$2"
        python -c "import sys,re;[sys.stdout.write(re.sub('$pattern', '$substitution', line)) for line in sys.stdin]"
    }
    ;;

    afp|awk-field-pipe) {
        # Use this instead: $HOME/scripts/aatc
        # This runs every field through theh script. That's pretty weird.
        gawk -F, 'BEGIN{OFS=","; cmd="l2u"} { for(i = 1; i <= NF; i++) { printf "%s\n", $i |& cmd; cmd |& getline \$i; }; } { print; system("") }END{close(cmd)}'
        # gawk -F, 'BEGIN{OFS=","; cmd="l2u"} { for(i = 1; i <= NF; i++) { printf "%s\n", $i |& cmd; cmd |& getline \$i; }; print; } END{close(cmd)}'
   } 
    ;;

    visor-ascii-codes|annotate-ascii-codes) {
        # https://stackoverflow.com/questions/2499270/how-to-print-ascii-value-of-a-character-using-basic-awk-only?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
        # Make all
        :
    }
    ;;
        
    # See:
    # vim +/"amp|awk-match-pipe) {" "$HOME/scripts/f"
    avp|awk-variable-pipe) {

        # example
        # The thing that's going through must not have buffering
        # cat $HOME/scripts/c | soak | c avp python "sed -u -e 's/\(.*\)/\U\1/'"
        # cat $HOME/scripts/c | c avp printf theannotation cat|less
        # cat $HOME/scripts/c | c avp printf cat|less

        pattern="$1"
        shift
        # annotation="$1"
        # shift

        CMD="$(cmd "$@")"

        lit "$CMD" >> /tmp/cmd.sh

        # hls -c 1 '.*'

        #gawk -v cmd="$CMD" "/$pattern/ { print \$0; print \"\t$annotation\" |& cmd; cmd |& getline; } { print; system(\"\") }"
        gawk -v cmd="$CMD" "/$pattern/ { print \$0 |& cmd; cmd |& getline; } { print; system(\"\") }"
    }
    ;;

    s-u|strip-utf|strip-unicode) {
        python2 -c "import sys,re,shanepy;[sys.stdout.write(shanepy.make_unicode(line).encode('ascii', 'ignore')) for line in sys.stdin]"
    }
    ;;
            
    ascify|asciify) {
        sed -e 's/▄/ /g' \
            -e 's/[┌┐┘└│├─┤┬┴┼]/ /g' \
            -e 's/\s\+$//g' ` # remove trailing whitespace ` | \
        sed -e 's/ / /g' \
         -e 's/…/.../g' \
         -e 's/ﬀ/ff/g' \
         -e 's/ﬃ/ffi/g' \
         -e 's/ﬁ/fi/g' \
         -e 's/ﬂ/fl/g' \
         -e 's/©/(c)/g' \
         -e 's/[“”]/"/g' \
         -e "s/[‘’]/'/g" \
         -e "s/[–—­]/-/g" | \
            c strip-unicode
    }
    ;;

    # Don't strip unicode until I'm sure I have caught it all.
    # c strip-unicode

    anum|alphanum|alphanumeric) {
        sed 's/[^a-zA-Z0-9]\+/ /g'
    }
    ;;

    nosymbol) {
        sed 's/[^a-zA-Z0-9_-]\+/ /g'
    }
    ;;

    char-frequency) {
        awk -f $HOME/var/smulliga/source/git/acmeism/RosettaCodeData/Task/Letter-frequency/AWK/letter-frequency.awk
    }
    ;;

    words) {
        # List out words. word chars include: "a-zA-Z0-9_-"
        # If not a tty but TTY is exported from outside, attach the tty
        exec </dev/tty
        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    html-decode|html_entities_decode) {
        # ENT_QUOTES is required for &quot; (html5 only)
        php -R 'echo html_entity_decode($argn, ENT_QUOTES | ENT_XML1, "UTF-8")."\n";' 2>/dev/null
    }
    ;;

    q|quote) {
        # Needs an option to force the outside quotes
        q
    }
    ;;

    qne|quote-no-args) {
        qne
    }
    ;;

    uq|unquote) {
        uq
    }
    ;;

    lc|lower-case) {
        tr '[:upper:]' '[:lower:]'
        # awk '{print tolower($0)}'
        # sed -e 's/\(.*\)/\L\1/'
        # perl -ne 'print lc'
    }
    ;;

    uc|upper-case) {
        tr '[:lower:]' '[:upper:]'
    }
    ;;

    tc|title-case) {
        sed -e 's/.*/\L&/' -e 's/[[:graph:]]*/\u&/g'
    }
    ;;

    no-special-chars) { # Turn special characters into regular ascii ones
        sed 's/[“”]/"/g' | sed "s/[‘’]/'/g"
    }
    ;;

    testf|test_function) {
        opt="$1"
        shift
        case "$opt" in
            lll|longest-line-length) {
                cat $HOME/scripts/c | c lll
            }
            ;;
            
            wrl) {
                cat $HOME/scripts/fpvd | c wrl q
            }
            ;;

            *)
        esac
    }
    ;;
    
    
    *) 
esac

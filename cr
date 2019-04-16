#!/bin/bash
export TTY

# Example
# $HOME/notes2018/ws/kotlin/examples/ls

# Everything related to compiling and running things
# Zr in vim should link to this

cd_run() {
    CWD="$1" exec x -zsh -s "ls" -c m -s "./$mant" -c m -a
}

cd_ls() {
    CWD="$1" exec x -zsh -s "ls" -c m -a
}

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -ft*) { # Because "$1" == "-ft kotlin", when used in shebang
        file_type="${opt##* }"
        shift
    }
    ;;

    *) break;
esac; done

#echo "$file_type"
#exit 0

# printf -- "%s\n" "$1"

fp="$1"
shift

rp="$(realpath "$fp")"
dn="${rp%/*}"

first_line="$(head -n 1 "$fp")"

td_cr="$(mktemp -t -d td_crXXXXXX || echo /dev/null)"
trap "rmdir \"$td_cr\" 2>/dev/null" 0

bn="$(basename "$rp")"

fn=$(basename "$rp")
ext="${fn##*.}"
mant="${fn%.*}"

read first_line < "$rp"

if [ -z "$file_type" ]; then
    file_type="$ext"
fi

# tm -d dv "$file_type"

case "$fn" in
    .compton.conf) {
        killall compton
        set -m
        compton & disown
        tm n "Compton restarted"
        exit 0
    }
    ;;
    
    shanepy.py) {
        cd "$dn"
        sudo rm /usr/local/lib/python2.7/dist-packages/shanepy*
        sudo rm /usr/local/lib/python3.5/dist-packages/shanepy*
        sudo python setup.py build -b /tmp/shanepy install --record /tmp/files.txt
        sudo python3 setup.py build -b /tmp/shanepy install --record /tmp/files.txt

        tm n "shanepy installed"
        pak
        exit 0
    }
    ;;

    Setup.hs) {
        runhaskell Setup.hs configure --ghc
        runhaskell Setup.hs build
        runhaskell Setup.hs install
        exit 0
    }
    ;;

    stack.yaml) {
        stack-build
        exit 0
    }
    ;;

    xmonad.hs|xmobarrc) {
        xmonad --recompile && xmonad --restart
        exit 0
    }
    ;;

    pl-flow-*) {
        file_type=json
    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac

case "$first_line" in
    '{') {
        file_type=json
    }
    ;;

    *)
esac

case "$file_type" in
    hs) {
        if yn "use interpreter?"; then
            #ans="$(qa -r runhaskell -s stackghc)"
            #case "$ans" in
            #    runhaskell) {
            #        runhaskell "$rp"
            #    }
            #    ;;
            #
            #    stackghc) {
            #        # this is not an interpreter
            #        stack ghc -- -O2 -threaded  "$rp"
            #    }
            #    ;;
            #
            #    *)
            #esac
            zsh-init runhaskell "$rp"
            pak
        else
            cd "$td_cr"
            ln -s "$rp"
            zsh-init ghc "./$fn" -o "$mant"\; ./"$mant"
            # zsh-init -E "( ghc \"./$fn\" -o \"$mant\" && "./$mant" \"\\\$@\" )"
            bash
            # And here I could use my terminal automation script to pretype
            # the command
        fi
        exit 0
    }
    ;;

    hy) {
        hy "$rp"
        pak
        exit 0
    }
    ;;

    problog) {
        problog "$rp" | vs
        exit 0
    }
    ;;

    jsonnet) {
        zsh-init -E "jsonnet $(aqf "$rp") | vs"
        exit 0
    }
    ;;

    m3u) {
        cvlc "$rp"
        exit 0
    }
    ;;

    el) {
        if test "$(head -c 2 "$rp")" = "#!"; then
            $rp
        else
            emacs-script "$rp"
        fi
        pak
        exit 0
    }
    ;;

    sh) {
        bash "$rp"
        pak
        exit 0
    }
    ;;

    #go) {
    #    cd "$td_cr"
    #    ln -s "$rp"
    #    go build "$rp" 2>&1 | mnm | nvpager

    #    fn=$(basename "$rp")
    #    ext="${fn##*.}"
    #    mant="${mant%.*}"

    #    ./"$mant"
    #    pak
    #    exit 0
    #}
    #;;

    go) {
        # This is not good enough
        # Requires rp to have .go extension.

        # This method is good enough
        # $HOME/scripts/go-re-grep
        # $HOME/scripts/re-grep.go

        # go run "$rp"
        zsh-init go run "$rp" --

        pak
        exit 0
    }
    ;;

    lisp) {
        clisp "$rp"
        pak
        exit 0
    }
    ;;

    es) {
        ess "$rp"
        pak
        exit 0
    }
    ;;

    js) {
        node "$rp" 2>&1 | vs
        # pak
        exit 0
    }
    ;;

    rkt) {
        echo racket "$rp"
        # nvt page racket "$rp"

        nvt -E "racket \"$rp\"; pak"

        # pak
        exit 0
    }
    ;;

    ts|type) {
        cd "$td_cr"
        ext="${fn##*.}"
        mant="${fn%.*}"

        # The extension is sometimes (incorrectly) type
        ln -s "$rp" "${mant}.ts"

        tsc "${mant}.ts"
        yn "Start vd?" && vd "${mant}.ts" "${mant}.js"
        yn "Run?" && ts-node "${mant}.ts"
        exit 0
    }
    ;;

    rs) {
        cd "$td_cr"
        ln -s "$rp"
        rustc "./$fn"
        cd_run "$cd_cr"
        # And here I could use my terminal automation script to pretype
        # the command
        exit 0
    }
    ;;

    c) {
        cd "$td_cr"
        ln -s "$rp"
        #CWD="$td_cr" zsh-init gcc -g "./$fn" -lm -o "$mant" \; "./$fn"
        CWD="$td_cr" zsh-init -E "gcc -g \"./$fn\" -lm -o \"$mant\"; ./$mant"

        # cd_run "$cd_cr"
        # And here I could use my terminal automation script to pretype
        # the command
        exit 0
    }
    ;;

    rb) {
        cd "$td_cr"
        # ruby "$rp"

        # Load into an interpreter. That's more interesting
        irb -r "$rp"
        exit 0
    }
    ;;

    scrbl) {
        cd "$td_cr"
        scribble --pdf "$rp"
        scribble --html "$rp"
        cd_ls "$cd_cr"
        exit 0
    }
    ;;

    cpp) {
        cd "$td_cr"
        ln -s "$rp"
        g++ -g -march=native -lm -pthread "./$fn" -o "$mant"
        cd_run "$cd_cr"
        # And here I could use my terminal automation script to pretype
        # the command
        exit 0
    }
    ;;

    py) {
        # I need python version detection
        python3 "$rp" 2>&1
        pak c
        exit 0
    }
    ;;

    toml) {
        filter toiq "$rp" 2>&1
        pak c
        exit 0
    }
    ;;

    yaml) {
        # I need python version detection
        tm -d nw -args filter yiq "$rp"
        # filter yiq "$rp" 2>&1
        # pak c
        exit 0
    }
    ;;

    json) {
        # I need python version detection
        tm -d nw -args filter myjiq "$rp"
        # filter myjiq "$rp" 2>&1
        # pak c
        exit 0
    }
    ;;

    kotlin|kts) {
        np="${td_cr}/script.kts"
        ln -s "$rp" "$np"
        kotlinc -script "$np" -- $@
        exit $?
    }
    ;;

    template) {
        :
    }
    ;;

    *) { # does it have a shebang?
        if test "$(head -c 2 "$rp")" = "#!"; then
            nvc -w -2 $rp
            pak
            exit $?
        fi
    }
    ;;
esac

if [ -f "$1" ]; then
    {
        lit "This must compile and run"
        echo
        echo
        cat "$1" 
    } | less
    exit 0
fi

lit "$1" | less

# nnoremap <silent> Zr :call ExecInTmux()<CR>
# silent! call system('rifle-run-split.sh "'.expand('%:p').'"'))

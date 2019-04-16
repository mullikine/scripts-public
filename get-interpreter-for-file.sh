#!/bin/bash
export TTY # shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

last_arg="${@: -1}"
fp="$last_arg"
rp="$(realpath "$fp")"
dn="$(dirname "$rp")"
cd "$dn"
bn="$(basename "$fp")"
ext="${fp##*.}"
fn="${fp%.*}"

case "$ext" in
    # hackett|hkt) { printf -- "%s\n" "$(which racket) -I hackett"; } ;; 
    hackett|hkt) { which racket; } ;; 
    rkt) { which racket; } ;; 
    hs) { which runhaskell; } ;; 
    js) { which node || which nodejs; } ;; 
    rb) { which ruby; } ;; 
    scrbl) { which scribble; } ;; 
    py) { which python3; } ;; 
    tcl) { which tclsh; } ;; 
    pl) { which perl; } ;; 
    sh) { which bash; } ;;
    *) { notify-send "$0 : create an entry for $ext here"; }
esac

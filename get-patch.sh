#!/bin/bash
export TTY

# If git repository

last_arg="${@: -1}"
fp="$last_arg"
rp="$(realpath "$fp")"
dn="$(dirname "$rp")"
cd "$dn"
bn="$(basename "$fp")"
ext="${fp##*.}"
fn="${fp%.*}"

cd "$dn"
git diff "$rp"
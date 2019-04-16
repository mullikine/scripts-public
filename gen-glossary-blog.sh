#!/bin/bash
export TTY

# Don't forget to find and remove any files in the blog folder with '#'
# in its name

fp="$1"
: ${fp:="$HOME/notes2018/glossary.txt"}

unbuffer nv -c "au BufEnter * call GeneralSyntax() | au BufEnter * call NumberSyntax()" -c "au BufEnter * hi Normal ctermfg=60" -c "au BufEnter * TOhtml" -c "e $fp" -c "wqa!" -n &>/dev/null

sed -i "s/^\(pre.*\)\(#[0-9a-f]\+\)\(; }\)$/\1#111\3/i" "${fp}.html"
sed -i "s/^\(body.*\)\(#[0-9a-f]\+\)\(; }\)$/\1#111\3/i" "${fp}.html"

cp -a "${fp}.html" $HOME/source/git/mullikine/mullikine.github.io

echo "${fp}.html" | xc -i -n -

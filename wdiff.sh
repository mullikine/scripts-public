#!/bin/bash
# see wdiff.py

#wdiff -s123 "$2" "$5"|grep -v \'/tmp\'
#the grep was to exclude calculations on the original file, but it's needed when diffing 2 historical commits
# need this pipe into cat
#hl <(wdiff -s123 "$2" "$5"|sed 's/^\//\n\//g') ":" "\/tmp\/" "\/dev\/null"
#wdiff -s123 "$2" "$5"|sed 's/^\//\n\//g'|sed 's/^\/dev\/null: .*/New File/g'|sed 's/^\/tmp\/.*_//g'
wdiff -s123 "$2" "$5"|sed 's/^\//\n\//g'|sed 's/^\/dev\/null: .*//g'|sed 's/^\/tmp\/.*_//g'

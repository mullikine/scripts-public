#!/bin/bash
export TTY

ext="$1"; : ${p1:="el"}

find . -name "*.$ext" | while read line; do cat "$line" | sed 's/\(([a-z-]\+\)/\n\1/g' | sed -n '/^([a-z]/ s/^(\([a-z]\+\) .*/\1/p'; done | sort | uniq -c | sort -n | tac

#for f in *.clj; do printf -- "%s\n" "$f" | while read line; do cat "$line" | sed 's/\(([a-z-]\+\)/\n\1/g' | sed -n '/^([a-z]/ s/^(\([a-z]\+\) .*/\1/p'; done; done | sort | uniq -c | sort -n | tac
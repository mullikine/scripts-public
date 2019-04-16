#!/bin/bash
if [ -n "$GIT_PREFIX" ]; then
    cd "$GIT_PREFIX";
fi

git log --oneline -- "$1"|cut -d ' ' -f 1|tac|while read line; do
    git diff $line\^! -- "$1"
done

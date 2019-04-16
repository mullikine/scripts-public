#!/bin/bash
if [ -n "$GIT_PREFIX" ]; then
    cd "$GIT_PREFIX";
fi
if [[ $# == 1 ]]; then
    git log --oneline | grep "$1"|cut -d ' ' -f 1|while read p; do
        git diff $p\^!;
    done
else
    echo "Example ‘git dt draw.c’"
fi

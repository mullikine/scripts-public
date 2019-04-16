#!/bin/bash

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

pager() {
    if is_tty; then
        fzf
    else
        cat
    fi
}

find . -path '*/.git*' -prune -o -print | pager

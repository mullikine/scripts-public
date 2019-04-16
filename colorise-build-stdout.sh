#!/bin/bash
export TTY

# hls uses a sed pattern
#Important

if ! test "$NO_DEFAULT_BG" = "y"; then
    export DEFAULT_BG=black
    export DEFAULT_FG=green
fi

{
    if test "$NO_DEFAULT_BG" = "y"; then
        cat
    else
        hls -i -f green -b nblack ".*"
    fi
} | 
hls -i -b red -f black "definition is void" | \
hls -i -b red -f yellow "error" | \
hls -i -b red -f yellow "FAIL[A-Z]*" | \
hls -i -b red -f yellow "could not" | \
hls -i -b red -f yellow "cannot" | \
hls -i -b red -f yellow "missing" | \
hls -i -b red -f yellow "incompatible" | \
mnm | \
cat
#!/bin/bash
export TTY

# hls uses a sed pattern
#Important

# hls -i -f green "Running" | \
# hls -i -f blue "review" | \

if ! test "$NO_DEFAULT_BG" = "y"; then
    export DEFAULT_BG=black
    export DEFAULT_FG=dgrey
fi

{
    if test "$NO_DEFAULT_BG" = "y"; then
        cat
    else
        hls -i -b black -f dgrey ".*"
    fi
} | 
hls -i -f black "definition is void" |
hls -i -b red -f yellow "error" |
hls -i -b red -f yellow "misbehaving" |
hls -i -b red -f yellow "failed" |
hls -i -b red -f yellow "FAILURE" |
hls -i -b red -f yellow "could not" |
hls -i -b red -f yellow "missing" |
hls -i -b nblack -f black "warning:" |
hls -i -b nblack -f yellow "-W" |
hls -i -b red -f yellow "incompatible" |
hls -i -b red -f yellow "timed out" |
mnm |
cat
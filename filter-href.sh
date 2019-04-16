#!/bin/bash
export TTY


sed -e 's/\(href="\)/\n\1/g' | \
# sed -n -e '/href="/p'
sed -n -e 's/.*href="\([^"]\+\)".*/\1/gp' | htmlentities-decode.sh # | urldecode

# !/bin/bash
export TTY

cat | \
    sed 's/\t/    /g' | \    # use spaces for indents
    sed 's/^\s\+/    /g' | \ # use consistent intent
    max-double-spaced.sh

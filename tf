#!/bin/bash
export TTY

# Takes stdin as contents and para 1 as extension and echo the resulting
# filename. Good for fpvd

ext="$1"
: ${ext:="dat"}

stdin_exists() {
    ! [ -t 0 ]
}

tf_tmpfile="$(nix tf tempfile "$ext" || echo /dev/null)"

if stdin_exists; then
    cat > "$tf_tmpfile"
fi

echo "$tf_tmpfile"

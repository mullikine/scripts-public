#!/bin/bash
export TTY

# Use this for the go pastebin
# https://play.golang.org

# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# If you pipe into pb, then p1 is the filename hinted to pastebin
# If you provide a path to a file, then it will simply upload that file

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

stdin_exists() {
    # IFS= read -t0.1 -rd '' input < <(cat /dev/stdin)
    # exec < <(printf -- "%s" "$input")
    # [ -n "$input" ]

    ! [ -t 0 ]
    # ! [ -t 0 ] && read -t 0
}

fp="$1"

ext=

if stdin_exists; then
    lit "stdin paste" | udl

    if [ -n "$fp" ]; then
        ext="$fp"

        # fp is the desired extension
        fp="/tmp/paste.$$.$fp"
    else
        fp="/tmp/paste-$$.txt"
    fi

    rm -f "$fp"

    cat > "$fp"
elif test -f "$fp"; then
    lit "file paste" | udl

    rp="$(realpath "$fp")"
    bn="$(basename "$fp")"
    dn="${fp%/*}"
    if [ -d "dn" ]; then
        cd "$dn"
    fi
    ext="${bn##*.}"
else
    lit "xc paste" | udl

    fp="/tmp/paste-$$.txt"
    xc - > "$fp"
fi

output="$(cat "$fp" | curl -F 'f:1=<-' ix.io 2>/dev/null)"
# output="$(curl -F c=@"$fp" https://ptpb.pw/ 2>/dev/null)"

# printf -- "%s\n" "$output" 1>&2
url="$output"
# url="$(printf -- "%s\n" "$output" | sed -n '/^url:/ s/^[^ ]\+ //p' | s chomp)"
if test -n "$ext" && ! test "$ext" = "txt"; then
    printf -- "%s" "$url/$ext" | xc -i - | awk 1
else
    printf -- "%s" "$url" | xc -i - | awk 1
fi


paste="$(curl "$url" 2>/dev/null)"
printf -- "%s" "$paste" | head -n 5
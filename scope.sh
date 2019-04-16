#!/usr/bin/env bash
# ranger supports enhanced previews.  If the option "use_preview_script"
# is set to True and this file exists, this script will be called and its
# output is displayed in ranger.  ANSI color codes are supported.

# NOTES: This script is considered a configuration file.  If you upgrade
# ranger, it will be left untouched. (You must update it yourself.)
# Also, ranger disables STDIN here, so interactive scripts won't work properly

# Meanings of exit codes:
# code | meaning    | action of ranger
# -----+------------+-------------------------------------------
# 0    | success    | success. display stdout as preview
# 1    | no preview | failure. display no preview at all
# 2    | plain text | display the plain content of the file
# 3    | fix width  | success. Don't reload when width changes
# 4    | fix height | success. Don't reload when height changes
# 5    | fix both   | success. Don't ever reload
# 6    | image      | success. display the image $cached points to as an image preview

# exec 2>/dev/null

# Meaningful aliases for arguments:
path="$1"    # Full path of the selected file
width="$2"   # Width of the preview pane (number of fitting characters)
height="$3"  # Height of the preview pane (number of fitting characters)
cached="$4"  # Path that should be used to cache image previews

# Just don't do large files
#[[ $(find "$path" -type f -size +51200c 2>/dev/null) ]] && exit 0
[[ $(find "$path" -type f -size +512000c 2>/dev/null) ]] && exit 0

if [ -z "$width" ]; then
    width="$COLUMNS"
    if [ -z "$width" ]; then
        eval `resize`
        LINES=$(tput lines)
        COLUMNS=$(tput cols)

        width="$COLUMNS"
    fi
    maxln=10000    # Stop after $maxln lines.  Can be used like ls | head -n $maxln
else
    maxln=200    # Stop after $maxln lines.  Can be used like ls | head -n $maxln
fi

# Find out something about the file:
mimetype="$(file --mime-type -Lb "$path")"

extension="$(/usr/bin/printf -- "%s\n" "${path##*.}" | tr "[:upper:]" "[:lower:]")"

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

is_tty && IS_TTY=y

# Functions:
# runs a command and saves its output into $output.  Useful if you need
# the return value AND want to use the output in a pipe
try() {
    output="$(eval '"$@"')";
}

# writes the output of the previously used "try" command
dump() { /usr/bin/printf -- "%s\n" "$output"; }

# a common post-processing function used after most commands
trim() { head -n "$maxln"; }

# wraps highlight to treat exit code 141 (killed by SIGPIPE) as success
# highlight() { command highlight "$@"; test $? = 0 -o $? = 141; }

# Always succeed
highlight() {
    if test "$IS_TTY" = "y"; then
        {
            command highlight "$@" 2>/dev/null
        } || {
            for arg in "$@"; do case "$arg" in
                -*) shift ;;
                *) break ;;
            esac; done

            lit -s "$@" | awk 1 | udl
            last_arg="${@: -1}"
            cat "$last_arg" | rosie match all.things
        }
    else
        last_arg="${@: -1}"
        cat "$last_arg"
    fi
}

case "$extension" in
    # Archive extensions:
    7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
    rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
        try als "$path" && { dump | trim; exit 0; }
        try acat "$path" && { dump | trim; exit 3; }
        try bsdtar -lf "$path" && { dump | trim; exit 0; }
        exit 1;;
    jpg|png) {
        # Do not even try
        exit 1
        # for some reason, timg only works inside tmux. Make a script to
        # run timg inside of tmux and then cat tmux.
        # A tmux cat program
        export TERM=screen-256color; unbuffer timg "$path"
        exit 0
        }
        ;;
    rar)
        try unrar -p- lt "$path" && { dump | trim; exit 0; } || exit 1;;
    # PDF documents:
    pdf) {
        try pdftotext -l 10 -nopgbrk -q "$path" - && \
            { dump | trim | fmt -s -w $width; exit 0; } || exit 1
            }
        ;;
    # BitTorrent Files
    torrent)
        try transmission-show "$path" && { dump | trim; exit 5; } || exit 1;;
    # HTML Pages:
    htm|html|xhtml)
        try w3m    -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        try lynx   -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        try elinks -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        ;; # fall back to highlight/cat if the text browsers fail
esac

case "$mimetype" in
    # Syntax highlight for text files:
    text/* | */xml) {
        try highlight --out-format=ansi "$path" && { dump | trim; exit 5; } || exit 2
    }
    ;;

    # Ascii-previews of images:
    image/*) {
        # Do not even try
        exit 1

        # for some reason, timg only works inside tmux. Make a script to
        # run timg inside of tmux and then cat tmux.
        # A tmux cat program
        export TERM=screen-256color; unbuffer timg "$path"
        exit 0

        # img2txt --gamma=0.6 --width="$width" "$path" && exit 4

        # timg is much better
        # https://github.com/hzeller/timg
        
        #if [ -z "$height" ]; then
        #    height="$LINES"
        #    
        #    if [ -z "$height" ]; then
        #        LINES=$(tput lines)

        #        height="$LINES"
        #    fi
        #fi
        # echo "$width x $height" | tv

        # Works but use img2txt instead because ranger cuts out anything
        # above 16 colors anyway.
        # TERM=xterm-256color timg -g${width}x${height} "$path"  && exit 4 || exit 1

        # OK so it's working fine but ranger is stripping the colour out
        # or something
        # TERM=xterm-256color timg -g${width}x${height} "$path" | tm -S -tout spv "less -rS" && exit 4 || exit 1
        # export TERM=xterm-256color
        # timg -E -f1 -c1  -g30x20 "$path" && exit 4 || exit 1
    }
    ;;
    # Image preview for videos, disabled by default:
    # video/*)
    #     ffmpegthumbnailer -i "$path" -o "$cached" -s 0 && exit 6 || exit 1;;
    # Display information about media files:
    video/* | audio/*)
        exiftool "$path" && exit 5
        # Use sed to remove spaces so the output fits into the narrow window
        try mediainfo "$path" && { dump | trim | sed 's/  \+:/: /;';  exit 5; } || exit 1;;
esac

exit 1

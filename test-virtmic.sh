#!/bin/bash
export TTY

fp="$1" # mp3
rp="$(realpath "$fp")"
bn="$(basename "$fp")"

tf_wav="$(nix tf wav wav || echo /dev/null)"
trap "rm \"$tf_wav\" 2>/dev/null" 0

ffmpeg -i "$fp" "$tf_wav"
if ! [ -e "${tf_wav}.raw" ]; then
    sox -r 48k  -b 16 -L -c 1 "$tf_wav" "${tf_wav}.raw"
fi

# test
play -r 48k -s -b 32 -L -c 1 "${tf_wav}.raw"

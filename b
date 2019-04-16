#!/bin/bash
export TTY

# This is for all things binary files

sn="$(basename "$0")"

case "$sn" in
    *) {
        f="$1"
        shift
    }
esac

case "$f" in
    bin2ascii) {
        uuencode -
    }
    ;;
    
    ascii2bin) {
        uudecode
    }
    ;;
    
    *)
esac

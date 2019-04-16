#!/bin/bash
export TTY

# All things crypto

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -n) {
        window_name="$2"
        shift
        shift
    }
    ;;

    *) break;
esac; done


opt="$1"
shift
case "$opt" in
    enc) {
        openssl rsautl -decrypt -inkey ~/.ssh/id_rsa -in <(
        echo ""|openssl enc -base64 -d
        ) 2>&-
    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac

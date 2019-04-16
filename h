#!/bin/bash
export TTY

# All things help and info


path_info() {
    fp="$1"

    fn=$(basename "$fp")
    dn=$(dirname "$fp")
    ext="${fn##*.}"
    mant="${fn%.*}"

    case "$ext" in
        first) {
            :
        }
        ;;

        template) {
            :
        }
        ;;

        *)
    esac

    return 0
}


sn="$(basename "$0")"

case "$sn" in
    pathi) {
        opt=pathinfo
    }
    ;;

    *)
        opt="$sn"
esac

case "$opt" in
    pathinfo)
        path_info "$@"
    ;;

    *)
esac

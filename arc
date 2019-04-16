#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# arc l arj.zip
# arc x arj.zip
# arc ux arj.zip # remove the files

# all things archives

last_arg="${@: -1}"
fp="$last_arg"
rp="$(realpath "$fp")"
dn="$(dirname "$rp")"
cd "$dn"
bn="$(basename "$fp")"
ext="${fp##*.}"
fn="${fp%.*}"

op="$1"
shift
case "$op" in
    l|ls) {
        case "$ext" in
            zip) {
                zipinfo -1 "$fp"
            }
            ;;

            *)
        esac
    }
    ;;

    ux|unx) {
        case "$ext" in
            zip) {
                zipinfo -1 "$fp" | tee /dev/stderr | awk1 | while IFS=$'\n' read -r line; do
                    test -f "$line" && rm -rI "$line"
                done 
            }
            ;;

            *)
        esac
    }
    ;;

    x) {
        case "$ext" in
            zip) {
                mkdir "$fn"
                unzip -d "$fn" "$fp"
            }
            ;;

            *)
        esac
    }
    ;;

    *)
esac
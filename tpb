#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

# tpb predator

opt="$@"
shift
case "$opt" in
    movies) {
        url="http://uj3wazyk5u4hnvtk.onion/browse/201/0/7/0"
    }
    ;;

    webrip) {
        url="http://uj3wazyk5u4hnvtk.onion/search/webrip/0/99/0"
    }
    ;;

    brrip) {
        url="http://uj3wazyk5u4hnvtk.onion/search/brrip/0/99/0"

        # https://1337x.to/search/brrip/1/
    }
    ;;

    *) {
        # url="http://uj3wazyk5u4hnvtk.onion/"

        url="http://uj3wazyk5u4hnvtk.onion/search/$(urlencode "$opt")/0/99/0"
    }
    ;;
esac

# w3m will only allow mouse for xterm
export TERM=xterm-256color

my-torify w3m -2 "$url"

# while :; do
#     my-torify w3m -2 "$url"
#     # nvc my-torify w3m -2 "$url"
#     yn -n "NnQq" "try again?" || break
# done
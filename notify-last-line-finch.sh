#!/bin/bash

exit 0

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

latest_line=`find ~/.purple/logs/facebook/ -mtime -1 -printf "%T@ %Tx %TX %p\n" | sort -n -r | head | cut -d ' ' -f 2- | awk '{print $NF}' | head -1 | xargs tail -1 | sed -e 's#<[^>]*>##g'`

# mplayer $1 >/dev/null 2>&1 &

notify-send "`echo $latest_line | cut -d ':' -f 3 | awk -F ')' '{print $2}'`" "`echo $latest_line | cut -d ':' -f 4-`"
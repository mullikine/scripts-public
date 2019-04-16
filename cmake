#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

export CMAKE_BUILD_TYPE=Debug


bin="$(which -a cmake |grep -v scripts | head -n 1)"
CMAKE_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu "$bin" "$@"


echo "$$ $cmd" | udl | hls -i -f dred -b nblack ".*"
# | hls -i -f red -b dblue cmake

exec 1> >(colorise-build-stdout.sh)
exec 2> >(colorise-build.sh)

eval "$cmd"
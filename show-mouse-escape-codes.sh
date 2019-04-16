#!/bin/bash
export TTY

# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

tm -d sph -d -bash "sleep 0.5; sh -i >& /dev/tcp/127.0.0.1/4444 0>&1"; echo -e "\e[?1000h"; nc -l 4444
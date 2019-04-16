#!/bin/bash
export TTY

exec 3>&2
exec 2>/dev/null
# jq is called by jiq, which doesn't give it a path.
# Therefore, source the shell_environment
source ~/.shell_environment

# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )
exec 2>&3

/usr/bin/jq "$@"

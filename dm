#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" 0</dev/null ) &>/dev/null

/usr/bin/datamash "$@"

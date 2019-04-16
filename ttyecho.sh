#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# I need to fix cr up to take arguments and to not echo out stuff from
# the 'x' tty
cr $HOME/scripts/ttyecho.c

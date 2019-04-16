#!/bin/bash
export TTY

exec 2>/dev/null

set -m
(
unbuffer timeout 0.3 $HOME/var/smulliga/source/tarballs/xterm-278/vttests/256colors.pl & disown
) | tr -s ' ' '\t' | columnate COLUMNS=$COLUMNS
 
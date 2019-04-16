#!/bin/bash
export TTY

mv "$@" $DL
cd "$DL"
CWD="$DL" tsph

#!/bin/bash
export TTY

for d in \
$EMACSD/my-packages \
$EMACSD/config; do

    find "$d" -name '*.el'
done | mnm
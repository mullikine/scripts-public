#!/bin/bash
export TTY

eval `resize`

$MYGIT/pipeseroni/pipes.sh/pipes.sh "$@"
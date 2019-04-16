#!/bin/bash
export TTY

# Things to do with doing math on the command-line.

rand() {
    awk -v min=1 -v max=1000000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
    return 0
}

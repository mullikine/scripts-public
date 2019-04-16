#!/bin/bash
export TTY

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

if is_tty; then
    nvc /usr/bin/gdb "$@"
else
    /usr/bin/gdb "$@"
fi

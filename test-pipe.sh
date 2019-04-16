#!/bin/bash
export TTY

exec 1> >(tee >(cat))
# exec 2> >(tee >(cat >&2))

# echo hi >&2

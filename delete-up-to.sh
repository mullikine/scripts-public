#!/bin/bash
export TTY

char="$1"

sed "s/^[^$1]\+\($1\)/\1/"

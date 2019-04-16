#!/bin/bash
export TTY

pattern="$1"
shift

annotation="$1"
shift

apply_command="$1"
shift

gawk -v cmd="$apply_command" "/$pattern/ { print \$0; print \"$annotation\" |& cmd; cmd |& getline; } { print; system(\"\") }"
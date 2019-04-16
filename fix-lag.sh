#!/bin/bash
export TTY

# This command must fix lag

# kill the tmux wrap session
# This is often the cause of a very laggy tmux

# ** nvim is lagging my computer
# Even when nothing is happening, irssi is lagging a lot with nvim.

ps -ef | grep "tm.*capture" | grep -v grep | s field 2 | xargs kill

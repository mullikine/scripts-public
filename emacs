#!/bin/bash
export TTY

if test -f $HOME/local/emacs26/bin/emacs; then
	$HOME/local/emacs26/bin/emacs "$@"
else
	/usr/bin/emacs "$@"
fi

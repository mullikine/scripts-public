#!/bin/bash
if [ -n "$GIT_PREFIX" ]; then
    cd "$GIT_PREFIX";
fi
source ~/home/scripts/start_tmux.sh;
if [[ $# == 1 ]]; then
    GREV="$1"
    NEW_SESSION_NAME="Δ-${GREV}"
    DIFFCMD="git difftool ${GREV} --"
else
    GREV="$( git log --pretty=format:'%h' -n 1 )"
    NEW_SESSION_NAME="δ-${GREV}"
    DIFFCMD="git difftool --"
fi
export GREV
export NEW_SESSION_NAME
GDIR="$( git rev-parse --show-toplevel )"
CDIR="$( pwd )"
export CURRENT_SESSION_NAME="`tmux display-message -p '#{session_name}'`"
export CURRENT_WINDOW_NAME="`tmux display-message -p '#{window_name}'`"
export CURRENT_SESSION_PATH="`tmux display-message -p '#{pane_start_path}'`"
export NEW_SESSION_FULLNAME="${CURRENT_SESSION_NAME}_$NEW_SESSION_NAME"
tmux_s ${CURRENT_SESSION_NAME}_$NEW_SESSION_NAME $NEW_SESSION_NAME $CURRENT_SESSION_NAME "$CURRENT_SESSION_PATH/$NEW_SESSION_NAME" ""
waitForSession "$NEW_SESSION_FULLNAME"
cd "$CDIR"
(
if [[ $# == 1 ]]; then
    git diff --name-only ${GREV}
else
    git diff --name-only
fi
) | while read line
do
    GFNAME="`basename $line`"
    tmux neww -t "$NEW_SESSION_FULLNAME:" -n "$GFNAME" -c "$GDIR" "bash -lc \"$DIFFCMD $line\""
done

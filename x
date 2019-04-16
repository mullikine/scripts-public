#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

# Consider using this
# man expect-lite

# Related: scripts using x
# $HOME/scripts/xs

# example 1: this adds and starts a git commit message
# x -m "\`" -m t -m e -m v -i

PANE_ID="$(tmux display-message -p -t $TMUX_PANE '#{pane_id}' 2>/dev/null)"

SHELL=zsh

input_filter() {
    # I don't want to escape \n
    sed 's/\([[$"]\)/\\\1/g'

    # qne
    # cat
    return 0
}

# Examples
# x -nto -e » -s "pti3\n" -e "In" -s "%matplotlib tk\n" -i
# x -nto -sh "pti3" -e "In [" -scc c -s yo -scc m -i
# x -tmc pti3 -nto -e "In [" -scc c -s yo -scc m -i
# x -h -d -tmc pti3 -nto -e "In [" -scc c -s "%matplotlib tk\n" -scc m -e "In [" -i
# x -h -d -tmc pti3 -nto -e "In [" -scc c -s "%matplotlib tk\n" -scc m -e "In [" -a
# x -d -tmc htop -e running -a

export TMUX=

tf_script="$(nix tf script exp || echo /dev/null)"

script_append() {
    # printf -- "$1" >> "$tf_script"
    # echo -e "$1" >> "$tf_script"

    lit "$1" >> "$tf_script"

    return 0
}

script_append "#!/usr/bin/expect -f"

timeout=3600
uses_tmux=n
debug_mode=n
tmux_command=
attach_tmux=n
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -d) {
        debug_mode=y
        shift
    }
    ;;

    -n|-g|-dr) { #gen
        DRY_RUN=y
        shift
    }
    ;;

    -sh) {
        SHELL="$2"
        shift
        shift
    }
    ;;

    -cd ) {
        cd "$2"
        export CWD="$1"
        shift
        shift
    }
    ;;

    -h) { # hide output until interactive
        script_append "log_user 0"
        # script_append "stty -echo"
        shift
    }
    ;;

    -tm) {
        uses_tmux=y
        if [ -z "$PANE_ID" ]; then
            echo "No tmux pane. Can't swap pane so not trying."
            exit 1
        fi
        tmux_session="$(TMUX= tmux new -F "#{session_id}" -P -d)"
        tmux_session_qne="$(p "$tmux_session" | input_filter)"
        SHELL=tmux
        shift
    }
    ;;

    -tmc) {
        uses_tmux=y
        tmux_session="$(TMUX= tmux new -F "#{session_id}" -P -d)"
        tmux_session_qne="$(p "$tmux_session" | input_filter)"
        SHELL=tmux
        tmux_command="$2"
        shift
        shift
    }
    ;;

    -to) {
        timeout="$2"
        shift
        shift
    }
    ;;

    -nto|-notimeout) { # No timeout
        timeout=-1
        shift
    }
    ;;

    -zsh) {
        SHELL="zsh"
        shift
    }
    ;;

    *) break;
esac; done

if ! test "$debug_mode" = "y"; then
    exec 2>/dev/null
fi

# I should design this script first to use tmux

# The final expect script:
# script=""

read -r -d '' expect_script <<'HEREDOC'

#trap sigwinch and pass it to the child we spawned
trap {
    set rows [stty rows]
    set cols [stty columns]
    stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

proc getctrl {char} {
    set ctrl [expr ("$char" & 01xF)]
    return $ctrl
}

set force_conservative 0
if {$force_conservative} {
    set send_slow {1 .1}
    proc send {ignore arg} {
        sleep .1
        exp_send -s -- $arg
    }
}

# For send -h
set send_human {.4 .4 .2 .5 100}
HEREDOC
script_append "$expect_script"

read -r -d '' expect_script <<'HEREDOC'
set timeout -1
match_max 100000
HEREDOC
script_append "$expect_script"

# script_append "spawn -noecho \"\$env(SHELL)\""
if test "$SHELL" = "zsh"; then
    # script_append "spawn \"\$env(SHELL)\""
    script_append "spawn \"zsh\""
    script_append "expect -exact \"»\""
elif test "$SHELL" = "tmux"; then
    # sleep
    # tmux ls > /tmp/tms.txt
    if [ -n "$tmux_command" ]; then
        # this does what it's supposed to. the session ID is correct but
        # it must not be ready. if i call without the target, it
        # works though. how annoying.

        #script_append "spawn \"\$env(SHELL)\" \"respawn-pane\" \"-t\" \"${tmux_session_qne}:1.0\" \"-k\" \"$tmux_command\" \"\\;\" \"attach\" \"-t\" \"$tmux_session_qne\""

        # TODO For the moment, don't use the target. This is dodgy, I
        # know. Hmm, it's still not working.
        # script_append "spawn \"tmux\" \"respawn-pane\" \"-k\" \"$tmux_command\" \"\\;\" \"attach\" \"-t\" \"$tmux_session_qne\""
        
        # script_append "spawn \"tmux\" \"respawn-pane\" \"-k\" \"$tmux_command\""
        # It might be slightly more stable with the sleep here.
        script_append "sleep 0.2"
        # Write tmux explicitly instead of $env(SHELL)
        # This way I can run the script after printing it to stdout
        script_append "spawn \"tmux\" \"respawn-pane\" \"-t\" \"$tmux_session_qne\" \"-k\" \"$tmux_command\""
        # script_append "sleep 0.5"
        # Separating the 2 commands appears to make it a little more
        # stable.
        # Using \"\$env(SHELL)\" instead of tmux appears to make no
        # difference here
        script_append "spawn \"tmux\" \"attach\" \"-t\" \"$tmux_session_qne\""

        # script_append "spawn \"tmux\" \"respawn-pane\" \"-k\" \"$tmux_command\" \"\\;\" \"attach\" \"-t\" \"$tmux_session_qne\""
        # script_append "expect -exact \"sh\""
    else
        script_append "spawn \"\$env(SHELL)\" \"attach\" \"-t\" \"$tmux_session_qne\""
        script_append "expect -exact \"sh\""
    fi
else
    script_append "spawn \"\$env(SHELL)\""
    script_append "expect -exact \"\r\""
fi

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -e) { # Expect something
        input="$(p "$2" | input_filter)"

        script_append "expect -exact \"$input\""
        shift
        shift
    }
    ;;

    -u) { # Expect user input
        input="$(p "$2" | input_filter)"

        script_append "expect_user -timeout $timeout \"$input\";"
        script_append "set user_input \"\$expect_out(0,string)\""
        script_append "send -- \"\$user_input\\r\""
        shift
        shift
    }
    ;;

    -ur) { # Expect user input matching regex
        input="$(p "$2" | input_filter)"

        # example:
        # -ur "(.*)\[\r\n]"
        # x -nto -e » -s "vim\n" -ur "(.*hi.*)" -i

        # script_append "send -- {getctrl {l}}"
        script_append "expect_user -timeout $timeout -re \"$input\";"
        script_append "set user_input \"\$expect_out(1,string)\"" # 1 must be capture group 1. 0 is entire string
        script_append "send -- \"\$user_input\\r\""
        shift
        shift
    }
    ;;

    -p) { # Expect user input password
        input="$(p "$2" | input_filter)"

        script_append "stty -echo"
        script_append "expect_user -timeout $timeout \"$input\""
        script_append "set user_input \"\$expect_out(1,string)\"" # 1 must be capture group 1. 0 is entire string
        script_append "send -- \"\$user_input\\r\""
        script_append "stty echo"
        shift
        shift
    }
    ;;

    -pr) { # Expect user input password matching regex
        # input="$(p "$2" | input_filter)"

        input="$2"

        # example:
        # -ur "(.*)\[\r\n]"

        script_append "stty -echo"
        script_append "expect_user -timeout $timeout -re \"$input\""
        script_append "set user_input \"\$expect_out(1,string)\"" # 1 must be capture group 1. 0 is entire string
        script_append "send -- \"\$user_input\\r\""
        script_append "stty echo"
        shift
        shift
    }
    ;;

    -c|-scc) { # Send control character
        # script_append "send {getctrl {$2}}"
        script_append "send -- $(cchar $2)"
        shift
        shift
    }
    ;;

    -m) { # Send meta
        script_append "send -- \\033$2"
        shift
        shift
    }
    ;;

    -cm) { # Send control-meta
        script_append "send -- \\033$(cchar $2)"
        shift
        shift
    }
    ;;

    -sec) { # Send escape char
        script_append "send -- \\033$2"
        shift
        shift
    }
    ;;

    -esc) { # Send escape char
        script_append "send -- \\033"
        shift
    }
    ;;

    -sl) {
        script_append "sleep $2"
        shift
        shift
    }
    ;;

    -s1) {
        script_append "sleep 1"
        shift
    }
    ;;

    -s|-send) { # Send something
        # input="$(p "$2" | input_filter)"

        input="$2"

        script_append "send -- $(aqfd "$input")"
        shift
        shift
    }
    ;;

    # Frustratingly, can't work out why this doesn't work
    -ss|-send-slow) { # Send something
        input="$(p "$2" | input_filter)"

        script_append "set send_slow {2 0.5}"
        script_append "send -s $(aqfd "$input")"
        shift
        shift
    }
    ;;

    -i) {
        if test "$uses_tmux" = "y"; then
            # This sleep appears to help the script catch the final
            # expect statement
            script_append "sleep 0.2"
            script_append "exit"
        else
            script_append "interact"
        fi
        shift
    }
    ;;

    -a) {
        if test "$uses_tmux" = "y"; then
            attach_tmux=y
            # This sleep appears to help the script catch the final
            # expect statement
            script_append "sleep 0.2"
            script_append "exit"
        else
            script_append "interact"
        fi
        shift
    }
    ;;

    -fc) {
        # Set some expect options

        script_append "set force_conservative 0"
        shift
    }
    ;;

    -ts) {
        # tm n "$opt :: NOT IMPLEMENTED"
        # Tmux-Send something

        input="$(p "$2" | input_filter)"
        script_append "spawn \"\$env(SHELL)\" \"send\" \"-t\" \"${tmux_session_qne}\" \"$input\""

        # script_append "$2"
        shift
        shift
    }
    ;;

    -tsl) {
        # tm n "$opt :: NOT IMPLEMENTED"
        # Tmux-Send something

        input="$(p "$2" | input_filter)"
        script_append "spawn \"\$env(SHELL)\" \"send\" \"-t\" \"${tmux_session_qne}\" -l \"$input\""

        # script_append "$2"
        shift
        shift
    }
    ;;

    -tssl) {
        # tm n "$opt :: NOT IMPLEMENTED"
        # Tmux-Send something

        input="$(p "$2" | input_filter)"
        script_append "spawn \"tm\" \"type\" \"$input\""

        # script_append "$2"
        shift
        shift
    }
    ;;

    *) break;
esac; done

read -r -d '' expect_script <<'HEREDOC'
expect eof
close
HEREDOC

script_append "$expect_script"

printf -- "%s" "$script" >> "$tf_script"

export SHELL

if test "$DRY_RUN" = "y"; then
    cat "$tf_script"
else
    expect -f "$tf_script"
fi

# The session must be guaranteed to exist before attaching.
# This is risky

# sleep 1

if ! test "$DRY_RUN" = "y"; then
    if test "$attach_tmux" = "y"; then
        tmux attach -t "$tmux_session"
    elif test "$uses_tmux" = "y"; then
        tmux swap-pane -s "$tmux_session:1.0" -t "$PANE_ID" \; kill-session -t "$tmux_session"
    fi
fi

if ! test "$debug_mode" = "y"; then
    trap "rm \"$tf_script\" 2>/dev/null" 0
else
    echo
    echo "$tf_script" 1>&2
fi

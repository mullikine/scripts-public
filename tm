#!/bin/bash
export TTY

# deps
# tm-lsp.sh

# This script uses CALLER_TARGET as a session name, which is evil.
# Needs immediate refactoring to use PANE instead of SESSION. Because
# there is no current_pane id that you can get from session.

# I want any processes spawned by this script to become detached and not
# die. I think this worked to prevent the tmux server from dying when I
# F1-K on localhost.

# trap on_quit EXIT
# on_quit() {
#     exec 2>/dev/null
#     jobs -p | xargs kill # kill jobs
#     trap '' PIPE CHLD HUP # do not kill child processes
# }

# This needs to be stabilised
# echo hi | tm -i nw "soak | fzf -nm --sync | soak" | cat
# This is far more stable
# echo hi | tm -i nw "fzf" | cat

# trap func_trap INT PIPE HUP
# func_trap() {
#     :
# }

    # -f) {
        # FAST=y
        # shift
    # }
    # ;;

# If this option is provided, skip all the bs below
# Scan over all options
: ${FAST:="n"}
# FAST=n

if test "$DEBUG_MODE" = "y"; then
    set -v
    export DEBUG_MODE=y
fi

displayedname() {
    # display the last bit, swap with capitalized hostname if localhost
    sed -e 's/^.*_//' -e "s/^localhost$/$(hostname | sed 's/[^ _-]*/\u&/g')/"
}

extra_exports=
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -f) {
        FAST=y
        shift
    }
    ;;

    -export) {
        extra_exports+=" $2 "
        shift
        shift
    }
    ;;

    -debug) {
        set -v
        export DEBUG_MODE=y
        shift
    }
    ;;

    *) break;
esac; done

editor() {
    if e running; then
        e c "$1"
    else
        v "$1"
    fi
}


init-tm() {
    # set -xv
    export FORCE
    # CWD="$NOTES" tmux new -d

    # tmux new -d -c "$NOTES" -s localhost # disable when not forcing
    $HOME/scripts/tm ns $(test "$FORCE" = "y" && printf -- "%s\n" "-f") -np -r -l -d -c "$HOME/notes" -n localhost "$shell"

    server="$(tm-get-server)"

    TMUX= tmux -L $server attach -t localhost:
}

        # pc|pipec|pipe-to-command|sf|select-filter|split-and-pipe|spp|\

# DO NOT put capture in this list
# Skip the initial options to find first command but don't shift.
# -te -d
for arg in "$@"; do case "$arg" in
    # These commands enable fast by default
    cat|cat-pane|\
        fzf|\
        pipe-pane|\
        get-pane|get-session|\
    goto-fzf|\
    filter|\
    man|\
    tw|w|h|v|\
    avy|easymotion|search|nv-wrap|capture-stdout|capture-stdout-wrap|\
    xp|type|typeclip|\
    cap|capp|cap-pane|capture|\
    copy-current-line|\
    editsession|\
    send-keys|\
    click|em-click|regex-find|regex-find-coord|regex-click|click-wrap|\
    ep|edit-paste|vp|vipe-paste|\
    edit-file|\
    scrape-filter|\
    scrape-things|\
    scrapep|\
    vipe|eipe|pipe|tv|ntv|tvs|\
    lw|previous-window|next-window|\
    open-dirs|\
    find-window-from-session|\
    open-files|\
    open-list-of-files-in-emacs|\
    open-list-of-files-in-windows|\
    pns|pane-status|rsp|n|notify|\
        copy-pane-name|copy-pane-id|\
        recent-isues|sel|select|\
        dv|display-var|mru|most-recently-used|\
        session-exists|target-exists|\
        shpvs|shpv|show-pane-variable|\
        op|shortcuts|d|dir|directories|\
        s|src|source-files|ranger|\
        calc|saykeyunbound|edit-x-clipboard|\
        tnf|new-file|new-script|config) {

        # config breaks if I put it in this list
        # I'll try put it in again

        FAST=y
        break
    }
    ;;

    nwf)
        tmux neww zsh
        exit 0
    ;;

    init) {
        init-tm
        exit 0
    }
    ;;

    -*) continue
    ;;

    *) break
    ;;
esac; done


plf() {
    printf -- "%s\n" "$@"
    return 0
}

shell="bash; pak ."
shell="zsh"


# I should be writing code like this but in elisp because it is
# self-documenting. I can then use batch-mode to actually run the
# commands outside of elisp. However, I will have nice documentation for
# all the commands inside of emacs.
#
#!/usr/bin/emacs --script

# If tmux is not running then start a server.
# tmux info | ns
# ns "$?"
# exit 0
if ! test "$FAST" = y && ! tmux info &> /dev/null; then # it's important to have the tmux info check here to prevent infinite init loop
    # ns "tmux not running..."
    # exit 0
    init-tm
    exit 0
fi

# Usage: $0 -h

invocation="$0 $@"


# This will cause an infinite loop
#tm n "$CWD"


# Also need to think about trapping things
# Does everything quit gracefully when I do a C-c ?


# Create a new system of organising tmux windows. Abstract everything.
# Create as many abstractions around terminals and text as I can.
# Use languages for their features.

export EDITOR=v

# Display is not necessary
DISPLAY=:0

# If launched from emacs then this is different. Therefore, ensure path
# starts like this

if ! test "$FAST" = "y"; then
    . $HOME/.shell_environment
    . $HOME/scripts/libraries/bash-library.sh
fi

is_tty() { [ -t 1 ]; }
stdout_capture_exists() { ! is_tty; }
pager() { if is_tty; then v; else cat; fi; }
stdin_exists() { ! [ -t 0 ]; }

# lit is a script that does something slightly different. as for p, maybe
# it's ok. It's not ok

# p() { printf -- "%s" "$@"; }
# pl() { printf -- "%s\n" "$@"; }

# pathmunge "$HOME/local/bin"
# pathmunge "$HOME/scripts"

# Something is adding /usr/bin to the start. Prevent that from
# happening.

# export PATH="$(lit "$PATH" | sed 's_^/usr/bin:__')"
# export PATH=${PATH#/usr/bin:} # This does actually work. The : does not mess with it
# lit "$PATH" >> /tmp/path.txt # This verifies it worked
# There is more than one! Fix this in zshrc.

if ! test "$FAST" = y; then
    # I did this in zsh. What is going on?
    PATH="$(printf -- "%s" "$PATH" | sed ':a;s_:/usr/bin:__g;ta'):/usr/bin"
    PATH="$(printf -- "%s" "$PATH" | sed ':a;s_^/usr/bin:__g;ta'):/usr/bin"
    PATH="$(printf -- "%s" "$PATH" | sed ':a;s_:/usr/bin$__g;ta'):/usr/bin"

    # This is evil. But it was added here so the correct vim opens up.
    # export PATH="$HOME/local/bin:$PATH"

    while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
        -p) { # session that called the tmux script
            CALLER_TARGET="$2"
            shift
            shift
        }
        ;;

        *) break;
    esac; done
fi

# Tmux session and pane vars are privileged.
# If not provided by parameter or by environment, work it out. It may have been exported to us.
if [ -n "$CALLER_TARGET" ]; then
    CALLER_TARGET="$CALLER_TARGET"
else
    CALLER_TARGET="$(tmux display -p "#{session_name}")"
    # ns "$CALLER_TARGET"
    # tm n "$CALLER_TARGET"
    # This is bad if used by breakp because it breaks from the 0th pane.
fi

# If not provided by parameter or by environment, work it out. It may have been exported to us.
if [ -n "$CALLER_PANE" ]; then
    CALLER_PANE="$CALLER_PANE"
else
    CALLER_PANE="$(tmux display -p "#{pane_id}")"
fi


# I may have to break up CALLER_TARGET into session, pane and window
# for use in different commands

if ! test "$FAST" = y; then

    envstring=
    # I'm putting path in here. Is that a good idea?
    # List of environment variables to send to the inner command:
    # Don't set CWD here. Because if -c is used to change directory, the
    # wrong envstring will be set

    # Is it kotlin doing this?
    # export PATH=${PATH#/usr/bin:} # kotlin prepens /usr/bin to the path. Stop this!

    # export PATH=${PATH#/usr/bin:}

    # ORIGINAL_DIR Used for tenets. I really need an option to supply a list of env vars which will

    for e in TMUX PATH PAGER EDITOR DISPLAY PYTHONSTARTUP PYTHONPATH CALLER_TARGET PARENT_SESSION_ID PARENT_WINDOW_ID PARENT_SESSION_NAME CURRENT_SESSION_NAME ORIGINAL_DIR $extra_exports; do
        eval val=\${$e}
        envstring+=" $e=\"$val\" "
    done
    envstring="export $envstring; "

fi

: ${CWD:="$(pwd)"};
# Because the folder may be deleted. i.e. git change branch
if [ -d "$CWD" ]; then
    cd "$CWD"
fi
dir="$CWD"

stdin_exists && HAS_STDIN=y
stdout_capture_exists && HAS_STDOUT=y

. $HOME/scripts/libraries/tmux-lib.sh

# tmux pane var
tpv() {
    # Retrieving pane variables is actually the same syntax as getting
    # server options

    TARGET=
    while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
        -t) {
            TARGET="$2"

            shift
            shift
        }
        ;;

        *) break;
    esac; done
    # export TARGET

    if [ -z "$TARGET" ]; then
        TARGET="$CALLER_TARGET"
    fi

    varname="$1"
    tmux display -t "$TARGET" -p "#{$varname}"
    return 0
}

# Be careful with the buffering and unbuffering. It's probably best to
# manually use them

# This should be y by default or things such as the zle will break
DETACHMENT_SENTINEL=y
# DETACHMENT_SENTINEL=n
PRESS_ANY_KEY_ON_ERROR=n
# PRESS_ANY_KEY_ON_ERROR=y

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -d) {
        DETACHMENT_SENTINEL=n

        # Prevent waiting on stdin and ignore stdout
        (  exec </dev/tty  ) &>/dev/null # I should really check this output
        HAS_STDIN=
        HAS_STDOUT=n

        shift
    }
    ;;

    -w|-s)
        DETACHMENT_SENTINEL=y; shift
    ;;

    -S) # no detachment sentinel This is different from detaching immediately. The new window is still created and switched to. But the tm command will not wait for the process to end.
        DETACHMENT_SENTINEL=n; shift
    ;;

    -te) # Use tty from piped command if possible
        {
        # exporting these is important
        HAS_STDIN=
        HAS_STDOUT=

        # If not a tty but TTY is exported from outside, attach the tty
        # tm dv "$mytty"
        if test "$mytty" = "not a tty" && ! [ -z ${TTY+x} ]; then
            printf -- "%s\n" "Attaching tty"
            exec 0<"$TTY"
            exec 1>"$TTY"
        else
            # Otherwise, this probably has its own tty and only needs normal
            # reattachment (maybe stdin was temporarily redirected)
            exec </dev/tty
        fi
        shift
    }
    ;;

    -t)
        {
        ( exec </dev/tty ) &>/dev/null # I should really check this output
        HAS_STDIN=
        HAS_STDOUT=
        shift
    }
    ;;

    #-tin)
    #    exec </dev/tty
    #    HAS_STDIN=; shift
    #;;

    -tout) { # tty out, not stdout
        HAS_STDOUT=; shift
    }
    ;;

    -fout) { # Force stdout (echo hi | tm -sout nw fzf)
        HAS_STDOUT=y; shift
    }
    ;;

    -tt) {
        # vim +/"Not sure why I need unbuffer here" "$HOME/scripts/tm"
        # Run this command again but inside a wrapper tty. Not a great
        # solution.

        invocation="$(printf -- "%s\n" "$invocation" | sed 's/ -tt\b//')"

        exec script -q --return -c "$invocation" /dev/null

        exit 0
    }
    ;;

    -u)
        UNBUFFER_IN=y
        UNBUFFER_OUT=y
        shift
    ;;

    -uin) # cat | unbuffer -p [tm nw]
        UNBUFFER_IN=y; shift
    ;;

    -uout) # unbuffer [tm nw]
        UNBUFFER_OUT=y; shift
    ;;

    -b)
        BUFFER_IN=y;
        BUFFER_OUT=y;
        shift
    ;;

    -bin)
        BUFFER_IN=y; shift
    ;;

    -bout)
        BUFFER_OUT=y; shift
    ;;

    -s)
        SPONGE_IN=y
        SPONGE_OUT=y
        shift
    ;;

    -sin) { # Maybe use -i|-stdin instead
        SPONGE_IN=y; shift
    }
    ;;

    -i|-stdin|-soak|-soak-input) {
        # soak it up BUT put it BACK into stdin

        IFS= read -rd '' input < <(cat /dev/stdin)
        # exec < <(p "$input")
        # exec < <<< "$input"

        # xxd -p <<< "foo" # not binary safe (appends newline)

        # exec < <(printf "%s" "$input")
        exec < <(s chomp <<< "$input")
        shift
    }
    ;;

    -sout)
        SPONGE_OUT=y; shift
    ;;

    -v)
        set -xv
        shift
    ;;

    *)
        break
    ;;
esac; done

# form_command() {
#     input="$(cat)"
#     p -- "%s" "stty stop undef; stty start undef; $input"
# }


debug_mode_enabled() {
    case "$-" in
        *x*) true;;
        *v*) true;;
        *) false;;
    esac
}

# set -xv
# Alias 2 before we close it. So we can restore it for fzf
exec 4>&2

# This is incredibly annoying
# if ! debug_mode_enabled; then
#     exec 2>/dev/null
# fi

# tm n "$@"

# Recreate the same tmux system because it's amazing. But don't use it
# exclusively.
# Work on new tmux systems where things are searched for. Use fuzzy
# search much more.

# I want more search.
# I want more NLP.
# I want more machine-learning.
# I want more functional programming.
# I want abstraction where everything is tensors or working towards that.
# I want to be able to retrospectively understand the things I am
# writing using NLP libraries.
# Only use abstraction this time. Build a tensorflow-based development environment.
# To do this I need:
#   a decent python development environment -- use spacemacs
# While


second_last_arg() {
    if [ "$#" -gt "1" ]; then
        n=$(($#-1))
        eval ARG=\${$n}
        plf "$ARG"
    fi
}

last_arg() {
    if [ "$#" -gt "0" ]; then
        n=$(($#-0))
        eval ARG=\${$n}
        plf "$ARG"
    fi
}

session_list() {
    tmux list-sessions | sed '/^[^:]\+:/ s/^\([^:]\+\).*/\1/'
    return 0
}

# ! test "$FAST" = "y" && tmux set -t "$CALLER_TARGET" set-remain-on-exit off

f="$1"
shift

case "$f" in
    config|fzf-config) {
        exec 2>&4

        cd "$NOTES" # I may not want this
        # config-files.txt
        # this syntax is zsh only: sources{s,}\.*

        paths='files\.* source?(s)\.*'
        paths="$(shopt -s nullglob; shopt -s extglob; eval printf -- "%s\\\n" "$paths" | qargs)" # expand
        paths_tf="$({ plf "$paths"; find $NOTES -type f -name 'config.txt'; } | xargs cat1 | scrape-files-fast.sh | mnm | tf txt)"

        # lit "$paths" | less

        # TTY="$(tty)"
        # export TTY
        # exec </dev/tty

        selection="$(cat "$paths_tf" | s uniq | soak | fzf -p)"

        ! [ -n "$selection" ] && exit 0

            # tm -te dv "open $selection"
            # tm n "$selection"
            # exit 0

            # p -- "%s\n" "$selection"
            # p "open $selection" | tm -tout -S nw -cin

        # tm -d -te -S nw -noerror "open -e $(aqf "$selection")"
        tm -d -te -S nw -noerror "open -e $(aqf "$selection")"

            # pak
            # | tm -tout nw -pak "vim -"
        exit 0

        ge "$selection"
    }
    ;;

    fz-s|fzf-scripts) {
        exec 2>&4

        selection="$(u lx $HOME/scripts | fzf | u whichname)"
        ! [ -n "$selection" ] && exit 0

        # p -- "%s\n" "$selection"

        ge "$selection"
    }
    ;;

    findrun) {
        exec 2>&4
        selection="$(list-executables | fzf)"
        wp="$(which "$selection")"

        # p -- "%s\n" "$wp"

        tm run "$wp"

        # bind -n F13 neww -t localhost: -n "run" 'tm findrun'
    }
    ;;

    em-click) { # easymotion click
        # Requires this patch: $HOME/notes2018/ws/tm/patches/em-click.diff

        cap_file="$(tm cap | tf txt; sleep 0.5)"
        if [ -s "$cap_file" ]; then
            tm -te nw -n em-click "v -c 'set foldcolumn=0 ls=0 | call EasyMotion#WB(0,2) | q!' \"$cap_file\""

            x="$(cat /tmp/em-click.txt | cut -d ' ' -f 1)"
            y="$(cat /tmp/em-click.txt | cut -d ' ' -f 2)"

            if [ -n "$x" ] && [ -n "$y" ]; then
                # notify-send "$loc"
                x=$((x - 1))
                y=$((y - 1))
                tm click-wrap $x $y
            fi
        fi

        # Need to obtain coordinates here. Thene run: "tm click -t %570 0 0"
        # $HOME$VIMCONFIG/vim/pack/myplugins/start/vim-easymotion-new/autoload/vital/easymotion.vim

        exit 0
    }
    ;;

    regex-find-coord) {
        # get coordinates
        # tm n "$f :: NOT IMPLEMENTED"

        last_arg="${@: -1}"
        regex="$last_arg"

        # shift last arg
        set -- "${@:1:$(($#-1))}"

        : ${LITERAL:="n"}
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -t) {
                TARGET="$2"
                shift
                shift
            }
            ;;

            -l) {
                LITERAL=y
                shift
            }
            ;;

            *) break;
        esac; done

        : ${TARGET:="$TMUX_PANE"}

        ## for -nohist and -t
        #CMD="$(
        #for (( i = 1; i < $#; i++ )); do
        #    eval ARG=\${$i}
        #    printf -- "%s" "$ARG" | q
        #    printf ' '
        #done
        #eval ARG=\${$i}
        #printf -- "%s" "$ARG" | q
        #)"

        # eval "tm -te -d capture $CMD -clean -"

        if test "$LITERAL" = "y"; then
            # eval "tm cap-pane $CMD -clean -nohist" | pcre-pos.pl "$regex"
            tm cap-pane "$@" -clean -nohist | pcre-pos.pl "$regex"
        else
            #eval "tm cap-pane $CMD -clean -nohist" | exact-pos.pl "$regex"
            tm cap-pane "$@" -clean -nohist | exact-pos.pl "$regex"
        fi

        exit 0
    }
    ;;

    # tm regex-click -t "%617" regex
    regex-click) {

        ALL=n # click everything that matches
        LITERAL=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -t) {
                TARGET="$2"
                shift
                shift
            }
            ;;

            -a) {
                ALL=y
                shift
            }
            ;;

            -l) {
                export LITERAL=y # for "tm regex-find-coord"
                shift
            }
            ;;

            *) break;
        esac; done

        re="$1"
        shift

        results="$(tm regex-find-coord -nohist -t "$TARGET" "$re" | tv)"

        if test "$ALL" = "y"; then
            printf -- "%s\n" "$results" | awk1 | while IFS=$'\n' read -r line; do
                printf -- "%s\n" "$line" | xargs tm click -t "$TARGET"
                sleep 0.1
            done
        else
            printf -- "%s\n" "$results" | head -n 1 | xargs tm click -t "$TARGET"
        fi

        exit 0
    }
    ;;

    click-wrap) { # start wrapper and then click on it
        swidth="$(tmux display -t "$CALLER_TARGET" -p "#{session_width}")"
        sheight="$(tmux display -t "$CALLER_TARGET" -p "#{session_height}")"
        sheight="$(( sheight + 2 ))"

        server="$(tm-get-server)"

        # Don't use tm attach, to make this faster.
        tmux new-session -d -x "$swidth" -y "$sheight" -A -s wrap \; respawnp -k -t "wrap:1" "TMUX= tmux -L $server attach -t \"$CALLER_TARGET\""

        [ -n "$1" ] && x="$1" && shift
        [ -n "$1" ] && y="$1" && shift

        tm click -t "wrap:1" "$x" "$y"

        tmux kill-pane -t "wrap:1.0"
    }
    ;;

    ac|asciinema) {
        # Maybe don't make it smaller.

        # trap sigwinch so tmux cant get it.
        # Start an invisible tmux that wraps the current session
        # do something like click-wrap

        swidth="$(tmux display -t "$CALLER_TARGET" -p "#{session_width}")"
        sheight="$(tmux display -t "$CALLER_TARGET" -p "#{session_height}")"
        sheight="$(( sheight + 2 ))"

        caller_slug="$(printf -- "%s" "$CALLER_TARGET" | slugify)"

        server="$(tm-get-server)"

        cmd="x -s \"asciinema rec\" -c m -e \"»\" -s \"TMUX= tmux -L $server attach -t \$(aqf \"$CALLER_TARGET\")\" -c m -i"

        tmux new-session -d -c "$CWD" -x "$swidth" -y "$sheight" -A -s "cinema-$caller_slug" \; respawnp -k -t "cinema-$caller_slug:1" "$cmd"

        xt -b tmux attach -t "cinema-$caller_slug"
    }
    ;;

    # tm click -t %570 0 0
    click) {
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -t) {
                TMUX_PANE="$2"
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        [ -n "$1" ] && x="$1" && shift
        [ -n "$1" ] && y="$1" && shift

        if [ -n "$TMUX_PANE" ] && [ -n "$x" ] && [ -n "$y" ]; then
            tmux send-keys -t "$TMUX_PANE" -l "$(xterm-click -d $y $x)"
            sleep 0.2
            tmux send-keys -t "$TMUX_PANE" -l "$(xterm-click -u $y $x)"
        fi
        exit 0
    }
    ;;

    goto-fzf) {
        # jumplist -- in the future I colud have a general-purpose command panel, maybe

        # I need a menu that returns something.
        # A selection system.

        # tm -d spv "sh-tmux-hydra"

        eval "tmux run -b $(aqf "tm find-window-from-session -no-activate")"
    }
    ;;

    start) {
        attach=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -a) {
                attach=y
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        # exit 0

        # This is killing my machine with lots of infinite loops
        # exit 0

        notify-send "Starting emacs"

        unbuffer e -startall

        unbuffer bash -xv e -startall

        # Must wait for this to finish before starting tmux sessions
        # Although, this appears to take forever.
        # Therefore, with 'open' only use emacs if the server is
        # available

        if ! tm session-exists localhost; then
            tm ns -np -r -l -d -c "$HOME/notes" -n localhost "$shell"

            # Cannot put new window creation in this function. Start is
            # meant to be immutable so it can be called many times, when
            # a new xterm is created.
            # # How is this being called write?
            # # this should open up as the folder is sourced
            # tm -d nw -d -n closh closh
            # tm -d nw -d -n hy hy
        fi
        tm attach localhost
    }
    ;;

    target-exists) {
        tm n "$f :: NOT FULLY IMPLEMENTED"

        # Need support for checking if windows and panes exist.
        # Use in rsp|respawn-pane) {

        tmux has-session -t "$1:"
        exit $?
    }
    ;;

    session-exists) {
        # session_list
        # exit 0
        # session_list | s one-of "$1"

        # exit $?

        # Must be done like this because of error code
        sessions="$(session_list)"
        printf -- "%s" "$sessions" | s one-of "$1"
        exit $?
    }
    ;;

    bp-other|bpo) { # breakp -other
        tm n "$f :: Use 'bp -o'"
        # new_window="$(tmux neww -F "#{pane_id}" -P -s "$CALLER_PANE")"
    }
    ;;

    bp|breakp) {
        while :; do opt="$1"; case "$opt" in
            -r|-reserve) {
                RESERVE=y
                shift

                # bind M-b run 'tmux-breakpane.sh'
            }
            ;;

            -o|-other) { # other panes
                OTHER=y
                shift

                # bind M-! run 'tmux-break-other-panes.sh'
            }
            ;;

            *) break;

        esac; done

        if test "$OTHER" = "y"; then
            notify-send "$CALLER_PANE"
            win_name="$(tmux display -p "#W")"
            new_window="$(tmux neww -F "#{window_id}" -P "echo originally: $CALLER_PANE | rosie match all.things | less -r")"
            tmux swap-window -s "$CALLER_PANE" -t "$new_window" \; \
                 rename-window -t "$new_window" "$win_name" \; \
                 rename-window -t "$CALLER_PANE" "[broke$CALLER_PANE]" \; \
                 swap-pane -s "${new_window}.0" -t "$CALLER_PANE"

            exit 0

        elif test "$RESERVE" = "y"; then
            # TODO Make it so breaking a placeholder pane should take
            # you to the broken pane.

            # Need to do completely differently
            # Create a new window, then swap the panes.
            # Then respawn the original pane

            CALLER_PANE="$(tmux display -p "#{pane_id}")"
            window_name="$(tmux display -p "#{window_name}")"

            if printf -- "%s" "$window_name" | grep -q -P '^%'; then
                tmux swap-pane -s "$window_name" -t "$CALLER_PANE" && \
                    tmux kill-pane -t "$window_name"
                tmux select-window -t "CALLER_PANE"
                exit 0
            fi

            # If the name starts with '%' then swap the panes back to
            # their original places

            # new_pane="$(tmux neww -d -F "#{pane_id}" -P "echo placeholder for: $CALLER_PANE | rosie match all.things | less -r")"
            new_pane="$(tmux neww -d -F "#{pane_id}" -P "echo | rosie match all.things | less -r")"

            tmux swap-pane -s "$new_pane" -t "$CALLER_PANE"
            tmux rename-window -t "$CALLER_PANE" "$new_pane"

            tmux respawn-pane -k -t "$new_pane" "echo placeholder: $new_pane | rosie match all.things | less -r"

            tmux select-window -t "$CALLER_PANE"

            # new_pane="$(tmux break-pane -F "#{pane_id}" -P -s "$CALLER_PANE")"
            # tmux select-window -t "$new_pane"
            # tmux rename-window -t "$new_pane" "[broke$new_pane]"

            # notify-send "reserve $CALLER_PANE $new_pane"
            exit 0

        else
            # This does not get the current pane. How annoying!
            #CALLER_PANE="$(tmux display -t "$CALLER_TARGET" -p "#{pane_id}")"

            # This gets current pane
            CALLER_PANE="$(tmux display -p "#{pane_id}")"
            # tm n "$CALLER_PANE"
            # exit 0

            new_window="$(tmux break-pane -F "#{pane_id}" -P -s "$CALLER_PANE")"
            # This should be happening but it's not.
            # Ahh, it's because tm breakp uses caller_target which is
            # not the pane. it's the session
            tmux select-window -t "$new_window"
            tmux rename-window -t "$new_window" "[broke$new_window]"
        fi
    }
    ;;


    # xclip → tmux
    xc) {
        exec 2>/dev/null
        exec 1>/dev/null
        #tmux load-buffer -b myclipboard =(unbuffer xc)
        zsh --no-rcs -c "tmux load-buffer =(unbuffer xc)"
    }
    ;;

    # tmux → xclip
    xv) {
        # exec 2>/dev/null
        # exec 1>/dev/null
        zsh --no-rcs -c "tmux save-buffer - | xc"
    }
    ;;

    # I need a way to store strings into registers arbitrarily.
    # Multiple clipboards. Use temporary files. Use xc.
    # xc -r a
    # xc -r something

    # I need to get freaky good with shell and haskell.
    # Keep adding abstraction.

    ask) {
        :
        # Ask for something.
        # Replace this with a separate program.

        # Register
        # tmux command-prompt -p man "new-window -n man-%1 \"exec m man %1\""
    }
    ;;

    # $HOME/scripts/m
    man) {
        program="$1"
        PROGRAM="$1"; : ${PROGRAM:="runit"}
        #tmux command-prompt -p man "new-window -n man-%1 \"exec m man %1\""
        # tmux command-prompt -p man "new-window -n man-%1 \"exec nv -2 \\\"tmux new \\\\\\\"m u %1\\\\\\\"\\\"\""

        # tmux command-prompt -p man "new-window -n man-%1 \"m u %1\""


        # tmux command-prompt -p man "splitw \"m u %1\""

        tmux command-prompt -p man "splitw \"sh-man %1\""
    }
    ;;

    # paste from x clipboard
    xp) {
        # x clip paste
        zsh --no-rcs -c "tmux load-buffer -b myclipboard =(unbuffer xc)"
        tmux paste-buffer -pr -b myclipboard

        # -r do not replace LF with CR
        # -p brackets
    }
    ;;

    ep|edit-paste|vp|vipe-paste) {
        # tm sph "echo -n '' | vipe" | cat
        zsh --no-rcs -c "tmux load-buffer -b myclipboard =(tm sph \"echo -n '' | vipe\" | cat | s chomp)"
        #tmux paste-buffer -pr -b myclipboard

        # Don't use paste brackets
        tmux paste-buffer -r -b myclipboard

        # -r do not replace LF with CR
        # -p brackets
    }
    ;;

    ta) {
        name=$(last_arg "$@")

        if [ -n "$name" ]; then
            source ~/.shell_environment
            tmux attach -t "$name"
        else
            source ~/.shell_environment
            tmux attach
        fi
    }
    ;;

    ta-local) {
        ta localhost
        exit 0
    }
    ;;

    shpv|show-pane-variable) {
        shpv "$1"
    }
    ;;

    cursor) {
        ## tm is heavy
        # tm shpv "cursor_x"
        # tm shpv "cursor_y"
        tmux display -t "$CALLER_TARGET" -p "#{cursor_x}"
        tmux display -t "$CALLER_TARGET" -p "#{cursor_y}"
    }
    ;;

    shpvs|show-pane-variables) {
        shpvs
    }
    ;;

    pns|pane-status) {
        # tmux status

        # It would be much nicer if I could put this into json
        # Need DSLs for this

        {
            shpvs

            plf

            pid="$(tpv pane_pid)"

            plf "pid: $pid"

            plf

            plf "pwd: $(pwd)"
            echo

            cmd="pstree -lAsp \"$pid\""
            plf "$cmd"
            eval "$cmd"
            echo

            cmd="pstree -alAsp \"$pid\""
            plf "$cmd"
            eval "$cmd"
            echo

            plf "Open files"
            pstree -lAp "$pid" | \
                sed 's/\(([0-9]\+)\)/(\n\1\n/g' | \
                sed -n '/([0-9]\+)/ s/[^0-9]//pg' | \
                while read pid; do
                    lsof -p $pid | sed 's/ \+/ /g' | cut -d ' ' -f9- | sed '1d';
                done | s uniq | grep -v /lib/

            # lsof

        } | mnm | tm -tout -i -S nw v

        # Introspection on anything running in any terminal
    }
    ;;

    xta) {
        # just pass the -b onward
        
        xt_opt=

        opt="$1" # it might not be opt though. it might be target
        case "$opt" in
            -b|-h) { xt_opt=$opt; shift; } ;;
        esac

        last_arg="${@: -1}"
        name="$last_arg"
        : ${name:="localhost:"}

        # lit "$name" | xtv

        # This needs fixing

        if [ -n "$name" ]; then
            xt $xt_opt tm ta "$name"
        else
            xt $xt_opt tm ta
        fi
    }
    ;;

    ts) {
        # This is run but when logging in start is also run
        tm start

        tm ta localhost
    }
    ;;

    # new background session
    nds|nbgs) {
        server="$(tm-get-server)"

        unset TMUX

        if [ -n "$3" ]; then
            # name, dir, command
            tmux new-session -d -s "$1" -c "$2" "$3"
        elif [ -n "$2" ]; then
            # name, dir
            tmux new-session -d -s "$1" -c "$2"
        elif [ -n "$1" ]; then
            # name
            tmux new-session -d -s "$1"
        else
            tmux new-session -d
        fi
    }
    ;;

    # This is not notify-send. It's new-session. But that isn't clear.
    # Avoid using "tm ns"
    ns|new-s|new-session) {
        server="$(tm-get-server)"

        unset TMUX
        # set -xv

        HIGHLIGHT=
        HAS_PARENT=y # Default action is to create a subsession (but a subsession in the new-window sense)
        RECURSIVE=n
        ATTACH=n
        SELECT=n
        # TARGET=
        force_create_session=n
        session_name=
        session_title=
        : ${REPEAT_COMMAND:="n"}
        : ${AUTO_RETRY:="n"}
        PRESS_ANY_KEY_FINISH=y
        REMAIN_ON_EXIT=n
        RETRY_SLEEP=0
        # Unfortunately, this simply creates more windows than tmux can
        # handle atm. I don't want to disable it by default
        : ${G_AUTOFILES:="y"} # global autofiles
        : ${L_AUTOFILES:="y"} # local autofiles
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -a) { # Attach to the parent session
                ATTACH="y"
                shift
            }
            ;;

            -f) { # if the session name already exists, use this
                force_create_session="y"
                shift
            }
            ;;

            -A) {
                G_AUTOFILES="y"
                L_AUTOFILES="y"
                shift
            }
            ;;

            -w) {
                HIGHLIGHT=warn
                shift
            }
            ;;

            -hlgreen) {
                HIGHLIGHT=green
                shift
            }
            ;;

            -hlblue) {
                HIGHLIGHT=blue
                shift
            }
            ;;

            -hlred) {
                HIGHLIGHT=red
                shift
            }
            ;;

            -paks|-pakstart) {
                PRESS_ANY_KEY_START=y
                shift
            }
            ;;

            -na) {
                G_AUTOFILES=n
                L_AUTOFILES=n
                shift
            }
            ;;

            -s) {
                ATTACH="y"
                SELECT="y"
                shift
            }
            ;;

            -R|-repeat) {
                REPEAT_COMMAND=y
                PRESS_ANY_KEY_FINISH=y
                shift
            }
            ;;

            -A|-autoretry) {
                REPEAT_COMMAND=y
                PRESS_ANY_KEY_FINISH=n
                RETRY_SLEEP=2
                shift
            }
            ;;

            -r|-roe) {
                # This is evil. Use PAK
                # REMAIN_ON_EXIT="y"
                :
                shift
            }
            ;;

            -l) {
                RECURSIVE="y"
                shift
            }
            ;;

            -d) {
                SELECT="n"
                shift
            }
            ;;

            -np) {
                HAS_PARENT="n"
                shift
            }
            ;;

            # Need to be able to specify that this session has a parent
            # because many do not.

            -t|-p) { # parent session
                # HAS_PARENT="y"
                TARGET="$2"
                shift
                shift
            }
            ;;

            -c) {
                # This expands the glob
                dir="$(eval echo -e "$2")" # expand
                dir="$(realpath "$dir")"
                CWD="$dir"
                mkdir -p "$CWD"
                cd "$CWD"
                export CWD

                envstring+="export CWD=\"$CWD\"; "

                # : ${CWD:="$(pwd)"}; cd "$CWD"

                shift
                shift
            }
            ;;

            -n) {
                session_name="$2"
                shift
                shift
            }
            ;;

            -T|-title) {
                session_title="$2"
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        CMD="$(
        for (( i = 1; i < $#; i++ )); do
            eval ARG=\${$i}
            printf -- "%s" "$ARG" | q
            printf ' '
        done
        eval ARG=\${$i}
        printf -- "%s" "$ARG" | q
        )"

        if [ -z "$CWD" ]; then
            : ${CWD:="$(pwd)"}; cd "$CWD"
        fi

        d_bn="$(basename "$CWD")"

        # tm dv "$CWD"

        if [ -z "$session_name" ]; then
            if [ $# -gt 0 ]; then
                session_name="$d_bn/$1"
            else
                session_name="$d_bn"
            fi
        fi
        # lit "$session_name"
        # exit 0

        # Consider prepending CALLER_TARGET to session_name here.
        if test "$HAS_PARENT" = "y"; then
            # this is not always the correct PARENT_SESSION_NAME. if you
            # call "tm ns" using key bindings then it gets the
            # grandparent
            session_name="${PARENT_SESSION_NAME}_${session_name}"
        fi

        # Sometimes I do not want a parent session so only set this if
        # we are forcefully finding the parent session.
        # TARGET is the session we want to create windows and
        # subsessions for. I think this code is outdated. Test what
        # happens if I comment this out
        if [ -z "$TARGET" ] && test "$HAS_PARENT" = "y"; then
            TARGET="$CALLER_TARGET"

            # Ensure this is a session name
            TARGET="$(tmux display-message -p -t "$TARGET" '#{session_name}')"
        fi

        # tm dv "$session_name $CWD"

        # exec 2>&4

        session_exists=n


        # This doesn't work yet because I still need to make new-session
        # able to be respawned
        # if test "$REPEAT_COMMAND" = "y"; then
        #     cmd_pre="while :; do $cmd_pre"
        #     cmd_post="$cmd_post; done"
        # fi


        tm -f session-exists "$session_name" && session_exists=y
        # This log goes into the new window. Create a new tm function
        # for this.
        if ! test "$session_exists" = "y" || test "$force_create_session" = "y"; then
            # So we don't get an error
            mkdir -p "$CWD"
            displayed_name="$(printf -- "%s" "$session_name" | displayedname)"

            # status-left must remain as this so capture works
            CWD="$CWD" tmux new-session -d -s "$session_name" -c "$CWD" "zsh" \; \
                setenv -t "$session_name" "TM_SESSION_NAME" "$session_name" \; \
                setenv -t "$session_name" "PARENT_SESSION_ID" "$PARENT_SESSION_ID" \; \
                setenv -t "$session_name" "PARENT_SESSION_NAME" "$PARENT_SESSION_NAME" \; \
                setenv -t "$session_name" "PARENT_WINDOW_ID" "$PARENT_WINDOW_ID" \; \
                setenv -t "$session_name" "CWD" "$CWD" \; \
                set -t "$session_name" status-left "[ $displayed_name ]  "

            # When I source a .tmux.sh file, this should happen
            # automatically.
            # No need for this
            # export CALLER_TARGET

            if test "$HAS_PARENT" = "y"; then
                :
                # This is excruciatingly slow
                # if test "$REMAIN_ON_EXIT" = "y"; then
                #     tmux set -t "$TARGET" set-remain-on-exit on
                # else
                #     tmux set -t "$TARGET" set-remain-on-exit off
                # fi
            fi
            export CURRENT_SESSION_NAME="$session_name"
            export PARENT_SESSION_NAME="$session_name"

            if [ -n "$PARENT_SESSION_NAME" ]; then
                PARENT_SESSION_ID="$(tmux display-message -p -t "$session_name:" '#{session_id}')"
            fi
            export PARENT_SESSION_ID

            # I should make this more robust by using window ID instead of a
            # name
            if test "$RECURSIVE" = "y"; then
                # . .tmux.sh;

                # Create the subsession
                # tm ns -r -s -c ../scripts
                # tm ns -r -d -c "$CWD" -n "$session_name" "$shell"
                # This is not where it happens. The commands are run from
                # .tmux.sh files

                # I want autofiles to happen before tmux.sh

                (
                    export TARGET="$session_name"
                    cd "$CWD"

                    test -f ".tmux-pre.sh" && source ".tmux-pre.sh"

                    case "$AUTOFILES" in
                        n) {
                            G_AUTOFILES=n
                            L_AUTOFILES=n
                        }
                        ;;

                        y) {
                            G_AUTOFILES=y
                            L_AUTOFILES=y
                        }
                        ;;

                        *)
                    esac

                    # DISCARD: The autofiles do not actually use full_id
                    # because they do not launch subsessions

                    # After creating the new window, I need to tell the
                    # subsession what its window id is, because it
                    # won't know. But this must also work for windows
                    # created with tm nw, as in .tmux.sh

                    # ID_FORMAT="#{session_id}:#{window_id}.#{pane_id}"

                    # Having less as a preview will prevent the recent files
                    # from getting clogged up with .org files.

                    # TODO Fix this up
                    # Combine autofiles lists. Local first.
                    # Get the 'set difference' to the existing window
                    # names.

                    # Do this later
                    # existing_windows="$(tmux list-windows -F '#{window_name}')"
                    # Don't use "s uniq", I need the "set difference".

                    #  Remember there is an elisp library for common-lisp functions
                    # (require 'cl)
                    # (set-difference '(1 2 3) '(2 3 4))

                    # Common lisp: (set-difference '(1 2 3) '(2 3 4))
                    # unopenend_global_autofiles="$({ printf -- "%s\n" "$existing_windows"; lsautofiles -g } | s uniq)"

                    # I want to combine 2 lists

                    if test "$G_AUTOFILES" = "y"; then
                        CWD="$CWD" lsautofiles -g | awk 1 | while IFS=$'\n' read -r line; do
                            if test -f "$line"; then
                                # full_id="$(tm -d -te nw -F
                                # "$ID_FORMAT" -P -hlgreen -R -nopakf -n "$line" -c "$CWD" "preview $(aqf "$line"); python $HOME$MYGIT/ranger/ranger/ranger/ext/rifle.py \"$line\"")"

                                tm-open-file-green "$line"

                            elif test -d "$line"; then
                                line="$(printf -- "%s" "$line" | qne)"

                                # full_id="$(tm -d -te nw -F "$ID_FORMAT" -P -hlgreen -R -nopakf -n "$line" -c "$CWD" "ls \"$line\" | less -S; ranger \"$line\"")"

                                # Old way: open ranger
                                # tm -d -te nw -hlgreen -R -nopakf -n "$line" -c "$CWD" "ls \"$line\" | less -S; ranger \"$line\""

                                REPEAT_COMMAND=y tm ns -hlred -r -l -s -c "$line"
                            fi
                        done
                    fi

                    test -f ".tmux.sh" && source ".tmux.sh"

                    if test "$L_AUTOFILES" = "y"; then
                        CWD="$CWD" lsautofiles -l | awk 1 | while IFS=$'\n' read -r line; do
                            if test -f "$line"; then
                                line="$(printf -- "%s" "$line" | qne)"
                                # full_id="$(tm -d -te nw -F "$ID_FORMAT" -P -hlblue -R -nopakf -n "$line" -c "$CWD" "less -S \"$line\"; python $HOME$MYGIT/ranger/ranger/ranger/ext/rifle.py \"$line\"")"
                                tm -d -te nw -hlred -R -nopakf -n "$line" -c "$CWD" "preview $(aqf "$line"); python $HOME$MYGIT/ranger/ranger/ranger/ext/rifle.py \"$line\""
                            elif test -d "$line"; then
                                line="$(printf -- "%s" "$line" | qne)"
                                # full_id="$(tm -d -te nw -F "$ID_FORMAT" -P -hlblue -R -nopakf -n "$line" -c "$CWD" "ls \"$line\" | less -S; ranger \"$line\"")"

                                # Old way: open ranger
                                # tm -d -te nw -hlblue -R -nopakf -n "$line" -c "$CWD" "ls \"$line\" | less -S; ranger \"$line\""

                                REPEAT_COMMAND=y tm ns -hlred -r -l -s -c "$line"
                            fi
                        done
                    fi

                    # setenv -t "$session_name" "PARENT_SESSION_ID" "$PARENT_SESSION_ID" \; \

                    # af="$(cat "$HOME/notes2018/programs/tm/autofiles.txt")"

                    # ls | awk 1 | while read -r bn; do
                    #     printf -- "%s\n" "$af" | awk 1 | while read -r pat; do
                    #         if printf -- "%s\n" "$rp" | grep -q -P "$pat"; then
                    #             :
                    #         fi
                    #     done
                    # done
                )

                # test -f .tmux.sh && sh .tmux.sh
            fi

            # This is the sh window. I should respawn it with a command
            # instead
            if [ $# -gt 0 ]; then
                tmux respawnp -k -t "$session_name:1.0" "$CMD"
            fi
        fi

        # lit $TARGET $session_name
        # exit 0

        tmux setenv -t "$session_name" "CWD" "$CWD"
        # tmux kill-window "$session_name:1"

        if test "$ATTACH" = "y"; then
            cd "$CWD"

            # If I want this to start the entire session again I need to
            # create a new tmx source
            # tm -d nw $(test "$REMAIN_ON_EXIT" = "y" && p "-r") -d -t "$TARGET:" -n "$session_name" -c "$CWD" "tm -f ssa \"$session_name:\""
            # echo "tm -d nw $(test \"$REMAIN_ON_EXIT\" = \"y\" && p
            # \"-r\") -d -t \"$TARGET\" -n \"$session_name\" -c \"$CWD\"
            # \"tm attach \\\"$session_name:\\\"\""
            # exit 0

            # An extra command at the end (sleep) is required to prevent
            # the server from crashing.

            if test "$HAS_PARENT" = "y"; then
                export HIGHLIGHT
                roe_para="$(test "$REMAIN_ON_EXIT" = "y" && printf -- "%s" "-r")"
                full_id="$(tm -d nw -P $roe_para -d -t "$TARGET" -n "$displayed_name" -c "$CWD" "tm attach $(aqf "$session_name"); sleep 0.1")"
                # tm -d nw $(test "$REMAIN_ON_EXIT" = "y" && printf -- "%s" "-r") -d -t "$TARGET" -n "$displayed_name" -c "$CWD" "tm attach \"$session_name\"; sleep 0.1"

                tmux setenv -t "$session_name:" "PARENT_WINDOW_ID" "$full_id"
            else
                tm attach "$session_name"
            fi

            if test "$SELECT" = "y" && test "$HAS_PARENT" = "y"; then
                tmux selectw -t "$TARGET:$displayed_name"
            fi
        fi

        if test "$HAS_PARENT" = "y"; then
            # Never use this. It's slow at hell and makes tmux unstable
            # tmux set -t "$TARGET" set-remain-on-exit off
            # echo "$TARGET" >> /tmp/tmux-targets.log
            :
        fi

        exit 0
    }
    ;;

    # Use: tm-open-file-green
    #open-file-green) {
    #    fp="$1"

    #    tm -d -te nw -hlgreen -R -nopakf -n "$fp" -c "$CWD" "less -S $(aqf "$fp"); python $HOME$MYGIT/ranger/ranger/ranger/ext/rifle.py $(aqf "$fp")"
    #}
    #;;

    vt100) {
        session_name="$1"

        # This appears to not get the job done
        export TERM=screen-2color

        if [ -z "$CWD" ]; then
            : ${CWD:="$(pwd)"}; cd "$CWD"
        fi

        tm attach "$session_name" || {
            true
            # export TARGET="$session_name"
            # source "$CWD/.tmux.sh"
        }
        exit $?
    }
    ;;

    attach) {
        session_name="$1"

        if [ -z "$session_name" ]; then
            session_name=localhost
        fi

        server="$(tm-get-server)"

        # Because, annoyingly, you can't specify an exact name
        if tm session-exists $session_name; then
            TMUX= tmux -L $server attach -t "$session_name:" || {
                true
                # export TARGET="$session_name"
                # source "$CWD/.tmux.sh"
            }
        elif test "$session_name" = "localhost"; then
            tm ns -r -l -d -c "$HOME/notes" -n localhost "$shell"
            TMUX= tmux -L $server attach -t "$session_name:" || {
            true
        }
    else
            lit "session: $session_name does not exist"
            pak c
        fi
        exit $?
    }
    ;;

    ssa|source-session-attach) {
        session_name="$1"

        if [ -z "$CWD" ]; then
            : ${CWD:="$(pwd)"}; cd "$CWD"
        fi

        tm attach "$session_name" || {
            true
            # export TARGET="$session_name"
            # source "$CWD/.tmux.sh"
        }
        exit $?
    }
    ;;

    kp) {

        # This kills everything.
        #tmux kill-pane -t "$CALLER_TARGET"

        # tm n "$CALLER_TARGET $CALLER_PANE"

        # This does not kill everything

        if [ -n "$CALLER_PANE" ]; then
            tmux kill-pane -t "$CALLER_PANE"
        else
            tmux kill-pane
        fi
    }
    ;;

    editsession) {
        # env | less
        # v .tmux.sh

        tm -te nw "v .tmux.sh"
    }
    ;;

    type) {
        printf -- "%s" "$1" |
        while IFS= read -N 1 char; do
            # Just do it
            tmux send-keys -l "$char"
        done
    }
    ;;

    typeclip) {
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -u) {
                window_name="$2"
                shift
            }
            ;;

            -j) {
                # Not sure what -j does
                :

                shift
            }
            ;;

            *) break;
        esac; done

        # At the moment, cheat and do the exact some thing as tm xp
        # I need it for moments when M-F3 is not working.

        # x clip paste
        # zsh --no-rcs -c "tmux load-buffer -b myclipboard =(unbuffer xc)"
        # tmux paste-buffer -pr -b myclipboard

        unbuffer xc | while IFS= read -N 1 char; do
            # Don't need to check. newline
            #if [[ "$char" == '\012' ]] ; then
            #    tmux send-keys "Enter"
            #else
                # Just do it
                tmux send-keys -l "$char"
            #fi

            # printf -- "%s" "$char"
        done
        exit 0

        # send the keys one at a time to the terminal
    }
    ;;

    getpane) {
        :

        # Not sure what -j does

        # Should be used like this:
        # tmux neww "TMUX_PANE=$(tm getpane) some-commmand.sh"
    }
    ;;

    runreturn) { # Am I going to delete this?
        tf_returncode="$(mktemp -t tf_returncodeXXXXXX || echo /dev/null)"
        trap "rm $(aqf "$tf_returncode") 2>/dev/null" 0

        cmd="$1; echo \$? > $tf_returncode"

        tmux neww -t "$CALLER_TARGET" "$cmd"

        printf -- "%s\n" "$message"
        # Not sure what -j does

        # Should be used like this:
        # tmux neww "TMUX_PANE=$(tm getpane) some-commmand.sh"
    }
    ;;

    nextlayout) {
        # Not sure what -j does

        tmux next-layout -t "$CALLER_TARGET"

        #tmux neww "TMUX_PANE=$(tm getpane) tmux-next-layout-ask.sh"
    }
    ;;

    op|option) {
        # Examples:

        # tm so default-shell
        # tm so default-shell /bin/bash

        # tm so synchronize-panes
        # tm so synchronize-panes 1

        TMUX_OPTION="$1"
        : ${TMUX_OPTION:="default-shell"}

        OPTION_VALUE="$2"

        if [ -n "$OPTION_VALUE" ]; then
            tmux set -t "$CALLER_TARGET" $TMUX_OPTION "$OPTION_VALUE"
        else
            tpv "$TMUX_OPTION"
        fi
    }
    ;;

    pastekeys) {
        :

        # Can't remember what this did. F1 C-n
    }
    ;;

    editbuffer) {
        bufdata="$(tmux save-buffer -)"
        newdata="$(p -- "%s\n" "$bufdata" | EDITOR=v vipe)"

        tmux delete-buffer
        p -- "%s\n" "$newdata" | tmux load-buffer -
    }
    ;;

    nss) { # new subsession
        :

    }
    ;;

    pwd) { # get working directory of foremost programm running in the current terminal
        # This is important for splitting the terminal
        :
    }
    ;;

    # This script needs to be able to return a pane ID.
    # # However, much can be achieved doing this:
    # # tm -S nw "tm -S split \"v a\"; v s"

    # Either of these breaks it

    # Examples
    # echo hi | tm nw vipe | less
    # ls | tm nw vipe | fzf | vim -
    # echo hi | tm nw less
    # # NEED another option to spawn subsession inside this pane
    split|nw|neww|spv|sph|ss|new-window|rs) {
        # ssn="$(tmux display-message -p '#{session_name}')"
        # set -xv

        BACKGROUNDED=
        SPLIT=

        if test "$f" = "ss"; then
            SUB_SESSION=y

            # caveat: if you pipe into this, you don't have a tty
            # anymore and tmux won't start. Need a workaround.

            # It's breaking atm for subsessions. Not sure why.
            DETACHMENT_SENTINEL=n
        elif test "$f" = "split"; then
            SPLIT=-h
        elif test "$f" = "spv"; then
            SPLIT=-h
        elif test "$f" = "sph"; then
            SPLIT=-v
        fi

        # If return code is set, it is used. If using option -d, return
        # code is set to 0
        if test "$DETACHMENT_SENTINEL" = "y"; then
            RETURN_CODE=
        else
            RETURN_CODE=0
        fi

        : ${HIGHLIGHT:=""}
        : ${PRESS_ANY_KEY_FINISH:=""}
        PRESS_ANY_KEY_FINISH_KEY=f
        FORWARD_ARGS=n
        CHANGE_SHELL=n
        : ${REPEAT_COMMAND:="n"}
        REMAIN_ON_EXIT=n
        RETRY_SLEEP=0
        NEOVIM=n
        NEOVIM_TMUX=n
        RETURN_ID=n
        TRAPINT=y # This is so the window doesn't close if you press C-c in less
        while :; do opt="$1"; case "$opt" in
            -n) {
                window_name="$2"
                shift
                shift
            }
            ;;

            -A|-autoretry) {
                REPEAT_COMMAND=y
                PRESS_ANY_KEY_FINISH=n
                RETRY_SLEEP=2
                shift
            }
            ;;

            -quiet|-noerror)
                PRESS_ANY_KEY_ON_ERROR=n; shift
            ;;

            -noquiet|-error)
                PRESS_ANY_KEY_ON_ERROR=y; shift
            ;;

            -s) {
                session_name="$2"
                shift
                shift
            }
            ;;

            -w) {
                HIGHLIGHT=warn
                shift
            }
            ;;

            -nv) { # wrap in a neovim
                NEOVIM=y
                shift
            }
            ;;

            -nvt) { # wrap in a neovim
                NEOVIM_TMUX=y
                shift
            }
            ;;

            -hlgreen) {
                HIGHLIGHT=green
                shift
            }
            ;;

            -hlblue) {
                HIGHLIGHT=blue
                shift
            }
            ;;

            -notrapint) {
                TRAPINT=n
                shift
            }
            ;;

            -trapint) {
                TRAPINT=y
                shift
            }
            ;;

            -safe) {
                # wrap the command inside of another bash, so the entire
                # terminal does not quit if bad syntax is used
                SAFE=y
                shift
            }
            ;;

            -hlred) {
                HIGHLIGHT=blue
                shift
            }
            ;;

            -P) {
                # Return the session,window,*pane id* of the new window created
                RETURN_ID=y
                shift
            }
            ;;

            -t) {
                TARGET="$2"
                shift
                shift
            }
            ;;

            -d|-bg) {
                BACKGROUNDED="-d"
                shift
            }
            ;;

            -R|-repeat) {
                REPEAT_COMMAND=y
                PRESS_ANY_KEY_FINISH=y
                shift
            }
            ;;

            -r|-roe) {
                # This is evil
                # REMAIN_ON_EXIT="y"
                REPEAT_COMMAND=y
                PRESS_ANY_KEY_FINISH=y
                shift
            }
            ;;

            -sh) {
                CHANGE_SHELL=y
                DEFAULT_SHELL="$2"
                shift
                shift
            }
            ;;

            -bash) {
                CHANGE_SHELL=y
                DEFAULT_SHELL="bash"
                shift
            }
            ;;

            -zsh) {
                CHANGE_SHELL=y
                DEFAULT_SHELL="zsh"
                shift
            }
            ;;

            -paks|-pakstart) {
                PRESS_ANY_KEY_START=y
                shift
            }
            ;;

            -pak|-pakf|-pakfinish) {
                PRESS_ANY_KEY_FINISH=y
                shift
            }
            ;;

            -pakfk|-pakfinishkey) {
                PRESS_ANY_KEY_FINISH=y
                PRESS_ANY_KEY_FINISH_KEY="$2"
                shift
                shift
            }
            ;;

            -nopak|-nopakf|-nopakfinish) { # Used in conjunction with -R and less
                PRESS_ANY_KEY_FINISH=n
                shift
            }
            ;;

            -c) {
                # This expands the glob
                dir="$(eval echo -e "$2")" # expand
                CWD="$dir"
                cd "$CWD"
                export CWD

                envstring+="export CWD=\"$CWD\"; "

                # : ${CWD:="$(pwd)"}; cd "$CWD"

                shift
                shift
            }
            ;;

            -tpwd) {
                if [ -z "$TARGET" ]; then
                    # It was using the tmux session rather than the
                    # last process in the pane
                    if [ -n "$TMUX_PANE" ]; then
                        TARGET="$TMUX_PANE"
                    else
                        TARGET="$CALLER_TARGET"
                    fi
                    #if [ -n "$CURRENT_SESSION_NAME" ]; then
                    #    TARGET="$CURRENT_SESSION_NAME"
                    #else
                    #    TARGET="$CALLER_TARGET"
                    #fi
                fi
                # ns "$TARGET"

                dir="$(tpwd -t "$TARGET")"
                dir="$(eval echo -e "$dir")"
                lit "$dir" > /tmp/tm.txt
                tm n "$dir"
                export CWD

                shift
            }
            ;;

            -sin) {
                HAS_STDIN=y;
            }
            ;;

            -rsi|-icmd|-cin|-xargs|-iargs) {
                # These work the same now. If you provide a command,
                # it's prefixed to the stdin. If you don't stdin is the
                # command

                STDIN_IS_COMMAND=y
                HAS_STDIN=n
                shift
            }
            ;;

            -v) { # we want to be able to run v (vim)
                SPLIT=-h
                shift
            }
            ;;

            -h|h) {
                SPLIT=-v
                shift
            }
            ;;

            -fa|-forward-args|-fargs|-args) {
                FORWARD_ARGS=y
                shift
            }
            ;;

            *) break;
        esac; done

        if [ -z "$TARGET" ]; then
            if [ -n "$CURRENT_SESSION_NAME" ]; then
                TARGET="$CURRENT_SESSION_NAME"
            else
                TARGET="$CALLER_TARGET"
            fi
        fi
        # PRESS_ANY_KEY_FINISH=y

        # tm n "from $ssn. placing into $TARGET"

        # Doesn't work. I want to be able to wait for input to finish
        # from fzf before launching tmux.
        # if test "$SPONGE_IN" = "y"; then
        #     input="$(cat)"
        #     lit "$input" >>&0

        #     exec </dev/tty
        # fi

        if test "$CHANGE_SHELL" = "y"; then
            PREVIOUS_SHELL="$(tm op default-shell)"
            DEFAULT_SHELL="$(which "$DEFAULT_SHELL")"
            tm op default-shell "$DEFAULT_SHELL"
        fi

        : ${window_name:="new-window"}
        : ${session_name:="new-session"}

        sentinal_string="tm_sentinal_${RANDOM}_$$"

        # bash (set -o pipefail)
        # zsh (setopt pipefail)
        case "$DEFAULT_SHELL" in
            bash) {
                cmd_pre="set -o pipefail; "
                :
            }
            ;;

            zsh) {
                cmd_pre="setopt pipefail; "
                :
            }
            ;;

            *)
                # POSIX (no such thing). Sadly, this is tmux default
        esac

        cmd_pre="$cmd_pre stty stop undef; stty start undef; "
        test "$PRESS_ANY_KEY_START" = "y" && cmd_pre="$cmd_pre pak s; "

        if test "$HAS_STDIN" = "y"; then
            ff0="$(nix mkfifo tm_stdin)"

            if test "$BUFFER_IN" = "y"; then
                cmd_pre="$cmd_pre buffer | "
            fi

            if test "$SPONGE_IN" = "y"; then
                cmd_pre="$cmd_pre sponge | "
            fi

            if test "$UNBUFFER_IN" = "y"; then
                cmd_pre="$cmd_pre unbuffer -p "
            fi

            cmd_pre="$cmd_pre cat \"$ff0\" | "
        fi

        if test "$HAS_STDOUT" = "y"; then
            ff1="$(nix mkfifo tm_stdout)"

            if test "$UNBUFFER_OUT" = "y"; then
                cmd_pre="$cmd_pre unbuffer"
            fi

            if test "$BUFFER_OUT" = "y"; then
                cmd_post="$cmd_post | buffer"
            fi

            if test "$SPONGE_OUT" = "y"; then
                cmd_post="$cmd_post | sponge"
            fi

            cmd_post="$cmd_post >$ff1"
        fi

        ## Maybe change this to a fifo
        tf_rc="$(nix tf rc txt || echo /dev/null)"

        cmd_post="$cmd_post; ret=\$?; printf -- \"%s\" \$ret > \"$tf_rc\""

        if test "$PRESS_ANY_KEY_FINISH" = "y"; then
            cmd_post="$cmd_post; pak $PRESS_ANY_KEY_FINISH_KEY"
        elif test "$PRESS_ANY_KEY_ON_ERROR" = "y"; then
            cmd_post="$cmd_post; test \$ret -ne 0 && ( lit -n 'exit code '\$ret' => '; pak )"
        fi

        if test "$REPEAT_COMMAND" = "y"; then
            cmd_pre="while :; do $cmd_pre"
            if [ "$RETRY_SLEEP" -gt "0" ]; then
                cmd_post="$cmd_post; sleep $RETRY_SLEEP; done"
            else
                cmd_post="$cmd_post; done"
            fi
        fi

        test "$DETACHMENT_SENTINEL" = "y" && cmd_post="$cmd_post; tmux wait-for -S $sentinal_string"

        if test "$STDIN_IS_COMMAND" = "y"; then
            CMD="$(
            for (( i = 1; i < $#; i++ )); do
                eval ARG=\${$i}
                aq "$ARG"
                printf ' '
            done
            eval ARG=\${$i}
            aq "$ARG"
            )"

            cmd="$CMD"

            IFS= read -rd '' arguments < <(cat /dev/stdin)

            cmd+=" $arguments"

            # lit "$cmd"
            # pak
        else
            if ! test "$FORWARD_ARGS" = "y"; then
                # This is nasty but I have to allow it
                # tm n "$0 :: This is nasty"
                if test -n "$2"; then
                    cmd="$2"
                    dir="$1"
                elif test -n "$1"; then
                    cmd="$1"
                fi
            else
                CMD="$(
                for (( i = 1; i < $#; i++ )); do
                    eval ARG=\${$i}
                    aq "$ARG"
                    printf ' '
                done
                eval ARG=\${$i}
                aq "$ARG"
                )"

                cmd="$CMD"
            fi
        fi

        if test "$NEOVIM" = "y"; then
            # cmd="nv -term $cmd"
            cmd="nv -E -term $(aqf "$cmd")"
        elif test "$NEOVIM_TMUX" = "y"; then
            cmd="nvt -E $(aqf "$cmd")"
            # cmd="nvt $cmd"
        fi

        if [ -z "$dir" ]; then
            : ${CWD:="$(pwd)"}
            dir="$CWD"
        fi

        if [ -z "$cmd" ]; then
            cmd="$shell"
        fi

        envstring+="export CWD=\"$dir\"; "

        tf_exports="$(nix tf exports sh || echo /dev/null)"
        printf -- "%s\n" "$envstring" > "$tf_exports"

        # This fixes eipe
        # echo hi | tm eipe | cat
        printf -- "%s\n" "export TTY=\$(tty);" >> "$tf_exports"

        # trap "rm \"$tf_exports\" 2>/dev/null" 0

        fullcmd=". $tf_exports; ${cmd_pre} $cmd ${cmd_post}"
        # echo "$fullcmd"
        # exit 0

        # p "$fullcmd" | tv
        # echo "$fullcmd"

        # lit "$fullcmd"
        # pak

        # lit "$envstring ${cmd_pre} $cmd$cmd_post" 1>&2

        # lit "$fullcmd" >> /tmp/cmd.txt
        # tm -d dv "$fullcmd"
        # lit "test: $PATH" >> /tmp/path.txt

        # tmux neww
        # exit 0

        # These commands are excruciatingly slow in nested tmux
        # sessions. Never use them
        # if false && ! test "$FAST" = "y"; then
        #     if test "$REMAIN_ON_EXIT" = "y"; then
        #         tmux set -t "$TARGET" set-remain-on-exit on
        #     else
        #         tmux set -t "$TARGET" set-remain-on-exit off
        #     fi
        # fi

        # lit "$TARGET $SPLIT $BACKGROUNDED $dir $filcmd" >> /tmp/cmd.txt

        ID_FORMAT="#{session_id}:#{window_id}.#{pane_id}"

        if test "$SAFE" = "y"; then
            # I think sh is equally safe as bash? maybe not?
            
            # couldn't use aqf here because I also needed to escape dollars
            fullcmd="bash -c $(aqfd "$fullcmd") || pak -m 'bad syntax'"

            # printf -- "%s" "$fullcmd" | tv &>/dev/null
            # echo "$fullcmd" >> /tmp/fullcmd.txt
        fi


        if test "$TRAPINT" = "y"; then
            fullcmd="trap '' INT; $fullcmd"
        fi

        # IMPORTANT -- The actual command running.
        # respawn
        if test "$f" = "rs"; then
            full_id="$(tmux respawnp -k -t "$TARGET" -t "$TARGET" "$fullcmd")"
        elif test "$SUB_SESSION" = "y"; then
            server="$(tm-get-server)"

            unset TMUX
            full_id="$(tmux -L $server new -F "$ID_FORMAT" -P -t "$TARGET" $BACKGROUNDED -s "$session_name" -n "$window_name" -c "$dir" "$fullcmd")"
        elif test -n "$SPLIT"; then
            full_id="$(tmux split -F "$ID_FORMAT" -P -t "$TARGET:" $SPLIT $BACKGROUNDED -c "$dir" "$fullcmd")"
        else
            full_id="$(tmux neww -P -F "$ID_FORMAT" -t "$TARGET:" $PARENT_SESSION $BACKGROUNDED -n "$window_name" -c "$dir" "$fullcmd")"
            case "$HIGHLIGHT" in
                warn) {
                    tmux setw -t "$full_id" window-status-format '#[fg=colour244]#I #[fg=colour227,bg=colour161]#W'
                }
                ;;

                red) {
                    tmux setw -t "$full_id" window-status-format '#[fg=colour244]#I #[fg=colour160,bg=colour235]#W'
                }
                ;;

                blue) {
                    tmux setw -t "$full_id" window-status-format '#[fg=colour244]#I #[fg=colour026,bg=colour235]#W'
                }
                ;;

                green) {
                    tmux setw -t "$full_id" window-status-format '#[fg=colour244]#I #[fg=colour040,bg=colour235]#W'
                }
                ;;

                *)
            esac

            ## A new window was created. Was it for a subsession? If so,
            ## set the subsession's parent window id to the full_id

            #if [ -n "$PARENT_SESSION_ID" ]; then
            #    tmux setenv -t "$session_name" "PARENT_SESSION_ID" "$PARENT_SESSION_ID" \; \
            #fi
        fi

        # tmux setw -t "$full_id" window-status-format '#[fg=colour244]#I #[fg=colour227,bg=colour161]#W'

        # Never use these
        # if false && ! test "$FAST" = "y"; then
        #     tmux set -t "$TARGET" set-remain-on-exit off
        # fi

        if test "$CHANGE_SHELL" = "y"; then
            tm op default-shell "$PREVIOUS_SHELL"
        fi

        if test "$RETURN_ID" = "y"; then
            echo "$full_id"
        fi

        if test "$HAS_STDIN" = "y"; then
            cat > "$ff0"
            rm "$ff0" 2>/dev/null
        fi

        if test "$HAS_STDOUT" = "y"; then
            cat "$ff1" &
        fi

        test "$DETACHMENT_SENTINEL" = "y" && tmux wait-for "$sentinal_string"

        # This sleep is needed because the last it of stdout is yet to
        # come through
        # echo -n "hi\nyo" | tm filter | cat
        sleep 0.1

        if [ -z "$RETURN_CODE" ]; then
            RETURN_CODE="$(cat "$tf_rc")"
            if [ -z "$RETURN_CODE" ]; then
                RETURN_CODE=99
            fi
        fi
        # echo "$RETURN_CODE"

        trap "rm \"$tf_rc\" 2>/dev/null" 0

        # Need to implement return code

        if [ -e "$ff1" ]; then
            rm "$ff1" 2>/dev/null
        fi
        # exit 0
        exit "$RETURN_CODE"
    }
    ;;

    run) { # Delete this?
        tmux neww -t "$CALLER_TARGET" "$1"
    }
    ;;

    refresh) {
        tmux source-file ~/.tmux.conf
        tmux refresh-client ~/.tmux.conf
    }
    ;;

    run-debug-windows) {
        # I was doing this because of ldap problems

        tm n "$f :: NOT IMPLEMENTED"

        # tmux neww -d -n debug-bash 'bash -x -i -c exit 2>&1 | timestampify.pl | vim -'
        # tmux neww -d -n debug-zsh 'zsh -x -i -c exit 2>&1 | timestampify.pl | vim -'
        # tmux neww -d -n debug-strace 'strace /usr/bin/id 2>&1 | timestampify.pl | vim -'
    }
    ;;

    nxw|nxtw) {
        tmux next-window -t "$CALLER_TARGET"
    }
    ;;

    prw|prvw) {
        tmux previous-window -t "$CALLER_TARGET"
    }
    ;;

    new-script) {
        fn="$SCRIPTS/new-script-${RANDOM}.sh"

        touch "$fn"
        chmod a+x "$fn"

        printf -- "%s\n" "#!/bin/bash" >> "$fn"
        printf -- "%s\n" "export TTY" >> "$fn"
        printf -- "%s\n" >> "$fn"

        tm -S -te nw "vim \"$fn\""
    }
    ;;

    cap) {
        tm -te -d capture -clean -wrap -noabort -
    }
    ;;

    # tm cap-pane -t "%617" | v
    cap-pane|capp) {
        # forward optional -t

        #CMD="$(
        #for (( i = 1; i < $#; i++ )); do
        #    eval ARG=\${$i}
        #    printf -- "%s" "$ARG" | q
        #    printf ' '
        #done
        #eval ARG=\${$i}
        #printf -- "%s" "$ARG" | q
        #)"

        # eval "tm -te -d capture $CMD -clean -"
        tm -te -d capture "$@" -clean -
    }
    ;;

    scrape|scrape-filter) {
        cap="$(tm cap)"
        printf -- "%s" "$cap" | tm -f -S -tout nw -noerror "f filter-with-fzf"
    }
    ;;

    scrape-things) {
        cap="$(tm cap)"
        printf -- "%s" "$cap" | tm -f -S -tout nw -noerror "f filter-things"
    }
    ;;

    scrapep) {
        cap="$(tm capp)"
        printf -- "%s" "$cap" | tm -f -S -tout nw -noerror "f filter-with-fzf"
    }
    ;;

    search) {
        # tm -te -d capture -clean -editor "e -f isearch-forward-regexp" -wrap
        tm -f -te -d capture -clean -editor "e" -wrap
    }
    ;;

    avy) {
        # tm -te -d capture -clean -editor "e -fi avy-goto-char" -wrap
        tm -f -te -d capture -clean -editor "e -fi avy-goto-char" -wrap
    }
    ;;

    wrap) {
        # I could've done the same thing as F9 here
        # tm -te -d capture -clean -editor "e" -wrap
        tm -f -te -d capture -clean -editor "e" -wrap
    }
    ;;

    em|easymotion) {
        cap_file="$(tm cap | tf txt; sleep 0.5)"
        if [ -s "$cap_file" ]; then
            tm -te nw -n easymotion "v -c 'set foldcolumn=0 ls=0 | call EasyMotion#WB(0,2)' \"$cap_file\""
        fi

        exit 0
    }
    ;;

    kill-other) {
        # tmux select-pane -t :.+
        tmux kill-pane -t :.+
    }
    ;;

    nv-wrap) {
        tm -te -d capture -clean -wrap -nv
    }
    ;;

    capture-stdout) { # captures the terminal and puts it to stdout
        tm -te -d capture -clean -
    }
    ;;

    capture-stdout-wrap) { # captures the terminal including panes and puts it to stdout
        tm -te -d capture -clean -wrap -
    }
    ;;

    capture) {
        mkdir -p ~/programs/tmux/capture

        # tm n "$f :: NOT FULLY IMPLEMENTED"

        # Need tmux-outside / tmux-wrap capture

        x="$(tmux display -p "#{cursor_x}")"
        y="$(tmux display -p "#{cursor_y}")"

        ANSI=n
        ANSI=y
        DO_SEND_KEYS=n
        SCROLLBACK=-32768
        CAPTURE_OPTIONS=" -J "
        EDITOR="v"
        STDOUT= # no editor. no value relies on is_tty
        NOABORT=n
        while [ $# -gt 0 ]; do case $1 in
            -a|-ansi) {
                # printf -- "%s\n" "ansi"

                ANSI=y

                shift
            }
            ;;

            -c|-clean) {
                # printf -- "%s\n" "clean"

                ANSI=n

                shift
            }
            ;;

            -tty) {
                STDOUT=n

                shift
            }
            ;;

            -|-stdout) {
                STDOUT=y

                shift
            }
            ;;

            -f|-filter) {
                # like tm scrape-filter but can specify cap options
                # not using currently

                # Maybe I should do some variable exports

                # tm cap | f filter-with-fzf

                # tm scrape-filter

                ns disabled $1 because ambiguous

                exit 0

                shift
            }
            ;;

            -p) {
                PREVIEW=y

                shift
            }
            ;;

            -noabort) {
                NOABORT=y

                shift
            }
            ;;

            -t) {
                CALLER_TARGET="$2"
                CALLER_PANE="$2"
                shift
                shift
            }
            ;;

            -nosendkeys) {
                DO_SEND_KEYS=n

                shift
            }
            ;;

            -sendkeys) {
                DO_SEND_KEYS=y

                shift
            }
            ;;

            -s|-session) {
                # Take a capture of the entire session, not just the window

                shift
            }
            ;;

            -ts|-top-session) {
                # Take a capture of the topmost session

                shift
            }
            ;;

            --pc|--preview-cmd) {
                PREVIEW=y
                PREVIEW_CMD=y

                shift
            }
            ;;

            -e|-emacs) {
                EDITOR="e c"

                shift
            }
            ;;

            -editor) {
                # EDITOR="$2 -e \"(linum-mode -1)\""
                EDITOR="$2"

                shift
                shift
            }
            ;;

            -nv) {
                EDITOR="nv -c 'nmap q :q!<CR>'"
                # EDITOR="nv"

                shift
            }
            ;;

            -v|-vim) {
                EDITOR="v"

                shift
            }
            ;;

            -session) {

                shift
            }
            ;;

            -wrap) { # The tmux wrapper session
                WRAP=y
                SCROLLBACK=0

                shift
            }
            ;;

            -nohist|-nohistory) {
                SCROLLBACK="0"

                shift
            }
            ;;

            -history) {
                SCROLLBACK=-32768

                shift
            }
            ;;

            -b|-bottom) { # start emacs/vim at bottom of buffer

                # bind M-f run -b 'tmux-capture.sh -f' # filters
                shift
            }
            ;;

            *) break;
        esac; done

        if test "$ANSI" = "y"; then
            CAPTURE_OPTIONS+=" -e "
            EDITOR=ansivim
        fi

        server="$(tm-get-server)"
        echo "$server" 1>&2
        unset TMUX

        # Create temporary file
        tf_tmcapture="$(nix tf tmcapture txt || echo /dev/null)"
        bn="$(basename "$tf_tmcapture")"
        np="$HOME/programs/tmux/capture/$bn"
        mv "$tf_tmcapture" "$np"

        # echo $CALLER_TARGET
        # echo $CALLER_PANE

        echo "$WRAP" 1>&2
        if test "$WRAP" = "y"; then
            swidth="$(tmux display -t "$CALLER_TARGET" -p "#{session_width}")"
            sheight="$(tmux display -t "$CALLER_TARGET" -p "#{session_height}")"
            sheight="$(( sheight + 2 ))"

            # inotifywait -e close_write "$np" &
            # inotifywait -e write "$np" &

            # Don't use tm attach, to make this faster.
            tmux -L $server new-session -d -x "$swidth" -y "$sheight" -A -s wrap \; respawnp -k -t "wrap:1" "TMUX= tmux -L $server attach -t \"$CALLER_TARGET\""

            # 0.1 was too small
            #sleep 0.5 # Sometimes the hanging is because you are in the minibuffer of emacs. Maybe vim is more reliable
            # needed with lots of nesting and lag

            # sleep 0.1
            # sleep 1
            # wait

            # lit "$CALLER_TARGET $swidth $sheight $np" | tv

            # More robust but the session name MUST appear in output or
            # I'll get massive lag
            c=0
            # echo "$CALLER_TARGET"
            # exit 0

            grepstring="$CALLER_TARGET"
            if test "$grepstring" = "localhost"; then
                grepstring="$(hostname | s cap)"
            fi

            while ! grep -q "\[ $grepstring \]" "$np"; do
                ((++c))
                if test "$NOABORT" = "n" && [ "$c" -eq 10 ]; then
                    notify-send "Leaving capture \"[ $grepstring ]\" because it took too long."
                    break
                fi

                tmux -L $server capture-pane -t "wrap:1.0" \; save-buffer "$np"
                # exit 0
            done

            tmux -L $server kill-pane -t "wrap:1.0"
        else
            eval "tmux -L $server capture-pane -t "$CALLER_PANE" $CAPTURE_OPTIONS -S $SCROLLBACK"

            tmux -L $server save-buffer "$np"
        fi

        cat "$np" | {
            sed -e 's/▄/ /g' \
                -e 's/[┌┐┘└│├─┤┬┴┼]/ /g' \
                -e 's/\s\+$//g' ` # remove trailing whitespace `

            # piping into cat here breaks it. It creates a race
            # condition with the outer cat, or something. Do not do
            # this.
            # | cat
        } | sponge "$np"

        # Too slow
        # tm -te -d nw "$EDITOR \"$np\""

        #tmux neww -n capture "$EDITOR \"$np\""

        if test "$STDOUT" = ""; then
            if is_tty; then
                STDOUT=n
            fi
        fi

        if test "$STDOUT" = "y"; then
            cat "$np"
        else
            #EDITOR=v
            pane_id="$(tmux -L $server neww -F "#{pane_id}" -P -n capture "stty stop undef; stty start undef; GOTO_COLUMN=$x GOTO_LINE=$((y + 1)) $EDITOR \"$np\"")"
            # sleep 1
            # Easymotion

            if test $DO_SEND_KEYS = "f" && test "$EDITOR" = "v"; then
                tmux -L $server send-keys -t "$pane_id" "C-k"
            else
                :
                # Assume is emacs
                # tmux -L $server send-keys -t "$pane_id" "M-k"
            fi

            # tmux -L $server neww -n capture "vi \"$np\""

            # tm -te -d nw "ec \"$np\""


            # tmux -L $server capture-pane -J -S -32768 | tm -S -tout nw v
            # FNAME="$BULK/programs/tmux/capture/tmux_capture$(tmux display-message -p "_#H_#S:#I(#W).#P")_date:$(date +%d.%m.%y).txt
            # tmux save-buffer "$FNAME"
            # tmux capture-pane -J -S -32768
            # tmux save-buffer
            # tmux-quit-vim.sh
            # bind V capture-pane -J -S -32768 \; run 'FNAME="$BULK/programs/tmux/capture/tmux_capture$(tmux display-message -p "_#H_#S:#I(#W).#P")_date:$(date +%d.%m.%y).txt";
            # rm "$FNAME"; tmux save-buffer "$FNAME" \; neww -n "vim-capture" "editor.sh -c \"ToggleBrightness\" \"$FNAME\""'
            # bind R run 'tmux-edit-capture-full.sh'
        fi
    }
    ;;

    fr|free-resources) {
        tm n "$f :: NOT IMPLEMENTED"

        # tmux-quit-vim.sh
    }
    ;;

    jump) { # easymotion jump
        tm n "$f :: NOT IMPLEMENTED"

        # use easymotion to jump somewhere on the screen

        # I'd be remaking this. Low priority atm.
        # I can use neovim if I want.

        # I still need a wrapper tmux session that encompasses tmux
        # localhost

        # Also, I can fudge it without using neovim, though neovim was
        # fast.
    }
    ;;

    tnf|new-file) {
        tf="$(u tf new txt)"

        # sp tf

        tm -S -te nw "vim \"$tf\""

        # bind N neww -t localhost_dump: vim \; run "tmux-select.sh localhost_dump: >/dev/null"
    }
    ;;

    saykeyunbound) {
        key="$1"; : ${key:="key"}
        message="$2" # "new key M-T"

        exec &>/dev/null

        if [ -n "$message" ]; then
            tm n "$key has been unbound. $message"
        else
            tm n "$key has been unbound"
        fi
    }
    ;;

    edit-x-clipboard) {
        # This is much faster
        tm -f -te nw xce
    }
    ;;

    # edit-x-clipboard) {
    #     # I had to put an unbuffer before the xc or it wouldn't work in
    #     # tmux
    #     # This appears stable atm

    #     IFS= read -rd '' output < <(xc - | tm -soak -bout nw -n edit-x-clipboard vipe | cat)
    #     # The problem was pipefail I think. vipe gives an error if you
    #     # change it then quit without saving. This causes
    #     # edit-x-clipboard to hang. So use capture

    #     printf -- "%s" "$output" | xc

    #     # xc | tm -bout nw -n edit-x-clipboard vipe | xc

    #     # Even like this, it often still hangs
    #     # xc | tm -bout nw -n edit-x-clipboard vipe
    # }
    # ;;

    calc) {
        tm n "$f :: TODO: Further implemention" &>/dev/null

        win calculator
        # tm -te -d nw calc

        # bind ` run "tmux-calc.sh"
    }
    ;;

    wa|wolfram-alpha) {
        tm n "$f :: NOT IMPLEMENTED"
        exit 1

        # bind '~' run "wa-ask.sh"
    }
    ;;

    scrapep|scrape-paths) {
        tm n "$f :: NOT IMPLEMENTED"
        exit 1

        # bind J run 'tmux-scrape-path.sh'
    }
    ;;

    r|ranger) {
        dir="$(p "$dir" | q)"

        : ${CWD:="$(pwd)"}; cd "$CWD"

        export CWD

        # eval "tm -f -t nw -c \"$CWD\" -args ranger $CMD"
        tm -f -t nw -c "$CWD" -fargs ranger "$@"
    }
    ;;

    # BSpace
    shortcuts) {
        paths="$(tm-list-shortcuts)"

        # tm dv "$paths"
        if [ -n "$paths" ]; then

            # Now this is the slowest thing
            # tm -f -i nw "fzf -nm"
            # Can substitute for fzf -nm

            plf "$paths" | s uniq | tm -f -i nw -noerror "fzf -nm" | {
                dn="$(cat|umn)"
                dnq="$(printf -- "%s" "$dn" | q)"
                # dn="$(realpath "$dn")"
                # echo "$dn" > /tmp/paths.txt
                # exit 0
                exec </dev/tty

                 # | u dn
                # tm -i nw v
                # read dn # don't use read because it might hang
                # if [ -n "$dn" ]; then
                #    tm -d -te dv "$dn"
                #    exit 0
                # fi
                # exit 0
                if [ -n "$dn" ]; then
                    if ! [ -e "$dn" ]; then
                        tm -f -d -te dv "$dn :: No longer exists"
                    fi
                    export CWD="$dn"
                    tm -f -te -d nw -c "$dn" "CWD=$dnq ranger"
                fi
                exit 0
            }
            exit $?
        else
            ns "No dirs exist anymore." &>/dev/null
            # This opens vim directories.org
            # If the dirs expanded no longer exist.
            tm -f -te -d dir
        fi
        exit 0
    }
    ;;

    d|dir|directories) {
        # I need to expand globs first.
        paths="directories.*"
        paths="$(shopt -s nullglob; shopt -s extglob; eval lit -s "$paths")" # expand
        # tm dv "$paths"
        if [ -n "$paths" ]; then
            # echo hi | ./pmenu
            tm -f -d -t nw "vim $paths"
        else
            tm -f -d -t nw "vim directories.txt"
        fi
    }
    ;;

    s|src|source-files) {
        # I need to expand globs first.
        # config-files.txt

        paths='files\.* source?(s)\.*'
        paths="$(shopt -s nullglob; shopt -s extglob; eval lit -s "$paths")" # expand

        if [ -n "$paths" ]; then
            tm -f -d -t nw "vs -nad $paths"
        else
            tm -f -d -t nw "vs -nad source.txt"
        fi
    }
    ;;

    rsp|respawn-pane) {
        tm n "$f :: NEEDS WORK"

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -t) {
                TARGET="$2"

                shift
                shift
            }
            ;;

            -w) {
                SET_REMAIN_ON_EXIT=y

                shift
            }
            ;;

            -f) {
                FORCE=y
                # kill the window with -k

                shift
            }
            ;;

            *) break;
        esac; done

        CMD="$(cmd "$@")"

        if test "$FORCE" = "y"; then
            OPS+=" -f "
        fi


        if [ -n "$CMD" ]; then
            tmux respawn-pane -t "$CALLER_TARGET" $OPS -k "$CMD"
        else
            tmux respawn-pane -t "$CALLER_TARGET" $OPS -k
        fi


        # For commands such as these:
        # bind H run -b "tm sel localhost:history»; tmux respawn-pane -k -t localhost:history»"
    }
    ;;

    project-edit) {
        tm n "$f :: NOT IMPLEMENTED. Use projectile"
        exit 1

        # This was a crown thing I think. Load projectile instead.

        # bind M-r neww -n project-edit "project-edit.sh"
    }
    ;;

    copy-session-name) {
        tm n "$f :: NOT IMPLEMENTED. Need objects to represent sessions. name vs id"
        exit 1

        # Name and ID for tmux sessions will not be related anymore.

        # This copies the current session name / identifier.
        # A session will have a name and an ID.
    }
    ;;

    n|notify) {
        message="$1"

        # Make this an xmonad, dmenu or dzen notification. I don't want
        # to interrupt tmux.
        # tmux display-message "$message"

        #notify-send "$message"

        ns "$message" &>/dev/null

        # lit "$message"
    }
    ;;

    lw|last-window) {
        last_window_num="$(tmux list-windows -t "$CALLER_TARGET" | tail -n 1 | sed 's/\([0-9]\+\):.*/\1/')"
        if [ -n "$last_window_num" ]; then
            tmux select-window -t ":${last_window_num}"
        fi
    }
    ;;

    # This is for putting in shell scripts so I can see the value of
    # something
    dv|display-var) {
        CMD="$(
        for (( i = 1; i < $#; i++ )); do
            eval ARG=\${$i}
            printf -- "%s" "$ARG" | q
            printf ' '
        done
        eval ARG=\${$i}
        printf -- "%s" "$ARG" | q
        )"

        if test "$HAS_STDIN" = "y"; then
            message="$(cat)"
        else
            message="$CMD"
        fi
        message="$(p "$message" | q)"

        # This isn't about running the dv command again, but presenting
        # it
        # message="$(p "tm dv $message")"

        tm -t -d sph -pak "lit $message"
    }
    ;;

    visor) {
        keys="$(cat)"

        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    tput-search) { # This was the urwid program that allowed me to select different search engines
        keys="$(cat)"

        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    efs|edit-fsnotes) {
        tm n "$f :: NOT IMPLEMENTED"
        # edit-fs-notes...
        :
    }
    ;;

    gfs|get-fsnotes|fsnotes) {
        tm n "$f :: NOT IMPLEMENTED"
        # get-fs-notes.sh...
        :
    }
    ;;

    show-vim-mappings) {
        tm n "$f :: NOT IMPLEMENTED"
        # vimhelpfzf
    }
    ;;

    find-path-from-notes) {
        tm n "$f :: NOT IMPLEMENTED"
        # find-and-vim-path-from-notes.sh
    }
    ;;

    find-text-in-terminals) {
        tm n "$f :: NOT IMPLEMENTED"

        # bind F neww -n find-content "printf -- \"%s\\n\" \"tmux-find-content.sh \" | rtcmd"
    }
    ;;

    search-command-copy) {
        tm n "$f :: NOT IMPLEMENTED"

        # bind M-w neww "$VAS/projects/scripts/run-search-command-copy.sh"
    }
    ;;

    ncmd|notes-commands) { # scrape out all the commands and run them. Use search for this
        # tm n "$f :: NOT IMPLEMENTED"

        # Not sure why I need unbuffer here
        # unbuffer tm -t -d dv "$f :: NOT IMPLEMENTED"

        # I can use -tt though
        tm -tt -d dv "$f :: NOT IMPLEMENTED"

        # tm -t -d sph -pak "lit \"$f :: NOT IMPLEMENTED\""

        # bind M-, neww -n 'run-command' "get-notes-commands.sh | fzf-nopreview --sort --sync | xargs tmux-run-hist-command.sh"
        # cmd=\"$(get-notes-commands.sh | LINES=20 fzf-preview --sort --sync)\"; tmux-run-hist-command.sh \"$cmd\"
    }
    ;;

    ntv|tvs) {
        tm tv -vs "$@"
    }
    ;;

    tv) { # just have a look at what's inside as the program is running
        SILENCE=n
        REMEMBER_IT=n
        EDITOR=v
        window_mode=spv
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -q) {
                SILENCE=y
                shift
            }
            ;;

            -nv|-vs) {
                EDITOR=vs
                shift
            }
            ;;

            -rec) {
                REMEMBER_IT=y
                shift
            }
            ;;

            -spv|-nw|-sph) {
                window_mode="$(p "$opt" | mcut -d - -f2)"
                shift
            }
            ;;

            *) break;
        esac; done

        if test "$SILENCE" = "y"; then
            exec &>/dev/null
        fi

        IFS= read -rd '' input < <(cat /dev/stdin)

        ft="$1"

        if [ -n "$ft" ]; then

            tf_ft="$(nix tf ft "$ft" || echo /dev/null)"
            # trap "rm \"$tf_ft\" 2>/dev/null" 0

            printf -- "%s" "$input" > "$tf_ft"
            tm -d -tout spv -noerror "$EDITOR -nad $tf_ft"
        else
            printf -- "%s" "$input" | tm -S -tout $window_mode -noerror "$EDITOR -nad"
        fi
        printf -- "%s" "$input"

    }
    ;;

    vipe) { # edit and continue
        tm -sout spv vipe | cat
    }
    ;;

    eipe) { # edit and continue
        tm pipe eipe | cat
    }
    ;;

    # This is different to pipe-pane. It doesn't continue. It prints and
    # exits immediately. Maybe I should combine them?
    # This appears to not capture everything, only what is visible
    cat|catp|cat-pane) {
        opts=

        FROM_START=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -a) {
                # All, From the start of history
                FROM_START=y
                shift
            }
            ;;

            -na) {
                FROM_START=n
                shift
            }
            ;;

            *) break;
        esac; done

        target="$1"

        if test "$FROM_START" = "y"; then
            opts+=" -p -S - "
        fi

        if [ -n "$target" ]; then
            tmux capture-pane $opts -t "$target" \; save-buffer -
        else
            tmux capture-pane $opts \; save-buffer -
        fi

        exit 0
    }
    ;;

    pp|pipe-pane) {
        FROM_START=n
        CONTINUE=y
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -a) {
                # All, From the start of history
                FROM_START=y
                shift
            }
            ;;

            -C|-continue) {
                CONTINUE=y
                shift
            }
            ;;

            -nc|-nocontinue) {
                CONTINUE=n
                shift
            }
            ;;

            *) break;
        esac; done

        ff=/tmp/$$.data; trap "rm -f $ff" EXIT; mknod $ff p

        target="$1"

        if test "$FROM_START" = "y"; then
            tmux capture-pane -e -p -S - -t "$target"
        fi

        if test "$CONTINUE" = "y"; then
            if [ -n "$target" ]; then
                tmux pipe-pane -t "$target" "cat > $ff"
            else
                tmux pipe-pane "cat > $ff"
            fi

            cat "$ff"
        fi

        exit 0
    }
    ;;

    get-session) {
        printf -- "%s" "$CALLER_TARGET"
        exit 0
    }
    ;;

    get-pane) {
        printf -- "%s" "$CALLER_PANE" | ns

        # tmux run will get the correct pane
        exit 0
    }
    ;;

    #spp|split-and-pipe) {
    #    tm n "$f :: NOT IMPLEMENTED"
    #    lit "Not implemented"
    #    exit 1

    #    # Allows me to pipe panes through arbitrary commands.
    #    # bind M-d run "tmux-split-and-pipe.sh 1>/dev/null 2>/dev/null"
    #}
    #;;

    # F1 f
    pc|pipec|pipe-to-command|sf|select-filter|split-and-pipe|spp) {
        filter="$(set -o pipefail; cat $HOME/notes2018/ws/filters/filters.sh | tm fzf | remove-hash-comments.sh)"
        ret="$?"

        # CALLER_PANE is set correctly

        if ! test "$ret" -eq "130"; then
            # lit "$CALLER_PANE $filter" | tv &>/dev/null

            # unbuffer is needed so I can pipe
            # tm pp into a command without it sending a SIGPIPE and
            # breaking the pipe.
            # "stdbuf -i0 -o0 -e0" does not work. Need unbuffer
            tm -d spv "unbuffer tm pp -a '$CALLER_PANE' | $filter; pak -m \"source pane closed\""
            tmux select-pane -t "$CALLER_PANE"

        fi

        # exit "$ret"

        exit 0
    }
    ;;

    # Need to be able to pipe into a tmux pane

    pipe) { # edit and continue
        pipe_cmd="$1"; : ${pipe_cmd:="vipe"}
        shift

        tm -sout spv "$pipe_cmd" | cat
    }
    ;;

    sk|stream-keys|send-keys) {
        # This also needs to stream. the stdin may not end
        # so, while reading characters, or until the end of file

        while true; do
            line=''

            while IFS= read -r -N 1 ch; do
                case "$ch" in
                    $'\04') got_eot=1   ;&
                    $'\n')  break       ;;
                    *)      line="$line$ch" ;;
                esac
            done

            printf 'line: "%s"\n' "$line"

            if (( got_eot )); then
                break
            fi
        done

        # keys="$(cat)"

        target=
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -t) {
                target="$2"
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    monitor) {
        tm n "$f :: NOT FULLY IMPLEMENTED"
        #tm -d nw "echo 'loading htop...'; htop"

        # htop is kinda slow
        tm -d nw "htop"
    }
    ;;

    select-subsession) {
        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    subsession) {
        tm n "$f :: NOT IMPLEMENTED"
        paths="$(find . -maxdepth 1 -type d)"
        if [ -n "$paths" ]; then
            # paths="$(plf "$paths" | s uniq | tm -f -i spv "fzf" | umn | q -ftln | tr -s '\n' ' ')"
            paths="$(plf "$paths" | s uniq | tm -f -i spv -noerror "fzf" | umn)"
            if [ -n "$paths" ]; then
                # plf "$paths" | tm -f -sin -S -i -tout spv "vim -"

                # printf -- "%s\n" "$paths" | tv > /dev/null

                bn="$(basename "$paths")"

                # printf -- "%s\n" "$bn" | tv > /dev/null

                tm ns -r -l -s -c "$bn"
            fi
        fi
    }
    ;;

    kass|kill-subsessions) {
        tm n "$f :: NOT IMPLEMENTED. Use data structure"
    }
    ;;

    kss|kill-subsession) {
        tm n "$f :: NOT IMPLEMENTED. Use data structure"
    }
    ;;

    bh|base-here) {
        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    bl|base-localhost) {
        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

    os|omni-session) {
        tm n "$f :: NOT IMPLEMENTED. Can't remember what this did"
    }
    ;;

    lkb|list-keybindings) {
        tmux list-keys | tm -S -tout nw -n tmux-key-bindings "v -c \"set ft=tmux\""
    }
    ;;

    cr|compile-run) {
        tm n "$f :: NOT IMPLEMENTED"

        # tm -t spv "cr '.fnameescape(expand('%:p')).'"'
    }
    ;;

    open-list-of-files-in-emacs) {
        # Takes stdin. Opens all files in emacs

        # This breaks stdin
        # tm n "$f :: NOT IMPLEMENTED"


        #tm -S -tout spv v

        tm -S -tout spv -noerror sp
    }
    ;;

    tp|open-list-of-files-in-windows) {
        # tm -S -tout nw vipe

        for var in "$@"
        do
            # print every argument into the stdin
            exec < <(printf -- "%s\n" "$var")
        done

        input="$(cat)"

        exec 0<&-
        # pwd | tv

        printf -- "%s" "$input" | awk 1 | umn | while read -r line; do
            if [ -e "$line" ]; then
                # line="$(p "$line" | qne)"
                # bn="$(basename "$line")"
                # tm -te -d nw -n "$bn" "open -e $line"

                tm-open-file-blue "$line"
            else
                # should I not use 'ge' here?

                line="$(p "$line" | scrape-files.sh | qne)" # use scrape-files because it could be an org-mode link
                bn="$(basename "$line" | slugify)"

                # open -e is also the way to open urls. rifle didn't
                # work

                tm -te -d nw -n "$bn" "open -e $line"
            fi
        done
    }
    ;;

    vim-open-buffer-list-in-windows) {
        # tm -S -tout nw vipe

        input="$(cat)"
        exec 0<&-

        printf -- "%s" "$input" | sed '1d' | sed 's/^[^"]\+\(.*"\)[^"]\+$/\1/' | uq -ftln | umn | awk 1 | while read -r line; do
            if [ -e "$line" ]; then
                # line="$(p "$line" | qne)"
                # bn="$(basename "$line")"
                # tm -te -d nw -n "$bn" "open -e $line"

                tm-open-file-green "$line"
            fi
        done
    }
    ;;

    ngrams) {
        # This is good-enough for the moment, but I want to capture from
        # other windows too.
        tmux capture-pane -t "$CALLER_TARGET" \; show-buffer\; delete-buffer

        # vim +/"w=( \${(u)=\$(tmux-localhost-words.sh)} )" "$HOME/.zshrc"
    }
    ;;

    # Get the cursor word gram
    gram) {
        tmux capture-pane -t "$CALLER_TARGET" \; show-buffer\; delete-buffer

        pattern="$1"
        : ${pattern:="»"}

        # h="$(tmux display -p "#{pane_height}")"

        y="$(tmux display -p "#{cursor_y}")"

        tm -f cat | sed -n "$((y + 1))p" | {
            # make a list of possible prompts
            sed -e 's/^Prelude> //' \
                -e 's/^.*» //' \
                -e 's/^Eval: //' \
                -e 's/^In \[[0-9]\+\]: //' \
                -e 's/^λ> //' \
                -e 's/^://' \
                -e 's/^[^ ]\+% //' \
                -e 's/ \[Unknown command\]$//'
        } | xc -i -n
    }
    ;;

    remote-xclip) {
        tm n "$f :: NOT IMPLEMENTED"

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -r) {
                # receive

                # This overwrites our clipboard with the remote
                # clipboard

                exit 0
                shift
            }
            ;;

            *) break;
        esac; done

        # pipe into this to send to the remote clipboard
        # otherwise, it will cat the remote clipboard, but not save
        # Use -r to overwrite ours with the remote
    }
    ;;

    mru|most-recently-used) {
        # without this, I can't pipe into vim
        exec 2>&4

        # cat "$HOME/.emacs/recentf"

        list-mru

        exit 0

        # Filter the above through a files-only filter list.
        # Need the consecutive combinations script.

        # tm sel localhost:mru.0; tmux respawn-pane -k -t localhost:mru.0;
    }
    ;;

    unimplemented) {
        p1="$1"; : ${p1:="This command is"}
        tm n "$p1 :: NOT IMPLEMENTED"
    }
    ;;

    # This should launch a hydra. Use the same script for selecting an
    # emacs distribution?
    git) {
        tm n "$p1 :: NOT IMPLEMENTED"
        plf "git status for everything below"
        plf "I could open a hydra here or I could use lots of different ranger bindings"
        pak
    }
    ;;

    gist) {
        tm n "$p1 :: NOT IMPLEMENTED"
        plf "git status for everything below"
        plf "Use a command from the git hydra"

        plf "Remotes"
        git remote -v | f urls

        pak
    }
    ;;

    search) { # Find / Search. Need hydra for this
        # Cut to the chase; start using hydras immediately.
        # Need to be able to use emacs hydras in vim.
        # If I can do that, I can create hydras for anything. Random
        # programs. Even things like vlc.
        # If I simply learned elisp though, that would speed up the
        # process.

        tm n "$p1 :: NOT IMPLEMENTED. Need tmux hydra"

        # Finding terminals:
        # F1 f w -- find by window name
        # F1 f c -- find by content
    }
    ;;

    copy-pane-name) {
        # I have to use format string because there is no 'literal'
        # option for display-message

        format_string="#{session_name}:#{window_name}.#{pane_index}"

        pane_name="$(tmux display-message -p "$format_string")"
        tmux display-message "copied pane name: $format_string"

        lit "$pane_name" | xc
    }
    ;;

    copy-pane-id) {
        # I have to use format string because there is no 'literal'
        # option for display-message

        format_string="#{session_id}:#{window_id}.#{pane_id}"

        pane_name="$(tmux display-message -p "$format_string")"
        tmux display-message "copied pane id: $format_string"

        p "$pane_name" | xc
    }
    ;;

    lock) {
        tmux lock-session -t localhost:
    }
    ;;

    move-to-start) {
        tmux set base-index 1 \; move-window -r \; move-window -t 0
    }
    ;;

    move-to-end) {
        tmux set base-index 1 \; move-window -r \; move-window -t :
    }
    ;;

    command-history) {
        tm sel "localhost:history»" && tm rsp -f -t "localhost:history»"
    }
    ;;

    recent-isues) {
        tm sel "localhost:recent-issues»"
        tmux respawn-pane -k -t "localhost:recent-issues»"
    }
    ;;

    sel|select) {
        # This even works for this:
        # target="localhost:test.txt.0"

        # For the time being, just do a really simple tmux select window
        # If I want to implement a nested select then that will be much
        # harder.

        target="$1"
        orig_target="$target"
        target="$(printf -- "%s" "$target" | sed 's/\.\([^%0-9]\)/\*\1/')"

        tmux select-window -t "$target" 2>/dev/null
        tmux select-pane -t "$target" 2>/dev/null || {
            echo "could not find $target. using slow method..." 1>&2
            re_target="$(p "$orig_target" | sed 's/\(\.[^0-9]\)/\\\1/g' | sed 's/\*/\.*/g')"
            tm-lsp.sh | grep -P "$re_target\t" | head -n 1 | sed 's/.*\t//' | xargs -l tmux select-window -t
        }

        PARENT_PANE_ID="$(tmux show-env -t "$target" PARENT_WINDOW_ID | sed 's/.*=//')"
        # echo "parent: $PARENT_PANE_ID" >> /tmp/tm.log
        if [ -n "$PARENT_PANE_ID" ]; then
            tm sel "$PARENT_PANE_ID"
        fi

        exit 0

        # if [[ "${target}" =~ .*:.*\..* ]]; then
            # lit "session:window.pane"
        # elif [[ "${target}" =~ [^:]*\..* ]]; then
            # lit "window.pane"
        # elif [[ "${target}" =~ .*:[^.]* ]]; then
            # lit "session:window"
        # elif [[ "${target}" =~ [0-9]* ]]; then
            # lit "pane"
        # fi

        target_session="${target%:*}"
        target_windowpane="${target##*:}"
        target_window="${target_windowpane%.*}"
        target_pane="${target_windowpane##*.}"

        # lit "${target%:*}"
        # lit "${target##*:}"
        # lit "${target_windowpane%.*}"
        # lit "${target_windowpane##*.}"

        plf "session: $target_session"
        plf "window: $target_window"
        plf "windowpane: $target_windowpane"
        plf "pane: $target_pane"

        exit 0
    }
    ;;
    
    yank-line|copy-current-line) {
        pattern="$1"
        : ${pattern:="»"}

        # h="$(tmux display -p "#{pane_height}")"

        y="$(tmux display -p "#{cursor_y}")"

        tm -f cat | sed -n "$((y + 1))p" | {
            # make a list of possible prompts
            sed -e 's/^Prelude> //' \
                -e 's/^.*» //' \
                -e 's/^➜  ~ //' \
                -e 's/^> //' \
                -e 's/^>>> //' \
                -e 's/^In \[[0-9]\+\]: //' \
                -e 's/^Eval: //' \
                -e 's/^In\[[0-9]\+\]:= //' \
                -e 's/^λ> //' \
                -e 's/^://' \
                -e 's/^[a-z]\+@[a-z0-9-]\+:[^$]\+$ //' \
                -e 's/^[^ ]\+% //' \
                -e 's/ \[Unknown command\]$//'
        } | xc -i -n
    }
    ;;

    # copy-current-line) {
    #     tm n "$f :: NOT IMPLEMENTED"
    #     exit 1

    #     tm -te -d capture "$@" -clean -

    #     cap_file="$(tm cap | tf txt; sleep 0.5)"
    #     if [ -s "$cap_file" ]; then
    #         tm -te nw -n em-click "v -c 'set foldcolumn=0 ls=0 | call EasyMotion#WB(0,2) | q!' \"$cap_file\""

    #         x="$(cat /tmp/em-click.txt | cut -d ' ' -f 1)"
    #         y="$(cat /tmp/em-click.txt | cut -d ' ' -f 2)"

    #         if [ -n "$x" ] && [ -n "$y" ]; then
    #             # notify-send "$loc"
    #             x=$((x - 1))
    #             y=$((y - 1))
    #             tm click-wrap $x $y
    #         fi
    #     fi

    #     # Need to obtain coordinates here. Thene run: "tm click -t %570 0 0"
    #     # $HOME$VIMCONFIG/vim/pack/myplugins/start/vim-easymotion-new/autoload/vital/easymotion.vim

    #     exit 0
    # }
    # ;;

    get-last-output) {
        pattern="$1"
        : ${pattern:="»"}

        tm -f capture-stdout | remove-trailing-blank-lines | sed '/^$/d' | tac | sed -n -e 1d -e "0,/$pattern/p" | tac | sed 1d
    }
    ;;

    edit-file) {
        paths="$(find . -maxdepth 1 -type f | sed 's/^..//')"
        if [ -n "$paths" ]; then
            paths="$(plf "$paths" | s uniq | tm -f -i spv -noerror "fzf -p" | umn | q -ftln | tr -s '\n' ' ')"
            if [ -n "$paths" ]; then
                plf "$paths" | tm -f -sin -S -tout spv -noerror -xargs vim
            fi
        fi
        :
    }
    ;;

    # bind f run -b "tm find-window-from-session -no-activate"
    find-window-from-session) {
        # tm n "$f :: NOT IMPLEMENTED"

        # Maybe I should start trying to build real software in python.
        # Design this thing. Use org-mode?

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -no-activate) { # This option allowed me to go to a window without triggering less to become vim.
                no_activate=y
                shift
            }
            ;;

            -no-split) { # This option allowed me to go to a window without triggering less to become vim.
                no_split=y
                shift
            }
            ;;

            *) break;
        esac; done

        # I need trees of tmux sessions. How to do this quickly?

        # tmux lsp -a -F '#{session_id}:#{window_id}:#{pane_id}'
        #panes="$(tmux lsp -a)"
        #panes="$(tm-lsp.sh)"
        #if [ -n "$panes" ]; then
        #    result="$(plf "$panes" | tm -f -i spv "fzf -nm")"

        fzfcmd="tm-lsp.sh \"${CALLER_TARGET}\" | hls -i -r -f white '\.org' | hls -i -r -f purple directories | hls -i -r -f blue links | hls -i -b red -f yellow '\(problems\)' | hls -i -r -f orange '\(setup\|scripts\)' | hls -i -r -f green commands | hls -i -r -f yellow notes | hls -i -f blue localhost | hls -i -f red '\.[0-9]\+' | hls -i -f purple : | fzf -A -nm | strip-ansi"
        if test "$no_split" = "y"; then
            result="$(eval "$fzfcmd")"
        else
            result="$(tm -f spv -noerror "$fzfcmd")"
        fi

        if [ -n "$result" ]; then
            # result="$(plf "$results" | head -n 1)"
            full_pane_id="$(p "$result" | sed 's/.*\t//')"

            #{
            #    lit "$full_pane_id"
            #}| tv &>/dev/null

            tm sel "$full_pane_id"
            # plf "$result" | tm -f -sin -S -tout spv -xargs vim
        fi

        # I first need to implement a tree or graph of tmux windows. But
        # rather than get stuck too much in the terminal, I should be
        # learning NLP and DL.
    }
    ;;

    select-current) {
        lastwin="$(tmux list-windows -t localhost_current | sed -n '$s/^\([0-9]\+\).*/\1/p')"
        tm sel "localhost_current:$lastwin"
        exit 0
    }
    ;;

    open-dirs) {
        selections="$(tm -s -fout spv -noerror "F find-no-git -d | fzf")"
        if [ -n "$selections" ]; then
            printf -- "%s\n" "$selections" | \
            while read -r line; do
                if [ -e "$line" ]; then
                    line="$(p "$line" | qne)"
                    bn="$(basename "$line")"
                    tm -te -d nw -noerror -n "$bn" "open -e $line"
                fi
            done
        fi
    }
    ;;

    open-files) {
        # selections="$(tm -s -fout spv -noerror "F find-no-git -f | fzf")"
        selections="$(tm -s -fout spv -noerror "F f | fzf")"
        if [ -n "$selections" ]; then
            printf -- "%s\n" "$selections" | \
            while read -r line; do
                if [ -e "$line" ]; then
                    line="$(p "$line" | qne)"
                    bn="$(basename "$line")"
                    tm -te -d nw -noerror -n "$bn" "open -e $line"
                fi
            done
        fi
    }
    ;;

    fzf) {
        tm -f spv -noerror fzf
        exit $?
    }
    ;;

    less) {
        tm -S -tout spv -noerror tless 
        exit $?
    }
    ;;

    filter) {
        IFS= read -rd '' input < <(cat /dev/stdin)

        # Due to some mechanism, I don't understand, C-c on this will
        # not give an error exit code
        # Maybe the f is still running
        # sout="$(printf -- "%s" "$input" | tm spv "f filter-with-fzf | cat" | cat)"

        export HAS_STDOUT
        sout="$(set -o pipefail; printf -- "%s" "$input" | tm spv -noerror "f filter-with-fzf" | cat)"
        ret="$?"
        # echo "$sout"
        # echo "$ret"

        if test "$ret" -eq 0; then
            {
                if [ -n "$sout" ]; then
                    printf -- "%s" "$sout"
                else
                    printf -- "%s" "$input"
                fi
            } | {
                if test "$HAS_STDOUT" = "y"; then
                    cat
                else
                    # Use tv instead of vim. Helps (defun my/fwfzf)
                    tv
                fi
            }
        fi

        exit "$ret"
    }
    ;;
    

    # tm w tpb tomorrow never dies
    tw|w) { slug="$(echo "$@" | tr -d '\n' | slugify | cut -c -10)"; tm -d nw -n "$slug" -fa "$@"; } ;;
    h) { tm -d sph -d -fa "$@"; } ;;
    v) { tm -d spv -d -fa "$@"; } ;;

    template) {
        :
    }
    ;;

    *) {
        tm n "$f :: NOT IMPLEMENTED"
    }
    ;;

esac

exit 0

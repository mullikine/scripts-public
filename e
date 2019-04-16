#!/bin/bash

: ${EMACS_TERM_TYPE:="screen-256color"}
export EMACS_TERM_TYPE

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

# overwritten with
# -2|-vt100) {

# Need this for RUST_SRC_PATH. But it might not be needed anymore.
. $HOME/.shell_environment

# I used to not specify a version here as the default and it would use version 24 as default.
# I'm not going to use version 24 anymore. I want the newest org-mode to work
EMACS_VERSION=26


# I could make it that package-refresh-contents is run when I run with
# nw --debug-init

# eval `resize`

# Troubleshooting:
# sp $HOME/notes2018/ws/cpp-c++/environment/tools/links.org
# Didn't like opening with lisp because of the +s in the path.

# echo "$(basename "$0")" $@ 1>&2

sn="$(basename "$0")"

f=

# Use the tmux version of emacs for hydras in the shell.

# It's not working properly
# find_file_command=my-find-file
find_file_command=find-file

case "$sn" in
    vlf) {
        find_file_command=vlf
        # f=c
    }
    ;;

    pd) {
        DISTRIBUTION=prelude
        # f=c
    }
    ;;

    pc) {
        DISTRIBUTION=purcell
        # f=c
    }
    ;;

    fr) {
        DISTRIBUTION=frank
        # f=c
    }
    ;;

    sp) {
        DISTRIBUTION=spacemacs
        # f=c
    }
    ;;

    dm) {
        DISTRIBUTION=doom
        # f=c
    }
    ;;

    sc) {
        DISTRIBUTION=scimax
        # f=c
    }
    ;;

    et) {
        DISTRIBUTION=default
        SOCKET="DEFAULT_tmux"
        # f=c
    }
    ;;

    xr) {
        DISTRIBUTION="exordium"
    }
    ;;

    me) {
        DISTRIBUTION=default
        SOCKET="DEFAULT_magit"
        EMACS_VERSION=26
        # f=c

        # disable rainbow here: my-distributions.el

        # Can't put it here, full stop. Either place it in the emacs
        # config or specify on the command-linet
        # elisp+="(global-rainbow-delimiters-mode -1)(global-rainbow-identifiers-always-mode -1)"

        # Both the below are equivalent because "me -e \"($f)\"" always
        # puts magit-status first
        # elisp="(global-rainbow-delimiters-mode -1)(global-rainbow-identifiers-always-mode -1)$elisp"

        # DISCARD: This will not work. They must be disabled before magit-status
        # is run
        # elisp+="(global-rainbow-delimiters-mode -1)(global-rainbow-identifiers-always-mode -1)"
    }
    ;;

    og) {
        DISTRIBUTION=default
        SOCKET="DEFAULT_org"
        EMACS_VERSION=26
        # f=c
    }
    ;;
esac

# This is the edit command.
# I should be able to do things like this:

# e v 25 10
# edit vim [line] [column]

# e c 25 10
# edit emacsclient [line] [column]

# This should also do vim

# Perhaps use this as a template for extending this script's options?
# $HOME/var/smulliga/source/git/fzf/bin/fzf-tmux


# Need to specify parameters for starting different variants of emacs.
# Do that at the start


# alias emacs='emacs -q --load "/path/to/init.el"'


# Need also full abstraction for terminal programs where I can create
# bindings

# Add ability to run a command

QUIET=y

# It's important that these are exportable
: ${EMACS_BIN:="/usr/bin/emacs"}
: ${EMACSCLIENT_BIN:="/usr/bin/emacsclient"}
: ${EMACS_USER_DIRECTORY:="$HOME/.emacs.d"}

# I am not using this env var atm. Yes I am now. For scimax and
# spacemacs testing.
# EMACS_VARIANT=

if test "$1" = "-v"; then
    QUIET=n
    shift
fi


if test "$1" = "-vv"; then
    QUIET=n

    # Usage: $0 -h
    invocation="$0 $@"
    printf -- "%s\n" "invocation: $invocation" 1>&2

    set -xv

    shift
fi

export QUIET

stdin_exists() {
    ! [ -t 0 ]
}

# A good default
: ${ONLY_WINDOW:="y"}

AUTO_VERSION=n

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    "") { shift; }; ;;
    -2|-vt100) {
        MONOCHROME=y
        shift
    }
    ;;

    -o|-only) { # Make the window that appears the only window
        export ONLY_WINDOW=y
        shift
    }
    ;;

    -noonly) {
        export ONLY_WINDOW=n
        shift
    }
    ;;

    -a|-auto|auto-version) { # select version based on extension
        AUTO_VERSION=y
        shift
    }
    ;;

    pd) {
        DISTRIBUTION=prelude
        f=c
        shift
    }
    ;;


    fr) {
        DISTRIBUTION=frank
        f=c
        shift
    }
    ;;

    org) {
        DISTRIBUTION=default
        SOCKET="DEFAULT_org"
        EMACS_VERSION=26
        f=c
        shift
    }
    ;;

    sp) {
        DISTRIBUTION=spacemacs
        f=c
        shift
    }
    ;;

    dm) {
        DISTRIBUTION=doom
        f=c
        shift
    }
    ;;

    +*:*) {
        GOTO_LINE="$(p "$opt" | mcut -d'[+:]' -f2)"
        GOTO_COLUMN="$(p "$opt" | mcut -d'[+:]' -f3)"

        shift
    }
    ;;

    +[0-9]*) {
        GOTO_LINE="$(p "$opt" | mcut -d+ -f2)"
        shift
    }
    ;;

    +/*) { # pattern
        pattern="$(p "$opt" | mcut -d+/ -f2 | s chomp | qne)"

        shift
    }
    ;;

    v) {
        shift

        # "tm -d" breaks stdin. Use -S
        if stdin_exists; then
            GOTO_LINE="$1"
            GOTO_COLUMN="$2"
        else
            file="$1"
            GOTO_LINE="$2"
            GOTO_COLUMN="$3"
        fi

        if [ -n "$GOTO_COLUMN" ]; then
            v -c "call cursor($GOTO_LINE,$GOTO_COLUMN)" "$file"
        elif [ -n "$GOTO_LINE" ]; then
            v +$GOTO_LINE "$file"
        elif [ -n "$file" ]; then
            v "$file"
        else
            # For piping into vim
            v
        fi

        exit $?
    }
    ;;

    *) break;
esac; done

if test "$MONOCHROME" = "y"; then
    export EMACS_TERM_TYPE=screen-2color
fi

if test "$ONLY_WINDOW" = "y"; then
    elisp+="(delete-other-windows)"
fi
# echo "$elisp"

print_err() {
    ! test "$QUIET" = "y" && printf -- "%s" "$@" 1>&2

    return 0
}

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    sa|-sa|-startall) {

        # Disable these by default to save memory

        # exordium is only on my cloud VPS
        # e -D exordium sd ` # Is having problems atm anyway `
        # e -D scimax sd ` # working perfectly atm`
        # e -D prelude sd ` # working perfectly atm`

        # e -D purcell sd

        # Annoyingly, if this is not done synchronously, it won't work.
        e sd
        # e -D default sd &

        # Server is not working for Frank's emacs
        # e -D frank sd

        # reserved for capturing tmux screenshots. I don't want capture
        # to hang while M-x is happening in another emacs

        # don't use a separate tmux server. Instead use the default
        # server
        # e -D default -s tmux sd &

        #e -D default -s org sd &
        # e -D default -s org sd
        og sd
        # dm sd

        # e -D default -s magit sd
        me sd

        # pd sd

        # pc sd
        sp sd

        # sc sd

        # xr sd

        # unbuffer spx & disown
        # wait

        # e -D spacemacs sd
        # e -D spacemacs sd &


        # e -D vanilla sd
        # e -D spacemacs -s eww sd
        # e -D default -s magit sd
        # e -D default -s eww sd
        # e -D default -s dired sd
        shift

        exit 0
    }
    ;;

    ka|-ka|-killall) {
        {
            e -D exordium k
            e -D prelude k
            e -D purcell k
            e -D spacemacs k
            e -D doom k
            e -D default k
            e -D frank k
            e -D scimax k # scimax doesn't like to be killed

            e -D default -s tmux k
            e -D default -s org k

            e -D vanilla k
            # e -D spacemacs -s eww k
            e -D default -s magit k
            # e -D default -s eww k
            # e -D default -s dired k

            pgrep emacs | xargs kill
        } &>/dev/null
        shift

        exit 0
    }
    ;;

    fa|-fa|-forall) {
        shift

        for d in e og me sp; do
            eval "$d" "$@"
        done

        exit 0
    }
    ;;

    qa|-qa|-quitall) {
        {
            # I don't want to start any servers. I only want to quit
            # them if they are running.

            e -D exordium q
            e -D purcell q
            e -D prelude q
            e -D spacemacs q
            e -D default q
            e -D frank q
            e -D scimax q

            e -D default -s tmux q
            e -D default -s org q

            # e -D exordium c -e "(kill-emacs)"
            # e -D prelude c -e "(kill-emacs)"
            # e -D spacemacs c -e "(kill-emacs)"
            # e -D default c -e "(kill-emacs)"
            # e -D scimax c -e "(kill-emacs)"

            # e -D vanilla q
            # e -D spacemacs -s eww
            # e -D default -s magit q
            # e -D default -s eww q
            # e -D default -s dired q

            pgrep emacs | xargs kill
        } &>/dev/null
        shift

        exit 0
    }
    ;;

    ra|-ra|-restart-all) {
        e -qa
        e -sa
    }
    ;;

    *) break;
esac; done


# I can import this
: ${SOCKET:="DEFAULT"}

if test "$1" = "-D"; then
    DISTRIBUTION="$2"
    shift
    shift
fi

if test "$AUTO_VERSION" = "y"; then
    # This isn't accurate, but whatever
    last_arg="${@: -1}"

    fn=$(basename "$last_arg")
    ext="${fn##*.}"
    mant="${mant%.*}"

    case "$ext" in
        org) {
            SOCKET="DEFAULT_org"
            EMACS_VERSION=26
        }
        ;;

        template) {
            :
        }
        ;;

        *) {
            EMACS_USER_DIRECTORY="$MYGIT/spacemacs"
            EMACS_VERSION=26
            SOCKET="SPACEMACS"
            EMACS_VARIANT="SPACEMACS"
        }
    esac
    :
fi

# Distribution
case "$DISTRIBUTION" in
    v|vanilla) # vanilla
        {
            SOCKET="VANILLA"
            EMACS_VARIANT="VANILLA"
            :
        }
        ;;

    fr|frank)
        {
            # Getting errors with emacs26

            #EMACS_VERSION=24
            EMACS_VERSION=26
            EMACS_USER_DIRECTORY="$MYGIT/zwpdbh/emacs"
            SOCKET="FRANK"
            EMACS_VARIANT="FRANK"
            :
        }
        ;;

    xr|exordium) # exordium (for C++)
        {
            EMACS_VERSION=26
            EMACS_USER_DIRECTORY="$MYGIT/philippe-grenet/exordium"
            SOCKET="EXORDIUM"
            EMACS_VARIANT="EXORDIUM"
        }
        ;;

    pc|purcell) # steve purcell
        {
            # I should be acquiring friends that can help me with
            # certain tasks.

            # If I wanted I could write down people and their skillsets.
            # To a degree I should do this. You should ask people for
            # their advice on things.

            # Install evil to fix this. Automatically install evil if
            # not available. My emacs configuration should be able to
            # sit on top of any emacs distribution..
            # exit 0

            # It's meant to work for recent emacs versions.
            # EMACS_VERSION=26

            # I'm having problems with emacs 26 on purcell's so try 27
            # Doesn't work. Try 24
            # EMACS_VERSION=27

            # uptimes is breaking startup on 24. Let me try with this
            EMACS_VERSION=26

            EMACS_USER_DIRECTORY="$MYGIT/purcell/emacs.d"
            SOCKET="PURCELL"
            EMACS_VARIANT="PURCELL"
            :
        }
        ;;

    pu|prelude) # prelude
        {
            # lit "$VAR"
            EMACS_USER_DIRECTORY="$MYGIT/bbatsov/prelude"
            # SOCKET="PRELUDE"
            SOCKET="prelude"
            EMACS_VERSION=26
            EMACS_VARIANT="PRELUDE"
            :
        }
        ;;

    sc|scimax) # scimax
        {
            EMACS_USER_DIRECTORY="$MYGIT/jkitchin/scimax"

            # I havn't figured out why scimax is setting the server name
            # to user by itself. Roll with it.
            SOCKET="user"

            EMACS_VERSION=27
            EMACS_VARIANT="SCIMAX"
            :
        }
        ;;

    sp|sm|spacemacs) # spacemacs
        {
            EMACS_USER_DIRECTORY="$MYGIT/spacemacs"
            EMACS_VERSION=26
            SOCKET="SPACEMACS"
            EMACS_VARIANT="SPACEMACS"
        }
        ;;

    dm|doom) # spacemacs
        {
            EMACS_USER_DIRECTORY="$MYGIT/hlissner/doom-emacs"
            EMACS_VERSION=26
            SOCKET="DOOM"
            EMACS_VARIANT="DOOM"
        }
        ;;

    d|default|*) # default
        {
            # Do not change things in here. It will break when
            # non options appear after options
            # SOCKET="DEFAULT"
            :
        }
        ;;
esac

# lit "SOCKET: $SOCKET $$"

# Choose emacs version
case "$opt" in
    -27) {
        EMACS_VERSION=27

        # I have emacs27. If I want emacs25 features then I have to check
        # out a copy of emacs25.

        SOCKET="${SOCKET}_25"

        # It's the same directory but a different socket
        # EMACS_USER_DIRECTORY="${EMACS_USER_DIRECTORY}_$EMACS_VERSION"
    }
    ;;

    -26) {
        EMACS_VERSION=26
        SOCKET="${SOCKET}_26"
    }
    ;;

    *)
esac

if test "$1" = "-27"; then
    shift
fi

if test "$1" = "-26"; then
    shift
fi

eclog() {
    # eval ARG=\${$i}

    lit "$1: $2" >> /tmp/ec.txt
    return 0
}

# -s Choose socket name. Append to distribution name.
# magit, eww
if test "$1" = "-s"; then
    SOCKET="${SOCKET}_$2"

    case $2 in
        org) # org mode
            {
                EMACS_VERSION=26
            }
            ;;

        *)
    esac

    shift
    shift
fi

eclog EMACS_VERSION "$EMACS_VERSION"
eclog EMACS_VARIANT "$EMACS_VARIANT"
eclog INVOCATION "$0 $@"

if test "$EMACS_VERSION" = "27" || test "$EMACS_VARIANT" = "SCIMAX"; then
    export PATH="$HOME/local/bin:$PATH"

    EMACS_BIN=$HOME/local/bin/emacs
    EMACSCLIENT_BIN=$HOME/local/bin/emacsclient

    # lit "Using v25" 1>&2
    #SOCKET="${SOCKET}_27" # this is disabled because scimax forces the socket name

elif test "$EMACS_VERSION" = "26" || test "$EMACS_VARIANT" = "SPACEMACS"; then
    export PATH="$HOME/local/emacs26/bin:$PATH"

    EMACS_BIN=$HOME/local/emacs26/bin/emacs
    EMACSCLIENT_BIN=$HOME/local/emacs26/bin/emacsclient

    # This adds it on recursively so forget it at the moment. I don't
    # need the emacs24 version anyway
    # SOCKET="${SOCKET}_26"
else
    export PATH="/usr/bin:$PATH"
fi


export EMACS_VARIANT
export EMACS_VERSION

export EMACS_USER_DIRECTORY
export EMACS_BIN
export EMACSCLIENT_BIN

# This is evil. Use export instead
# -fs Exact socket name
# magit, eww
if test "$1" = "-fs"; then
    SOCKET="$2"

    shift
    shift
fi



while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -e) {
        elisp="$2$elisp"
        shift
        shift
    }
    ;;

    -f) {
        elisp="($2)$elisp"
        shift
        shift
    }
    ;;

    -ci|-ic|-fi|-ei|-if) {
        elisp="(call-interactively '$2)$elisp"
        shift
        shift
    }
    ;;

    -eid) {
        elisp="(call-interactively '$2)$elisp(delete-frame)"
        shift
        shift
    }
    ;;

    -df) {
        elisp+="(delete-frame)"
        shift
        shift
    }
    ;;


    -h) {
        elisp="(describe-function '$2)$elisp"
        shift
        shift
    }
    ;;

    -gd) {
        elisp="(find-function '$2)$elisp"
        shift
        shift
    }
    ;;

    *) break;
esac; done

# p "$elisp"

# The only way to prevent emacs using a socket, even a default one
if test "$1" = "-S"; then
    SOCKET=

    shift
fi

debug_mode_enabled() {
    case "$-" in
        *x*) true;;
        *v*) true;;
        *) false;;
    esac
}


export SERVER_NAME="$SOCKET"

# This is a must
export SOCKET


# this works now
# echo hi | tspv -fa sp +1:1
if stdin_exists; then
    FT_DETECT=n
    ## Need to be able to select a filetype
    while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
        -aft) {
            FT_DETECT=y
            shift
        }
        ;;

        *) break;
    esac; done

    if test "$FT_DETECT" = "y"; then
        elisp+="(detect-language-set-mode)"
    fi

    tempfile="$(mktemp emacs-stdin-$USER.XXXXXXX --tmpdir | ds e-stdin-file)"
    cat - > "$tempfile"
    exec </dev/tty

    if [ -n "$GOTO_LINE" ] && [ -n "$GOTO_COLUMN" ]; then
        elisp+="(goto-line $GOTO_LINE)(move-to-column $GOTO_COLUMN)"
    elif [ -n "$GOTO_LINE" ] && ! [ -n "$GOTO_COLUMN" ]; then
        # client_ops+=" +$GOTO_LINE "
        elisp+="(goto-line $GOTO_LINE)"
    fi


    new_arg_string="--eval $(a- q "(progn ($find_file_command $(a- qf "$tempfile"))(set-visited-file-name nil)(rename-buffer $(a- qf "*stdin*") t)$elisp)")"

    # lit "$new_arg_string"
    # exit 0

    eval "e c $new_arg_string"
    exit $?

    exit 0
fi

. $HOME/scripts/libraries/bash-library.sh

# quoted_arguments()

# exec 2>/dev/null

#echo "'$1'"
#exit 0

if test "$sn" = "ec"; then
    f=c
elif test "$sn" = "ecn"; then
    f=c
elif [ -n "$1" ] && [ -e "$1" ] && ! [ "$1" == c ]; then
    # e c is not trying to open a directory named c, usually.
    f=c
elif [ -z "$f" ]; then
    f="$1"
    shift
fi

eclog OP "$f"

eclog EMACS_USER_DIRECTORY "$EMACS_USER_DIRECTORY"
eclog SERVER_NAME "$SERVER_NAME"

export EMACS_USER_DIRECTORY
export SERVER_NAME

# echo "$f"
# exit
# echo hi
case "$f" in
    sd|start-daemon) # start daemon
        {

        CMD="$(cmd "$@")"

        # CMD="$(quoted_arguments $@)"

        : ${SOCKET:="DEFAULT"}

        ! test "$QUIET" = "y" && print_err "Boostrapping emacs daemon $SOCKET... "

        (

            # I haven't figured out why scimax is not setting the server name
            # properly

            # ! debug_mode_enabled && exec &>/dev/null
            # Not sure why it's not working
            test "$QUIET" = "y" && exec &>/dev/null

            # lit "$SOCKET" 1>&2

            # lit "$EMACS_USER_DIRECTORY"
            # lit "$SERVER_NAME"

            export EMACS_VERSION
            # echo "$CMD"
            # exit 0

            if [ -n "$SOCKET" ]; then
                e running && exit 0

                eval "TERM=$EMACS_TERM_TYPE $EMACSCLIENT_BIN -nta '' -s ~/.emacs.d/server/$SOCKET $CMD"

                # not possible
                # sp -v sd --debug-init
                # not possible
                # eval "TERM=$EMACS_TERM_TYPE $EMACS_BIN --daemon -nta '' -s ~/.emacs.d/server/$SOCKET $CMD"
            else
                e running && exit 0

                eval "TERM=$EMACS_TERM_TYPE $EMACSCLIENT_BIN -nta '' $CMD"
            fi
        )

        ! test "$QUIET" = "y" && print_err "server now running."
        exit 0
    }
    ;;

    running) { # test running
        # lit "SOCKET: $SOCKET $$"
        # lit "server_name: $SERVER_NAME"
        # lit "dir: $EMACS_USER_DIRECTORY"
        # exit 0
        # open a new emacs window then quickly close it, returning true on success. If no emacs server exists, the alternate editor is /bin/false, which returns false.
        # test "$QUIET" = "y" && exec &>/dev/null
        # echo $SOCKET $EMACSCLIENT_BIN
        # exit 0


        if [ -n "$SOCKET" ]; then
            # lit "hassocket"
            # unbuffer SERVER_NAME=\"$SERVER_NAME\" EMACS_USER_DIRECTORY=\"$EMACS_USER_DIRECTORY\" $EMACSCLIENT_BIN -nw -a false -e '(delete-frame)' -s ~/.emacs.d/server/$SOCKET ) &>/dev/null

            $EMACSCLIENT_BIN -a false -e 't' -s ~/.emacs.d/server/$SOCKET &>/dev/null

            # This way hangs now if unbuffer is used instead of a real
            # terminal
            # ( unbuffer $EMACSCLIENT_BIN -nw -a false -s ~/.emacs.d/server/$SOCKET -e '(delete-frame)' )
        else
            # ( unbuffer $EMACSCLIENT_BIN -nw -a false -e '(delete-frame)' )

            $EMACSCLIENT_BIN -a false -e 't' &>/dev/null
        fi
        exit $?

    }
    ;;

    byte-compile) {
        dir="$1"; : ${dir:="~/.emacs.d"}
        dir="$(eval lit "$dir")" # expand

        $EMACS_BIN -batch -eval "(byte-recompile-directory (expand-file-name $(a- qf "$dir")) 0)"
        exit $?
    }
    ;;

    byte-compile-force) {
        dir="$1"; : ${dir:="~/.emacs.d"}
        dir="$(eval lit "$dir")" # expand

        cd "$dir"

        find . -path '*.el' | while read line; do { cd `dirname "$line"`; emacs -Q --batch -L . -f batch-byte-compile "$line"; } done

        exit $?
    }
    ;;

    -ar|ar|ra|-ra|-refresh-all) {
        for d in sp pc og e pd; do
            $d c -e "(package-refresh-contents)(revert-and-quit-emacsclient-without-killing-server)"
        done

        exit $?
    }
    ;;

    -ai|ai|ia|-ia|-install-all) {
        # Example
        # e -D prelude -i traad
        # e -D spacemacs -i traad
        # e -D scimax -i traad
        # e -i traad

        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -r) {
                pre_cmd="(package-refresh-contents)"
                shift
            }
            ;;

            *) break;
        esac; done

        for d in sp pc og e pd xr; do
            # Can't have a while loop nested in a for loop without
            # using a subshell
            (
            while [ $# -gt 0 ]; do pkg_name=$1
                # package-refresh-contents
                echo "$d (package-install ...) $pkg_name" 1>&2

                $d c -e "$pre_cmd(package-install '$pkg_name)(revert-and-quit-emacsclient-without-killing-server)"

                echo "$pkg_name" | append-uniq $EMACSD/packages.txt

                shift
            done
            )
        done

        exit $?
    }
    ;;

    fi|-fi|fast-install) {
        # Example
        # e -D prelude -i traad
        # e -D spacemacs -i traad
        # e -D scimax -i traad
        # e -i traad


        while [ $# -gt 0 ]; do pkg_name=$1

            e c -e "(package-install '$pkg_name)(revert-and-quit-emacsclient-without-killing-server)"

            shift
        done

        exit $?
    }
    ;;

    i|-i|package-install) {
        # Example
        # e -D prelude -i traad
        # e -D spacemacs -i traad
        # e -D scimax -i traad
        # e -i traad

        # This doesn't work
        #$EMACS_BIN -batch -eval "(package-install \"$2\")"
        # $EMACS_BIN -batch -eval "(package-initialize)(package-install \"$2\")"

        # emacs --batch -l ~/.emacs.d/init.el
        # This is a better way to load lisp files

        # (require 'package)


        # Package to be installed
        pkg_name=$1

        # Elisp script is created as a temporary file, to be removed after installing
        # the package
        elisp_script_name=$(mktemp /tmp/emacs-pkg-install-el.XXXXXX)
        elisp_code="
;; Install package from command line. Example:
;;
;;   $ emacs --batch --expr \"(define pkg-to-install 'smex)\" -l emacs-pkg-install.el
;;
(require 'package)
(package-initialize)
(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\"))
(add-to-list 'package-archives '(\"marmalade\" . \"https://marmalade-repo.org/packages/\"))
(add-to-list 'package-archives '(\"melpa-stable\" . \"http://stable.melpa.org/packages/\") t)
(add-to-list 'package-pinned-packages '(cider . \"melpa-stable\") t)

;; Fix HTTP1/1.1 problems
(setq url-http-attempt-keepalives nil)

(package-refresh-contents)

(package-install pkg-to-install)"

        echo "$elisp_code" > $elisp_script_name

        # if [ $# -ne 1 ]
        # then
          # echo "Usage: `basename $0` <package>"
          # exit 1
        # fi

        $EMACS_BIN --batch --eval "(defconst pkg-to-install '$pkg_name)" -l $elisp_script_name

        # Remove tmp file
        rm "$elisp_script_name"

        exit $?
    }
    ;;

    p|packages) {
        e c -e "(list-packages)"
        exit $?
    }
    ;;

    q|quit) {
        # printf -- "%s\n" "$SOCKET" 2>/dev/null

        if e running; then
            e c -e "(kill-emacs)"
            printf -- "%s\n" "$SOCKET is dead" 1>&2
        else
            printf -- "%s\n" "$SOCKET not running" 1>&2
        fi

        # if [ -n "$SOCKET" ]; then
        #     if test -f ~/.emacs.d/server/$SOCKET; then
        #         # This should forward the socket
        #     fi
        # fi

        # exec 2>&3
    }
    ;;

    r|restart) {
        timeout 5 unbuffer e q
        e k
        e sd
    }
    ;;

    st|stack-trace) {
        e k SIGUSR2

        # if [ -n "$SOCKET" ]; then
    }
    ;;

    k|kill) {
        signal="$1"; : ${signal:="INT"}

        # printf -- "%s\n" "$SOCKET" 2>/dev/null

        exec 3>&2
        exec 1>/dev/null
        exec 2>/dev/null

        # lit "$SOCKET"
        if [ -n "$SOCKET" ]; then
            {
                lc_socket="$(lit "$SOCKET" | sed 's/_.*$//' | c lc)"
                COLUMNS=10000 ps -ef |grep "e -D $lc_socket"

                u ps -ef | grep emacs | sed -n "/emacs --daemon=.*\/$SOCKET\$/p"
            } | field 2 | {
                pids="$(cat)"
                lit "$pids" | xargs kill
                #sleep 1
                #lit "$pids" | xargs kill -9
            }
        else
            ps -ef | grep emacs | sed -n "/emacs --daemon=.*\/DEFAULT\$/p" | field 2 | {
                pids="$(cat)"
                lit "$pids" | xargs kill
                lit "$pids" | xargs kill -9
            }
        fi

        exec 2>&3

        print_err "$SOCKET is dead"
    }
    ;;

    # Use xc instead to start the client. This doesn't yet select the
    # correct distribution
    x-gui-disabled) { # x|gui) { # start x11 gui version
        if test "$1" = "-e"; then
            # Change parameter 1
            set -- "--exec" "${@:2}"
        fi

        CMD="$(cmd "$@")"

        # exec &>/dev/null

        # CMD="$(quoted_arguments $@)"

        # export SERVER_NAME="$SERVER_NAME"
        # export EMACS_USER_DIRECTORY="$EMACS_USER_DIRECTORY"

        case $1 in
            n) {
                $EMACS_BIN $NOTES
                exit $?
            }
            ;;

            *)  {
                print_err "$EMACS_BIN $CMD"
                # printf -- "%s\n" "/usr/bin/emacs $@"
                # exit 0
                # Need to finish q so elisp command is properly quoted.
                # lit "$EMACS_BIN $CMD"
                eval "$EMACS_BIN $CMD"
                exit $?
            }
            ;;
        esac

        eval "$EMACS_BIN $CMD"
        exit $?
    }
    ;;

    c|-x|x|e|client) { # start emacs client

        # Unfortunately, I have to disable starting the server
        # automatically until the tmux script is very stable.


        if ! e running; then
            echo "Can't start server while tm is unstable"
            exit 1
        fi


        if test "$f" = "x" || test "$f" = "-x"; then
            client_ops="-c " # gui -x
        else
            client_ops="-t "
        fi

        # Make these options do something
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -l|-line) {
                GOTO_LINE="$2"
                shift
                shift
            }
            ;;

            -c|-col|-column) {
                GOTO_COLUMN="$2"
                shift
                shift
            }
            ;;

            +*:*) {
                GOTO_LINE="$(p "$opt" | mcut -d'[+:]' -f2)"
                GOTO_COLUMN="$(p "$opt" | mcut -d'[+:]' -f3)"

                shift
            }
            ;;

            +[0-9]*) {
                GOTO_LINE="$(p "$opt" | mcut -d+ -f2)"
                shift
            }
            ;;

            +/*) { # pattern
                pattern="$(p "$opt" | mcut -d+/ -f2 | s chomp | qne)"

                shift
            }
            ;;

            -x) {
                # Erase the -t. Add a -c.
                client_ops+="-c "
                shift
            }
            ;;

            -e|--eval) {
                # elisp+="$2"
                elisp="$2$elisp"
                # p "$elisp" | tv
                shift
                shift
            }
            ;;

            -eid) {
                elisp="(call-interactively '$2)$elisp(delete-frame)"
                shift
                shift
            }
            ;;

            -ei) {
                elisp="(call-interactively '$2)$elisp"
                shift
                shift
            }
            ;;

            -df) {
                elisp+="(delete-frame)"
                shift
                shift
            }
            ;;

            *) break;
        esac; done

        # printf -- "%s\n" "$SOCKET" 1>&2

        # A second chance to change the SOCKET or add to it for. Also, for ec
        if test "$1" = "-s"; then
            SOCKET="${SOCKET}_$2"

            shift
            shift
        fi


        #if [ -f "$1" ] && ! [ -n "$2" ]; then # one file argument
        if [ -n "$1" ] && [ -f "$1" ] && [ "$#" -eq 1 ]; then # one file argument
            file_path="$1"
            # file_path="$(p "$file_path" | qne)"
            elisp="($find_file_command $(aqf "$file_path"))$elisp"
            shift

        # elif [ -d "$1" ] && ! [ -n "$2" ]; then
        elif [ -n "$1" ] && [ "$#" -eq 1 ] && [ -d "$1" ]; then # one directory argument
            file_path="$1"
            # file_path="$(p "$file_path" | qne)"
            elisp="(dired $(aqf "$file_path"))$elisp"
            shift

        elif [ -n "$1" ] && [ -f "$1" ] && [ "$#" -eq 3 ] && tt -i "$2" && tt -i "$3"; then # one file argument and 2 int arguments
            file_path="$1"
            # file_path="$(p "$file_path" | qne)"
            elisp="($find_file_command $(aqf "$file_path"))$elisp"

            GOTO_LINE="$2"
            GOTO_COLUMN="$3"
            shift
            shift
            shift

        elif lit "$1" | grep -q -P '^[a-zA-Z0-9_.-]+\.[a-zA-Z0-9_-]+$' && ! [ -f "$1" ]; then # one argument that looks like a file name (because it has an extension)
            # If it looks like a path name

            # I should really do the touch in elisp but not actually
            # create until save
            file_path="$1"
            # The interactive version of find-file doesn't need the path
            # to exist. Do I actually need to touch this? No I just
            # tested. I do not.
            # touch "$file_path"
            # file_path="$(p "$file_path" | qne)"
            elisp="($find_file_command $(aqf "$file_path"))$elisp"
            shift

        elif test -n "$1"; then # one argument
            :

        fi

        if [ -n "$GOTO_LINE" ] && [ -n "$GOTO_COLUMN" ]; then
            elisp+="(goto-line $GOTO_LINE)(move-to-column $GOTO_COLUMN)"
        elif [ -n "$GOTO_LINE" ] && ! [ -n "$GOTO_COLUMN" ]; then
            # client_ops+=" +$GOTO_LINE "
            elisp+="(goto-line $GOTO_LINE)"
        fi

        if [ -n "$elisp" ]; then
            elispsh="-e $(aqf "(progn $elisp)")"
        fi
        # lit "$elispsh" | tv
        # exit 0

        CMD="$(cmd "$@")"

        # CMD="$(quoted_arguments $@)"

        export EMACS_USER_DIRECTORY
        # export SERVER_NAME

        # lit "$SOCKET"
        # lit "$SERVER_NAME"
        # lit "$EMACSCLIENT_BIN"
        # lit "$EMACS_USER_DIRECTORY"
        # exit 0
        # exit 0

        if [ -n "$SOCKET" ]; then
            ! e running && ( lit "emacs ~ Starting $SOCKET server" 1>&2; e sd )

            new_cmd="TERM=$EMACS_TERM_TYPE $EMACSCLIENT_BIN -a '' $client_ops -s ~/.emacs.d/server/$SOCKET $elispsh $CMD"
            # lit "$new_cmd"
            eval "$new_cmd"

            # This is annoying when closing windows unless I set this
            exit 0

        else
            ! e running && e sd

            eval "TERM=$EMACS_TERM_TYPE $EMACSCLIENT_BIN $client_ops $elispsh $CMD"
        fi
        # This slows it all right down. It's only useful when quitting
        # remotely. Forget it. It's not worth it.
        # reset

        # This way may be faster and might work
        stty sane
        tput rs1

        # It might help, but nothing works

        # tty > /tmp/tty.txt

        # tput reset
        # ls

        # tput reset # apparently tput reset does what reset does but without delay. Well no.
        # reset

        # expect -c "send \003;" > `tty`

        # clear
        # sleep 1
        # Print the prompt
        # print -P "$PS1"

        # Nothing works. Except reset, which is slow
        # kill -SIGWINCH $$
        # kill -INT $$
        # sleep 1
        # echo $'\cc' >`tty`
        # exec </dev/tty `# see etty`

        exit $?
    }
    ;;

    clean-byte-compiled|clean-elc-files) {
        set -xv
        # If emacs is not starting, this is a good thing to do
        (
            cd "$EMACSD"
            find . -name "*.elc" -type f | xargs rm -f
            cd "$MYGIT/spacemacs"
            find . -name "*.elc" -type f | xargs rm -f
            cd "$MYGIT/bbatsov/prelude"
            find . -name "*.elc" -type f | xargs rm -f
            cd "$MYGIT/jkitchin/scimax"
            find . -name "*.elc" -type f | xargs rm -f
            cd "$MYGIT/philippe-grenet/exordium"
            find . -name "*.elc" -type f | xargs rm -f
        )
        exit $?
    }
    ;;

    -nw|nw|standalone) {

        debug_init=n
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            -d) {
                debug_init=y
                shift
            }
            ;;

            *) break;
        esac; done

        # CMD="$(quoted_arguments $@)"

        if test "$DEBUG_INIT" = "y"; then
            eval "$EMACS_BIN" -nw --debug-init "$@"
        else
            eval "$EMACS_BIN" -nw "$@"
        fi
        exit $?
    }
    ;;

    tf|-tf) {
        tf_scratch="$(nix tf scratch || echo /dev/null)"
        # trap "rm \"$tf_scratch\" 2>/dev/null" 0

        e c "$tf_scratch" "$@"
    }
    ;;

    *) # normal emacs parameters
        {

        CMD="$(cmd "$@")"

        if [ -n "$elisp" ]; then
            # elisp="$(p "$elisp" | q)"
            # CMD="-e $elisp$CMD"

            CMD="-e $(aq "$elisp")"
        fi

        # CMD="$(quoted_arguments $@)"

        # Start emacs client by default
        # echo "e c $CMD" | less
        eval "e c $CMD"

        # if the daemon exists, start emacs client

        # if e running; then
        #     eval "e c $CMD"
        # else
        #     print_err "Not creating server."
        #     eval "$EMACS_BIN -nw $f $CMD"
        # fi
    }
    ;;
esac
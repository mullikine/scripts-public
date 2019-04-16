#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -noansi) {
        DISABLE_COLORIZE=y
        shift
    }
    ;;

    *) break;
esac; done

CMD="$(cmd "$@")"

cmd="/usr/bin/make $CMD"

opt="$1"
shift
case "$opt" in
    launchall) {
        docker kill $(docker ps -q)
        sleep 0.1
        docker run -d -p 9411:9411 openzipkin/zipkin
    }
    ;;

    launchcluster) {
        cmd="nvc -w eval \"$cmd | tless +F -S\""
        kill-port 8001
        DISABLE_COLORIZE=y
    }
    ;;

    # launchplatform

    launchplatform) {
        # does this kill chrome? -- not sure
        kill-port 8002
        # kill-port 9411 # zipkin

        # We also use tless to create a file path that we can then query
        # Because we want to be able to scrape things from the platform
        # dynamically.
        LESSS=y
        DISABLE_COLORIZE=y
    }
    ;;

    launchflow) {
        cmd="$cmd"
        DISABLE_COLORIZE=y

        # does this kill chrome? - yes
        # kill-port 8008

        # exec 1> >(colorise-build-stdout.sh | rosie match all.things)
        # exec 2> >(colorise-build.sh | rosie match all.things)

        LESSS=y
    }
    ;;

    *)
esac

# This is because the script runs mate-terminal
# test "$HOME/go/src/github.com/codelingo/platform" -ef "$(pwd)" && DISABLE_COLORIZE=y

echo "$$ $cmd" | udl | hls -i -f dred -b nblack ".*"
# | hls -i -f red -b dblue cmake

test "$INSIDE_NEOVIM" = "y" && DISABLE_COLORIZE=y

if ! test "$DISABLE_COLORIZE" = "y"; then
    exec 1> >(colorise-build-stdout.sh)
    exec 2> >(colorise-build.sh)
fi

func_trap() {
    :
}

if test "$LESSS" = "y"; then
    trap func_trap INT PIPE
    # exec </dev/tty `# see etty`

    # This saves the name of the temporary file to a variable
    # gs make-launchplatform | xa v

    if ! test "$DISABLE_COLORIZE" = "y"; then
        unbuffer $cmd 2>&1 | tless -fid "make-$opt" +F -S
    else
        eval "$cmd"
    fi

    # cmd="nvc -w eval \"$cmd | tless +F -S\""
    # eval "$cmd"
else
    eval "$cmd"
fi

if ! test "$DISABLE_COLORIZE" = "y"; then
    # If not a tty but TTY is exported from outside, attach the tty
    if test "$mytty" = "not a tty" && ! [ -z ${TTY+x} ]; then
        lit "Attaching tty"
        exec 0<"$TTY"
        exec 1>"$TTY"
    else
        # Otherwise, this probably has its own tty and only needs normal
        # reattachment (maybe stdin was temporarily redirected)
        exec </dev/tty
    fi
fi

sleep 0.3 # added a sleep for the last line of output to be flushed
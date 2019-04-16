#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` )

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    aq "$ARG"
    printf ' '
done
eval ARG=\${$i}
aq "$ARG"
)"

CMD="$(p "$CMD" | sed 's/ \+/\n\t/g' | hlgreen ".*")"

lit "Running: $0 $CMD" | mnm


# This is rsync, but what about repeat-string?
# That would be "s rs"
# or: rps

# Use -s ( protect args ) and enclose your path in quotes :
# rsync -savz user@server:"/my path with spaces/another dir/" "/my destination/"
# -L is useful sometimes


exclusions=
opts=

CAUTION=y
NOGIT=
NOSWAP=
PROGRESS=
INPLACE=y
VERIFY=n
LOCAL_SUDO=n
REMOTE_SUDO=n
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -ng|-nogit) {
        NOGIT=y
        shift
    }
    ;;

    -ns|-noswap) {
        NOSWAP=y
        shift
    }
    ;;

    -p) {
        PROGRESS=y
        shift
    }
    ;;

    -nc) {
        CAUTION=n
        shift
    }
    ;;

    +i|-ni|-na|-nia) {
        INPLACE=
        shift
    }
    ;;

    -v) {
        VERIFY=y
        shift
    }
    ;;

    -local-sudo) {
        LOCAL_SUDO=y
        
        # TODO
        # sudo rsync -aqv -e "ssh -i ~user/.ssh/id_rsa" ${user}@${remote_host}:/etc/bind /etc/bind
        shift
    }
    ;;

    -rs|-remote-sudo) {
        REMOTE_SUDO=y
        shift
    }
    ;;

    *) break;
esac; done

exclusions+=" --exclude .cache "

if test "$NOGIT" = "y"; then
    exclusions+=" --exclude .git/ --exclude .gitignore --exclude TODO "
fi

if test "$NOSWAP" = "y"; then
    exclusions+=" --exclude '*~' --exclude '.#*' "
fi

opts=" -a -rtlhx -pug -s "

if test "$INPLACE" = "y"; then
    opts+=" --inplace --append "
fi

# This is for when the remote file contains extra data at the end
# Ignore times can be very slow but may be the only sure way.
# Not even it works.
# This is simply not working
# rs -rs -aAXvc --ignore-times --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} $HOME/notes2018/ instance-1:/morgan$HOME/notes2018

if test "$VERIFY" = "y"; then
    opts+=" --append-verify --ignore-times "
fi

if test "$PROGRESS" = "y"; then
    opts+=" --progress "
fi

if test "$REMOTE_SUDO" = "y"; then
    opts+=" --rsync-path=\"sudo rsync\" "
fi

cmd="/usr/bin/rsync $opts $exclusions $@"
echo "$cmd" | mnm | udl 1>&2
# exit 0

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

test "$CAUTION" = "y" && is_tty && pak

eval "$cmd"
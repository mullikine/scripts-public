#!/bin/bash
export TTY

auto_only=n
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -a) {
        auto_only=y
        shift
    }
    ;;

    *) break;
esac; done

url="$1"
shift

mkdir -p $DUMP$HOME/notes2018/ws/youtube/subs
cd $DUMP$HOME/notes2018/ws/youtube/subs

clean_while_downloading() {
    # awk 1 does not flush by default
    awk1 | while IFS=$'\n' read -r line; do
        timeout 2 bash -c "until test -s \"$line\"; do sleep 0.5; done"
        # here, need to wait until the file is written to
        # a beep
        if [ -f "$line" ]; then
            cat "$line" | clean-subs | sponge "$line"
            printf -- "%s\n" "$line" | sed "s=^=$(pwd)/="
        fi
    done
}

#clean_subs() {
#    sed -e '0,/^$/d' -e 's/ align:start.*//' -e 's/<[^>]*>//g' -e '/^[0-9]/d' -e '/^\s*$/d' | uniq
#}

# exec 2>&1;

if ! test "$auto_only" = "y"; then
    youtube-dl --sub-lang en --all-subs --skip-download "$url" 2>/dev/null | soak | sed -u -n 's/.*Writing video subtitles to: \(.*\)/\1/p' | tee /dev/stderr | clean_while_downloading
fi

if ! [ -n "$subs" ]; then
    echo "getting auto subs" 1>&2
    youtube-dl --sub-lang en --write-auto-sub --skip-download "$url" 2>/dev/null | soak | sed -u -n 's/.*Writing video subtitles to: \(.*\)/\1/p' | tee /dev/stderr | clean_while_downloading
fi

# printf -- "%s" "$subs" | sed "s=^=$(pwd)/="
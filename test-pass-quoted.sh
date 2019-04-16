#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# shift

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    aq "$ARG"
    printf ' '
done
eval ARG=\${$i}
aq "$ARG"
)"

echo "$#"

opts="-1 -2"

# test-pass-quoted-child.sh "$@"
# eval test-pass-quoted-child.sh "$@"
echo
test-pass-quoted-child.sh $opts "$@"
echo
eval "test-pass-quoted-child.sh $opts $CMD"

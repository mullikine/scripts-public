free_cs() {
    # This works

    stty stop undef
    stty start undef 
}

isbehind()
{
    # Can use to check if a branch is behind origin/master
    vc g is-behind
}

debug_mode_enabled() {
    case "$-" in
        *x*) true;;
        *v*) true;;
        *) false;;
    esac
}

# test -t :: tests if as output stream is a tty
stdin_exists() {
    ! [ -t 0 ]
}

# test -t :: tests if as output stream is a tty
is_tty() {
    # If stout is a tty
    [ -t 1 ]
}

# test -t :: tests if as output stream is a tty
stdout_capture_exists() {
    # WARNING: false positives
    # Could have no tty but nothing listening

    ! is_tty
}

# This breaks sh so .profile won't work on login
# quoted_arguments() {
#     # sh doesn't like this
# 
#     CMD=''
#     for (( i = 1; i <= $#; i++ )); do
#         eval ARG=\${$i}
#         CMD="$CMD $(printf -- "%s" "$ARG" | q)"
#     done
# 
#     printf -- "%s\n" "$CMD"
# 
#     return 0
# }

# This is the best way
pathmunge () {
        if ! printf -- "%s" "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH="$PATH:$1"
           else
              PATH="$1:$PATH"
           fi
        fi
}

prepend_to_path() {
    new="$1"

    # PATH="$(printf -- "%s" "$PATH" | /bin/sed "s/:$new://")"
    # PATH="$(printf -- "%s" "$PATH" | /bin/sed "s/:$new\$//")"

    case ":${PATH:=$new}:" in
        *:$new:*) ;;
        *) PATH="$new:$PATH" ;;
    esac
    printf -- "%s\n" "$PATH"

    return 0
}

append_to_path() {
    new="$1"

    # PATH="$(printf -- "%s" "$PATH" | /bin/sed "s/:$new://")"
    # PATH="$(printf -- "%s" "$PATH" | /bin/sed "s/^$new://")"

    case ":${PATH:=$new}:" in
        *:$new:*) ;;
        *) PATH="$PATH:$new" ;;
    esac
    printf -- "%s\n" "$PATH"

    return 0
}
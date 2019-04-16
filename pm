#!/bin/bash
export TTY

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` ) & disown

# package management, for all languages

# | p        | lang       |
# |----------+------------|
# | bundler  | ruby       |
# | composer | php        |
# | npm      | javascript |
# | cargo    | rust       |
# | yarn     | javascript |

sn="$(basename "$0")"

case "$sn" in
    mpl) { manager=perl; }; ;;

    *) {
        manager="$1"
        shift
    }
    ;;
esac

case "$manager" in
    py|python|pip) {
        py i "$1"
    }
    ;;

    lit|perl) {
        (

        f="$1"
        shift
        case "$f" in
            i) {
                for p in "$@"
                do
                    # example
                    # sudo cpanm --installdeps Perl::Critic
                    # sudo cpanm Perl::Critic

                    sudo cpanm --installdeps "$p"
                    sudo cpanm "$p"

                done
            }
            ;;

            template) {
                :
            }
            ;;

            *)
        esac

        )

    }
    ;;

    template) {
        :
    }
    ;;

    *)
esac
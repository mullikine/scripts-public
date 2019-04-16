#!/bin/bash
export TTY

# Scripts for x

# xs fish-complete "vim -"

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -n) {
        DRY_RUN=y
        shift
    }
    ;;

    *) break;
esac; done

export DRY_RUN

opt="$1"
shift
case "$opt" in
    eack) {
        thing="$1"
        # thing="$(p "$thing" | q -ftln)"
        shift

        x -d -tmc zsh -nto -e » -s "eack $(aqf "$thing")" -a
    }
    ;;

    show-modica-card) {
        x -sh 3llo -nto -e ">" -s "card show 5c2ee4c5810a0e1f8a56436b" -c m -e ">" -s exit -c m -i
    }
    ;;

    fish-complete) {
        cmd="$1"
        x -sh "fish" -e ">" -s "vim -" -c i -i
    }
    ;;

    trello-show-card) {
        id="$1"
        notify-send "Not implemented"
        exit 0

        # Need to scrape the screen after listing something out and use that to generate a response.
        x -sh 3llo -e ">" -s "board select" -c m -e Alpha -s "Alpha Sprint" -c m -e ">" -s "card list mine" -c m -i
    }
    ;;

    trello-my-cards) {
        x -sh 3llo -e ">" -s "board select" -c m -e Alpha -s "Alpha Sprint" -c m -e ">" -s "card list mine" -c m -i
    }
    ;;

    trello-my-cards-tm) {
        x -d -tmc 3llo -nto -e ">" -s "board select" -c m -e Alpha -s Alpha -c m -e ">" -s "card list mine" -c m -a
    }
    ;;

    gh-github) {
        x -sh "gq-github" -e "gql>" -s "query{viewer{" -s1 -c i -i
    }
    ;;

    gore) {
        x -sh "gore" -e "gore>" -s ":import fmt" -c m -s "fmt.Pri" -c i -c i -i
    }
    ;;

    turtle) {
        x -sh "ghci" -e "Prelude>" -s ":set -XOverloadedStrings" -c m -s "import Turtle" -c m -e "Turtle>" -s "echo $(aqf "hi")" -c m -i
    }
    ;;

    gh) {
        x -s "gh cs -fs -n 10 \"\\.hs\" \"main.*\\blines\\b\"" -i
    }
    ;;

    eack-top) {
        thing="$1"
        # thing="$(p "$thing" | q -ftln)"
        shift

        x -d -tmc zsh -nto -e » -m "\`" -e » -s "eack --top $(aqf "$thing")" -a
    }
    ;;

    g|git) {

        (

        opt2="$1"
        shift
        case "$opt2" in
            A|-A) {
                # example 1: this adds and starts a git commit message
                # x -m "\`" -m t -m e -m v -i

                # using tmux, do the full sequence
                x -d -tmc zsh -nto -e master -m "\`" -m t -m e -m v -e "/tmp/file" -m '$' -ts 'S-F8' -a
            }
            ;;

            Am|-zsh-amend) {
                #x -d -tmc zsh -nto -e master -m "\`" -m t -cm '^' -a
                # x -d -tmc zsh -nto -e master -m "\`" -m t -s "git amend" -c m -a
                x -d -tmc zsh -nto -e master -m "\`" -m t -s "git amend" -a
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
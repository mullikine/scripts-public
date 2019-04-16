#!/bin/bash
export TTY

# This works atm
# cd "$MYGIT/chiphuyen/sotawhat"; py i -r requirements.txt
# pip3 install -r requirements.txt

# TODO This is how you install without sudo
# pip install s-tui --user

( hs "$(basename "$0")" "$@" </dev/tty ` # Disable tty to pipe content into hs ` ) & disown

stdin_exists() {
    ! [ -t 0 ]
}

STDIN_EXISTS=
if stdin_exists; then
    tf_stdin="$(nix tf stdin || echo /dev/null)"
    trap "rm \"$tf_stdin\" 2>/dev/null" 0

    cat > "$tf_stdin"
    STDIN_EXISTS=y
fi

# Install for both by default
PY3=y
PY2=y
PY36=y

py_opts=
# py_modules="pdb"

export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.full.py

FORCE_RC=n

while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -2) {
        PY2=y
        PY3=n
        PY36=n
        shift
    }
    ;;

    -3) {
        PY2=n
        PY3=y
        PY36=n
        shift
    }
    ;;

    -3.5) {
        PY2=n
        PY3=n
        PY35=y
        PY36=n
        shift
    }
    ;;

    # There is also a python 3.5

    -6) {
        PY2=n
        PY3=n
        PY36=y
        shift
    }
    ;;

    venv) {
        pipenv update --dev
        pipenv shell
        shift
    }
    ;;

    -rc) {
        shift
        opt="$1"
        shift

        FORCE_RC=y

        case "$opt" in
            full) {
                export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.full.py
            }
            ;;

            basic) {
                export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.basic.py
            }
            ;;

            debug) {
                export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.debug.py
            }
            ;;

            math) {
                export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.math.py
            }
            ;;

            shane) {
                export PYTHONSTARTUP=$HOME/notes2018/ws/python/rc/pythonrc.shane.py
            }
            ;;

            *) {
                export PYTHONSTARTUP=$HOME/.pythonrc
            }
            ;;
        esac
    }
    ;;

    -pyc|-compile) {
        rp="$(realpath "$2")"
        dn="$(p "$rp" | u dn)"

        (
        cd "$dn"
        python -m compileall .
        )
        exit 0
        shift
    }
    ;;

    -hs) {
        PY2=n
        PY3=y
        PY36=y
        if test "$PY3" = "y" || test "$PY36" = "y"; then
            python3 -m http.server
        elif test "$PY2" = "y"; then
            python2 -m SimpleHTTPServer
        fi
        shift
    }
    ;;

    -t) {
        py_modules+=",trace"
        shift
    }
    ;;

    -b|ibeta) {
        shift

        while [ $# -gt 0 ]; do
            # --upgrade
            # --quiet
            # --force-reinstall
            test "$PY2" = "y" && msudo pip2 install --upgrade --pre "$1"
            test "$PY3" = "y" && msudo pip3 install --upgrade --pre "$1"
            test "$PY36" = "y" && msudo pip3.6 install --upgrade --pre "$1"
            shift
        done

        exit 0
    }
    ;;
     
    -r|--uninstall|uninstall) {
        shift

        # py i json pprint subprocess pickle numpy scipy xml sqlparse
        # StringIO six time threading functools future

        while [ $# -gt 0 ]; do
            test "$PY2" = "y" && msudo pip2 uninstall -y "$1"
            test "$PY3" = "y" && msudo pip3 uninstall -y "$1"
            test "$PY36" = "y" && msudo pip3.6 uninstall -y "$1"
            shift
        done

        exit 0
    }
    ;;

    -f|f) {
        shift

        # py i json pprint subprocess pickle numpy scipy xml sqlparse
        # StringIO six time threading functools future

        set -xv
        while [ $# -gt 0 ]; do
            test "$PY2" = "y" && msudo pip2 install --upgrade --force-reinstall "$1"
            test "$PY3" = "y" && msudo pip3 install --upgrade --force-reinstall "$1"
            test "$PY36" = "y" && msudo pip3.6 install --upgrade --force-reinstall "$1"
            shift
        done

        exit 0
    }
    ;;

    -e) {
        # This does not work
        # echo "h\"i" | py -rc shane -e "line"
        # This is not tested
        pycmd="-c \"[sys.stdout.write($(p "$2" | qne -ftln) for line in sys.stdin\""
        shift
        shift
    }
    ;;

    -P|P) { # Edit some project
        shift

        pkg="$1"
        case "$pkg" in
            snake) {
                dir=$HOME$VIMCONFIG/common/bundle/snake
                cd "$dir"
                echo
                pwd | mnm
                echo
                CWD="$dir" ipython
                exit $?
            }
            ;;

            *)
                break
        esac

    };
    ;;

    # py i asciinema --upgrade
    -i|i) {
        shift

        pkg="$1"
        shift
        # echo "$pkg"

        case "$pkg" in
            snake) {
                dir=$HOME$VIMCONFIG/common/bundle/snake
                cd "$dir"
                py setup-install
                exit $?
            }
            ;;

            youtube-dl) {
                # Install using python2
                msudo pip2 install "$pkg" "$@"
                exit $?
            }
            ;;

            hylang) {
                msudo pip install git+https://github.com/hylang/hy.git "$@"
                msudo pip2 install git+https://github.com/hylang/hy.git "$@"
                exit $?
            }
            ;;

            gitsome) {
                msudo pip3.5 install "$pkg" "$@"
                exit $?
            }
            ;;

            py2hy) {
                msudo pip install git+https://github.com/woodrush/py2hy.git "$@"
                msudo pip2 install git+https://github.com/woodrush/py2hy.git "$@"
                exit $?
            }
            ;;

            jedi) {
                # $HOME/notes2018/ws/jedi/troubleshooting/notes.org
                # Because numpy completion does not work and neithehr
                # does pydoc, with the latest version of jedi

                # This definitely fixes pydoc and numpy completion

                echo installing old version jedi==0.11.1

                msudo pip2 install jedi==0.11.1 "$@"
                msudo pip3 install jedi==0.11.1 "$@"
                exit $?
            }
            ;;

            *) {
                :
            }
        esac


        # py i json pprint subprocess pickle numpy scipy xml sqlparse
        # StringIO six time threading functools future

        set -xv
        # echo "$PY2 $PY3 $PY36"
        # while [ $# -gt 0 ]; do
            test "$PY2" = "y" && msudo pip2 install "$pkg" "$@"
            test "$PY3" = "y" && msudo pip3 install "$pkg" "$@"
            test "$PY35" = "y" && msudo pip3.5 install "$pkg" "$@"
            test "$PY36" = "y" && msudo pip3.6 install "$pkg" "$@"
            # shift
        # done

        exit 0
    }
    ;;

    -u|u) {
        set -xv
        test "$PY2" = "y" && msudo pip2 install --upgrade pip
        test "$PY3" = "y" && msudo pip3 install --upgrade pip
        test "$PY36" = "y" && msudo pip3.6 install --upgrade pip

        shift
    }
    ;;

    install-file) { # Install a single python file as a module.
        :
    }
    ;;

    s|search) {
        shift

        CMD="$(
        for (( i = 1; i < $#; i++ )); do
            eval ARG=\${$i}
            printf -- "%s" "$ARG" | q
            printf ' '
        done
        eval ARG=\${$i}
        printf -- "%s" "$ARG" | q
        )"

        set -xv
        test "$PY2" = "y" && msudo pip2 search "$CMD"
        test "$PY3" = "y" && msudo pip3 search "$CMD"
        test "$PY36" = "y" && msudo pip3.6 search "$CMD"

        shift
    }
    ;;

    list-modules) {
        python -c "help('modules')"
        shift
    }
    ;;

    si|setup-install) {
        set -xv
        test "$PY2" = "y" && msudo python2 setup.py build -b /tmp/py-installed-files install --record /tmp/py-installed-files
        test "$PY3" = "y" && msudo python3 setup.py build -b /tmp/py-installed-files install --record /tmp/py-installed-files
        test "$PY36" = "y" && msudo python3.6 setup.py build -b /tmp/py-installed-files install --record /tmp/py-installed-files

        shift
        exit 0
    }
    ;;

    sf|show-files) {
        {
            test "$PY2" = "y" && pip show -f "$2"
            test "$PY3" = "y" && pip3 show -f "$2"
            test "$PY36" = "y" && pip3.6 show -f "$2"
        } | less -S +F

        exit 0;
    }
    ;;

    update-shanepy) {
        set -xv
        cd $HOME/notes2018/ws/python/shanepy
        test "$PY2" = "y" && msudo python2 setup.py build -b /tmp/shanepy install --record /tmp/files.txt
        test "$PY3" = "y" && msudo python3 setup.py build -b /tmp/shanepy install --record /tmp/files.txt
        test "$PY36" = "y" && msudo python3.6 setup.py build -b /tmp/shanepy install --record /tmp/files.txt

        shift
    }
    ;;

    *) break;
esac; done


opt="$1"
case "$opt" in
    pip) {
        shift
        :

    }
    ;;

    template) {
        shift
        :
    }
    ;;

    *)
esac

# python -m pudb.run 

# echo "$CMD"
# exit 0

# Both of these work
# pudb uses bpython :)
# eval "python -m pudb.run $CMD"
# eval "python -m pdb -c continue $CMD"

if test "$PY3" = "y"; then
    version=3
elif test "$PY36" = "y"; then
    version=3.6
elif test "$PY2" = "y"; then
    version=2
fi

if [ -n "$py_modules" ]; then
    py_opts+="-m $py_modules"

    if test "$py_modules" = "pdb"; then
        py_opts+=" -c continue"
    fi
fi

if [ -n "$pycmd" ]; then
    py_opts+="$pycmd"
fi

# echo "$PYTHONSTARTUP" | mnm 1>&2

# If you are trying to run a file
if test "$#" -gt 0; then
    last_arg="${@: -1}"

    fp="$last_arg"

    if [ -n "$FORCE_RC" ] && [ -f "$fp" ]; then
        tf_script="$(nix tf script || echo /dev/null)"
        trap "rm \"$tf_script\" 2>/dev/null" 0

        {
            cat "$PYTHONSTARTUP"
            echo
            cat "$fp"
        } > "$tf_script"

        echo "python$version $py_opts $tf_script" 1>&2
        eval "python$version $py_opts $tf_script"
    else
        python_cmd=
        while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
            "") { shift; }; ;;
            -c) {
                python_cmd="$2"
                shift
                shift
            }
            ;;

            *) break;
        esac; done
        
        CMD="$(cmd "$@")"

        # PYTHONSTARTUP doesn't work when commands are supplied as cli
        # params

        # echo PYTHONSTARTUP
        # set -x

        if test -n "$PYTHONSTARTUP"; then
            python_cmd="-c $(aqf "exec(open($(aqf "$PYTHONSTARTUP")).read()); $python_cmd")"
        fi

        if test "$STDIN_EXISTS" = "y"; then
            exec < "$tf_stdin"
        fi

        # echo "python$version $py_opts $python_cmd $CMD"
        eval "python$version $py_opts $python_cmd $CMD"
        exit $?
    fi
else
    eval "python$version" "$@"
fi

# eval "python -m bpdb $CMD"


# By default, try to run the file given as an argument

# Do a detection of the version of python
# python

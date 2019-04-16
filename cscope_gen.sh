#!/bin/bash
# because this is a child shell instead of a function,
# need to export CSCOPE_DB in the .shellrc
eval `resize`
CWD=`pwd`
builtin cd /

# this does not skip, it filters afterwards
#find -L -O3 $CWD \( -not -path ".$CWD/*[.-]*" \) -a \
#    -path ".$CWD/tm2*" -a \
find -L -O3 $CWD \
    -name '*.py' \
    -o -name '*.php' \
    -o -name '*.java' \
    -o -iname '*.[CH]' \
    -o -name '*.cpp' \
    -o -name '*.hpp'  \
    -o -name '*.cc' \
    -o -name '*.hh' \
    > $CWD/cscope.files
#    2>&1 > $CWD/cscope.files | cut -c-$COLUMNS
export CSCOPE_DB=$CWD/cscope.out
builtin cd $CWD
# -b: just build
# -q: create inverted index
cscope -b -q

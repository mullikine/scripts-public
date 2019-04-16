#!/bin/bash
cd "$(git rev-parse --show-toplevel)"
if [ -z "$(echo "$@"|grep -v "\^\!"|grep -v "\.\.")" ]; then
    rev="$@"
else
    rev="$@..HEAD"
fi
changes="$(git diff --name-only $rev)"
# the sed makes sure lines counted are non-empty
nchanges="$(echo "$changes"| sed '/^\s*$/d'|wc -l)"
output="$(
if [ -n "$rev" ] && [ "$rev" != "HEAD..HEAD" ]; then
    git log $rev
    echo
    echo "Changes:"
    echo
fi
echo "$changes"| while read f; do
    if [ -n "$(unbuffer rifle -l "$f"|grep -v "vimtrz"|grep "vim")" ]; then
        wdiff="$(git wdiff $rev -- "$f"|xargs -l -I{} echo "{}"|sed 's/^.*: //g'|awk '{print $6 " " $8 " " $9 " " $11 }')"
        line="$(
        (
        (
        echo "$wdiff"
        ) | xargs -l -I {} echo -n " {}"
        ) |awk '{print $1 $2 " " $3 $4 " " $5 $6 }'|sed 's/inserted/\+/g'|sed 's/changed/~/g'|sed 's/deleted/-/g'
        )"
        if [ -e "$f" ]; then
            if [[ "$(echo "$wdiff"|wc -l)" -eq 1 ]]; then
                echo -n "+"
            else
                echo -n "$line"
            fi
        else
            echo -n "-"
        fi
        echo -e "\t$f"
    else
        echo -e "\t$f"
    fi
done
)"
#if [ $nchanges -gt 0 ]; then
if [ $nchanges -gt 0 ]; then
    #echo "$output"| vim - -V0 -c "set ft=git | redir => gfmap | nmap gf | redir END | let gfmap = matchstr(gfmap,':.*') | exe \\\"nnoremap <buffer> <CR> \\\".gfmap | au BufEnter * unmap gf | setlocal noexpandtab | setlocal tabstop=19 | setlocal virtualedit= | let g:gitid='$rev' | setlocal noautochdir | EraseBadWhitespace"
    echo "$output"| vim - -V0 -S "$HOME/notes2018/programs/vim/scripts/difftool.vim" -c "let g:gitid='$rev' | EraseBadWhitespace"
else
    echo "No changes."
fi
#|column -s '	' -t
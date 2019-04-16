#!/bin/bash
#
# Export Chrome search engine shortcuts to emacs' engine-mode (https://github.com/hrs/engine-mode)
# https://gist.github.com/sshaw/9b635eabde582ebec442a
#


sql="select short_name,keyword,url from keywords where length(keyword) < 3"

source=${1:-$HOME/Library/Application Support/Google/Chrome/Default/Web Data}
[ ! -f "$source" ] && echo "Can't find Chrome DB $source" >&2 && exit 1

set -e

dest="$TMPDIR/$(basename "$source")"

# If Chrome is running $source will be locked
cp "$source" "$dest"
sqlite3 -bail -noheader -list "$dest" "$sql" 2>/dev/null | perl -laF'\|' -nE'
  next unless /\w/ and $F[2] !~ /^chrome-extension:/;
  $F[2] =~ s|%|%%|i;
  $F[2] =~ s|\{\w+\}|%s|;
  $name = (split m|\.|, lc $F[0])[0];
  say qq|(defengine $name "$F[2]" :keybinding "$F[1]")|;
' | sort

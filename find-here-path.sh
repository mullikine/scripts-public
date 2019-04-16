#!/bin/bash

glob="$1"

# -prune removes entries of the predicate before it
# -print adds entries of the predicate before it

exec 2>/dev/null
 
find -L . -path '*/.git*' -prune -o -name "$glob" -print
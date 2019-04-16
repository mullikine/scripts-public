#!/bin/zsh
export TTY

tf_html="$(nix tf html html || echo /dev/null)"
cat > "$tf_html"
# echo "$tf_html" | tv
cat "$tf_html" | xurls
# lynx -dump -listonly "$tf_html"
# trap "rm \"$tf_html\" 2>/dev/null" 0

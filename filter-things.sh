#!/bin/bash
export TTY

IFS= read -rd '' input < <(cat /dev/stdin)

printf -- "%s\n" "$input" | xurls
printf -- "%s\n" "$input" | scrape-dirs.sh
printf -- "%s\n" "$input" | scrape-files.sh
printf -- "%s\n" "$input" | scrape-hex-24

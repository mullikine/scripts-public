#!/bin/bash
export TTY


exec 2>/dev/null


func_trap() {
    exit 0
}

opt="$1"

shift
case "$opt" in
    pdf2txt) {
        paths="*.pdf"
        paths="$(shopt -s nullglob; eval lit "$paths")" # expand

        count="$(lit "$paths" | wc -l)"

        # lit "$count files to convert"

        if [ -n "$paths" ]; then
            c=0
            lit "$paths" | awk 1 | while IFS=$'\n' read -r line; do
                ((c++))

                trap func_trap INT

                lit "[$c/$count] $line -> $line.txt"
                pdf2txt "$line" > "$line.txt"
            done
        fi
        exit 0
    }
    ;;

    *)
esac

CMD="$(
for (( i = 1; i < $#; i++ )); do
    eval ARG=\${$i}
    printf -- "%s" "$ARG" | q
    printf ' '
done
eval ARG=\${$i}
printf -- "%s" "$ARG" | q
)"
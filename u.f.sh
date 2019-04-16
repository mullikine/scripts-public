longest_common_prefix() {
    declare -a names
    declare -a parts
    declare i=0

    names=("$@")
    name="$1"
    while x=$(dirname "$name"); [ "$x" != "/" ]
    do
        parts[$i]="$x"
        i=$(($i + 1))
        name="$x"
    done

    for prefix in "${parts[@]}" /
    do
        for name in "${names[@]}"
        do
            if [ "${name#$prefix/}" = "${name}" ]
            then continue 2
            fi
        done
        echo "$prefix"
        break
    done
}

path_without_prefix() {
    local prefix="$1/"
    shift
    local arg
    for arg in "$@"
    do
        echo "${arg#$prefix}"
    done
}

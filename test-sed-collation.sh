#!/bin/bash
export TTY

for (( i=0; i<=255; i++ )); do 
    printf "== $i - \x$(echo "ibase=10;obase=16;$i" | bc) =="
    echo '' | sed -E "s/[\d$i-\d$((i+1))]]//g"
done

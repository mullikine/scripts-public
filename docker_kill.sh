#!/bin/bash
export TTY

docker ps | awk {' print $1 '} | tail -n+2 > tmp.txt; for line in $(cat tmp.txt); do docker kill $line; done; rm tmp.txt
#!/bin/bash
export TTY

url="$(sed -n '/http.\?:\/\/\(www\.\)\?youtube.com\/watch/p')"
test -n "$url"

#!/bin/bash
export TTY

sed -e :a -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba'
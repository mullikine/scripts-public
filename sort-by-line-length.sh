#!/bin/bash
export TTY

# perl sort with custom comparator
perl -e 'print sort { length($a) <=> length($b) } <>'
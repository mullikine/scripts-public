#!/usr/bin/env python
# -*- coding: utf-8 -*-

import getopt
# echo "hi there whats up" | select-word-by-pos.py -j
try:
    opts, args = getopt.getopt(sys.argv[1:], "j:h", ['job=','help'])

    # except getopt.GetoptError, err:
    # python 3 use as
except getopt.GetoptError as err:
    print str(err)
    error_action

for option, argument in opts:
    if option in ("-h", "--help"):
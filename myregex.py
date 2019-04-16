#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This cannot be called regex.py because  then things will try to import it

import sys
import re

regex = re.compile( sys.argv[0])

print(re.match(regex,sys.stdin.read()).group())

# print(sys.stdin.read())
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import re

regex = re.compile( sys.argv[0])

print(re.match(regex,sys.stdin.read()).group())

# print(sys.stdin.read())
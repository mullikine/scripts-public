#!/usr/bin/env python3.5
# -*- coding: utf-8 -*-

import csv
from StringIO import StringIO
import sys

data = sys.stdin.read()

table = list(csv.reader(data, delimiter='\t'))
print(tabulate(table))

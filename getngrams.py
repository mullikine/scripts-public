#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import nltk
from nltk import word_tokenize
from nltk.util import ngrams
from collections import Counter

import sys

data = sys.stdin.read()

token = nltk.word_tokenize(data)

import getopt

# echo "hi there whats up" | select-word-by-pos.py -j

n = 1

try:
    opts, args = getopt.getopt(sys.argv[1:], "n", ['n='])

    # except getopt.GetoptError, err:
    # python 3 use as

    for option, argument in opts:
        if option in ("-n", "--n"):
            n = int(argument)

except getopt.GetoptError as err:
    print(str(err))

ngrams = ngrams(token,n)

sys.stdout.write('\n'.join([str(s) for s in ngrams]))

#  print(Counter(ngrams))


#  bigrams = ngrams(token,n)
#  trigrams = ngrams(token,3)
#  fourgrams = ngrams(token,4)
#  fivegrams = ngrams(token,5)

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import spacy
nlp = spacy.load('en_core_web_sm')
doc = nlp(u'Hello, world. Here are two sentences.')
print([t.text for t in doc])

# nlp_de = spacy.load('de_core_news_sm')
# doc_de = nlp_de(u'Ich bin ein Berliner.')
# print([t.text for t in doc_de])

nlp = spacy.load('en_core_web_sm')
doc = nlp(u"Peach emoji is where it has always been. Peach is the superior "
          u"emoji. It's outranking eggplant 🍑 ")
print(doc[0].text)          # Peach
from IPython import embed; embed()

print(doc[1].text)          # emoji
print(doc[-1].text)         # 🍑
print(doc[17:19].text)      # outranking eggplant
from ptpython.repl import embed; embed(globals(), locals())

noun_chunks = list(doc.noun_chunks)
print(noun_chunks[0].text)  # Peach emoji

sentences = list(doc.sents)
assert len(sentences) == 3
print(sentences[1].text)    # 'Peach is the superior emoji.'
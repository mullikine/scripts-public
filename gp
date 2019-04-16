#!/usr/bin/env python
# -*- coding: utf-8 -*-

from googlesearch import search
import urllib
from bs4 import BeautifulSoup
import shanepy
from shanepy import *

# GoogleResult:
#     self.name # The title of the link
#     self.link # The external link
#     self.google_link # The google link
#     self.description # The description of the link
#     self.thumb # The link to a thumbnail of the website (NOT implemented yet)
#     self.cached # A link to the cached version of the page
#     self.page # What page this result was on (When searching more than one page)
#     self.index # What index on this page it was on
#     self.number_of_results # The total number of results the query returned

def google_scrape(url):
    thepage = urllib.urlopen(url)
    soup = BeautifulSoup(thepage, "html.parser")
    return soup.title.text

i = 1
N_MAX_RESULTS_PAGES = 1
query = sys.argv[1]
print(query)

for url in search(query, stop=N_MAX_RESULTS_PAGES):
    try:
        a = google_scrape(url)
    except:
        pass

    print str(i) + ". " + a
    print url
    print " "
    i += 1
    #  break
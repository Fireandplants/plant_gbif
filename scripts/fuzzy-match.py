#!/usr/bin/env python 

# Dylan W. Schwilk
# some code for partial string matching using levenshtein distances or ratios

import Levenshtein 
# help(Levenshtein.distance)
# help(Levenshtein.rato)

import pandas as pd
#t = pd.read_csv()


def match_fuzzy(s, l, threshold = 2):
    """Return boolean vector of length l indicating itemes in l matching s at a
     threshold levenshtein distance"""
    return(map(lambda x : Levenshtein.distance(s,x) <= threshold, l))

def index_fuzzy(s, l, threshold = 2):
    """Return indices of items in l matching s at a
     threshold levenshtein distance"""
    from itertools import izip as zip, count # izip for maximum efficiency
    return([i for i, j in zip(count(), l) if Levenshtein.distance(s,j) <= threshold])


# some examples

qnames = open('../query_names/taxa_for_big_phylo_gbif_query_03_12_2014.txt').read().split("\n")

b = match_fuzzy("Quercus albar", qnames, 3)
sum(b)

index_fuzzy("Quercus alba", qnames, 2)

# ok, craziness, match verythng against everything. Well, for first 1000 for
# now. Not useful, just a demo
bigl = map(lambda x : index_fuzzy(x, qnames[0:1000], 1), qnames[0:1000])
 [x for x in bigl if len(x) > 1]

# >>> qnames[429]
# 'Asplenium montanum'
# >>> qnames[473]
# 'Asplenium fontanum'
# >>> 




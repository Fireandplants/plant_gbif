#!/usr/bin/env python

"""Use fuzzy_match.py to match taxon names in gbif occurrence data set to
expanded tanknames list.

"""
# Dylan W. Schwilk 
import codecs, datetime
from synonymize import read_names
from fuzzy_match import fuzzy_match_name_list

import logging
logger = logging.getLogger('tu_logger')
logger.setLevel(logging.INFO)

tanknames = read_names(codecs.open("../query_names/tanknames-expanded.txt", "r", "utf-8"))
gbifnames = read_names(codecs.open("../query_names/gbif-occurrences-names_140905.txt", "r", "utf-8"))

# How to handle the fact that TPL has three part naems and gbif does not?  For now:
# tanknames = filter(lambda x: len(x.split()) == 2, tanknames)
# If I don't do the above, then the matching will use those three parters but
# ignore the var or subsp. part. But that implies synonymity that may not be
# true!

# outputs
gbif_lookup_file = "../query_names/gbif_tank_lookup_140906.csv"
#unmatched_file  = "../results/gbif_tank_lookup_unmatched.txt"
outf = codecs.open(gbif_lookup_file, "w", "utf-8")
#unmatchedf = codecs.open(unmatched_file, "w", "utf-8")

print(gbifnames[1:10])

print("START " + str(datetime.datetime.now()))
res = fuzzy_match_name_list(gbifnames, tanknames, outf)
print("DONE " + str(datetime.datetime.now()))
outf.close()
#unmatchedf.close()
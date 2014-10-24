#!/usr/bin/env python

## Version 2014-10-24 to only run fuzzy matching on the 5859 new names in the
## October GBIF data dump.

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
gbifnames = read_names(codecs.open("../query_names/gbif-occurrences-names_141023_newonly.txt", "r", "utf-8"))

# outputs
gbif_lookup_file = "../query_names/gbif_tank_lookup_141024_newonly.csv"
#unmatched_file  = "../results/gbif_tank_lookup_unmatched.txt"
outf = codecs.open(gbif_lookup_file, "w", "utf-8")
#unmatchedf = codecs.open(unmatched_file, "w", "utf-8")

print(gbifnames[1:10])

print("START " + str(datetime.datetime.now()))
res = fuzzy_match_name_list(gbifnames, tanknames, outf)
print("DONE " + str(datetime.datetime.now()))
outf.close()
#unmatchedf.close()

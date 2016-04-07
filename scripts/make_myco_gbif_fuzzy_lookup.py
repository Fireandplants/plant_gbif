#!/usr/bin/env python
# Dylan W. Schwilk

"""Use fuzzy_match.py to match taxon names in gbif occurrence data set to
expanded name list.

"""

import codecs, datetime
# from taxon-names-utils:
import sys
sys.path.insert(0, '../../taxon-name-utils/scripts') # to provide scripts in taxon-name-utils
from synonymize import read_names
from fuzzy_match import fuzzy_match_name_list

import logging
logger = logging.getLogger('tu_logger')
logger.setLevel(logging.INFO)

tanknames = read_names(codecs.open("../query_names/myco_species_expanded.txt", "r", "utf-8"))
gbifnames = read_names(codecs.open("../query_names/gbif-occurrences-names_151014.txt", "r", "utf-8"))
# outputs
gbif_lookup_file = "../query_names/gbif_myco_lookup_151015.csv"

outf = codecs.open(gbif_lookup_file, "w", "utf-8")
# print(gbifnames[1:10])
print("START " + str(datetime.datetime.now()))
res = fuzzy_match_name_list(gbifnames, tanknames, outf)
print("DONE " + str(datetime.datetime.now()))
outf.close()

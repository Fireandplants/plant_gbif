#!/usr/bin/env python3
# Dylan W. Schwilk

"""Use fuzzy_match.py to match taxon names in gbif occurrence data set to
expanded name list.

This version needs both lists to include the raw scientific name as well as a
parsed version. A tab separates the two versions on a line and the pipe
character separates fields within the parsed name (as returned by Cam Webb's
parsename gawk script)
"""

import codecs, datetime
# from taxon-names-utils:
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../taxon-name-utils/scripts'))
#sys.path.insert(0, '../../taxon-name-utils/scripts') # to provide scripts in taxon-name-utils
from synonymize import read_names
from fuzzy_match import fuzzy_match_name_list

import logging
logger = logging.getLogger('tu_logger')
logger.setLevel(logging.INFO)

myconames = read_names(codecs.open("../query_names/myco_species_expanded_both", "r", "utf-8"))
gbifnames = read_names(codecs.open("../query_names/gbif-occurrences-names_220823_both", "r", "utf-8"))
# outputs
gbif_lookup_file = "../query_names/myco_tank_lookup_120823.csv"

outf = codecs.open(gbif_lookup_file, "w", "utf-8")
# print(gbifnames[1:10])
print("START " + str(datetime.datetime.now()))
res = fuzzy_match_name_list(gbifnames, myconames, outf)
print("DONE " + str(datetime.datetime.now()))
outf.close()

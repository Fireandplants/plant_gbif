#!/usr/bin/env python

# script to cycle through entire huge gbif plantae data dump and check each
# name against the fuzzy match table (expanded tank et al names to gbif names
# lookup).

# Note that rather than using the "merge" action provided by the command line
# synonymize.py script (in taxon-name-utils), this script imports synonymize
# and uses some functions directly. This is in the interest of speed: it takes
# a long time to go through ~140 million gbif records, let's only do it once
# and get the canonical name while we are visiting each record.

import zipfile as zf
import codecs

# from taxon-names-utils:
import sys
sys.path.insert(0, '../../taxon-name-utils/scripts')
import synonymize

output_field_sep = ","

fuzzyMatchesFile = codecs.open("../query_names/gbif_tank_lookup_final.csv","r", "utf-8")
fieldsFile =       codecs.open("../query_names/gbif_fields.txt", "r", "utf-8")

CANONICAL_NAMES= codecs.open("../../bigphylo/species/big-phylo-leaves.txt", "r", "utf-8")
goodnames = synonymize.read_names(CANONICAL_NAMES)
goodnames = set(goodnames)

# Turn a space separated header line into a dictionary that looks up indices
def makeHeaderDict(s):
    gbif_header = s[:-1].split("\t") # gbif data is tab-delimited
    hdict = {}
    for i,h in enumerate(gbif_header) :
        hdict[h]=i
    return hdict

def cleanField(s):
    return s.replace('"', '\\"').replace('\n',' ')

# make tpl dicts
synonymize.make_tpl_dicts(codecs.open(synonymize.TPL_FILE, "r", "utf-8"))
# make canonical lookup in synonymize
synonymize.expand_names(goodnames) # necessary to make the canonial lookup

# create fuzzy matches lookup table
fnames = {}
fuzzyMatchesFile.readline()
for l in fuzzyMatchesFile:
    fields = l.split(",")
    fnames[ fields[0][1:-1] ] = fields[1][1:-1] # lookup accepted to searched

# get the list of fields we want
gfields = fieldsFile.readlines()
gfields = map(lambda x: x.strip(), gfields)
# print(gfields)
occurrences = zf.ZipFile('/mnt/gis/gbif_plantae/0000911-150306150734599.zip').open("occurrence.txt", "r")
output_file = codecs.open('../data/gbif-occurrences_extracted_150311.csv', 'w', "utf-8")
output_file.write("gbifname%sexpandedname%canonical_name%s" %
                  (output_field_sep, output_field_sep, output_field_sep))
for h in gfields[0:-1]:
            output_file.write(h + output_field_sep)
output_file.write(gfields[-1])
output_file.write("\n")

# get header
for l in occurrences:
    l = codecs.decode(l, "utf-8")
    hdict = makeHeaderDict(l)
    break  # just read first line

# print(hdict)
# exit(0)

n = 0
nmatches=0
for l in occurrences:
    l = codecs.decode(l, "utf-8")
    n = n + 1

    f = l[:-1].split("\t")
    # first check if lat and lon exist
    if not f[hdict["decimallatitude"]] or not f[hdict["decimallongitude"]]:
        continue

    name = f[hdict["species"]]
    res = fnames.get(name)
    if res:
        nmatches = nmatches+1
        resline = '"%s"%s"%s"%s' % (name, output_field_sep,  res, output_field_sep)

        # to update progress:
        if (nmatches % 5000 == 0):
            print(str(n) + "\t" + str(nmatches) + ": " + resline)

        tankname = synonymize.bad2good(res)
        if tankname:  # write data if synonym could be matched back to tankname
            # get all the needed fields
            resline = resline + tankname + output_field_sep
            # required if we use "," as sep:
            field_vals = map(lambda x: '"%s"' % cleanField(f[hdict[x]]), gfields)
            resline = resline + output_field_sep.join(field_vals)
            output_file.write(resline + "\n")

#    if n > 10000 : break  # uncomment to test on first 10k records

output_file.flush()
output_file.close()
print("Total records scanned = " + str(n))
print("Total matches found = " + str(nmatches))

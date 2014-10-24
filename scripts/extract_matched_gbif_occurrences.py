## Revision 2014-10-24 for new gbif data dump

## script to cycle through entire huge gbif plantae data dump and check each
## name against the fuzzy match table (expanded tank et al names to gbif names
## lookup).

## Note that rather than using the "merge" action provided by the command line
## synonymize.py script, this script imports synonymize and uses some functions
## directly. This is in the interest of speed: it takes a long time to go
## through 132 million gbif records, let's only do it once and get the
## canonical name while we are visiting each record.

import zipfile as zf
import synonymize
import codecs

fuzzyMatchesFile = codecs.open("../query_names/gbif_tank_lookup_final.csv","r", "utf-8")
fieldsFile =       codecs.open("../query_names/gbif_fields.txt", "r", "utf-8")

TANKNAMES= codecs.open("../../bigphylo/species/big-phylo-leaves.txt", "r", "utf-8")
goodnames = synonymize.read_names(TANKNAMES)
goodnames = set(goodnames)

# Turn a space separated header line into a dicitonary that looks up indices
def makeHeaderDict(s):
    gbif_header = s[:-1].split("\t")
    hdict = {}
    for i,h in enumerate(gbif_header) :
        hdict[h]=i
    return hdict


## make tpl dicts
synonymize.make_tpl_dicts(codecs.open(synonymize.TPL_FILE, "r", "utf-8"))
## make canonical lookup in synonymize
synonymize.expand_names(goodnames) # necessary to make the canonial lookup

## create fuzzy matches lookup table
fnames = {}
fuzzyMatchesFile.readline()
for l in fuzzyMatchesFile:
    fields = l.split(",")
    fnames[ fields[0][1:-1] ] = fields[1][1:-1] # lookup accepted to searched

## get the list of fields we want
gfields = fieldsFile.readlines()
gfields = map(lambda x: x.strip(), gfields)

occurences = zf.ZipFile('/mnt/gis/gbif_plantae/0000380-141021104744918.zip').open("occurrence.txt", "r")
output_file = codecs.open('../data/gbif-occurrences_extracted_141024.csv', 'w', "utf-8")
output_file.write("gbifname\texpandedname\ttankname\t")
for h in gfields:
            output_file.write(h + "\t")
output_file.write("\n")
 


# get header
for l in occurences:
    l = codecs.decode(l, "utf-8")
    hdict = makeHeaderDict(l)
    break # just read first line

n = 0
nmatches=0
for l in occurences:
    l = codecs.decode(l, "utf-8")
    n = n + 1 
    
    f = l[:-1].split("\t")
    # first check if lat and lon exist 
    if not f[hdict["decimalLatitude"]] or not f[hdict["decimalLongitude"]]:
        continue

    name = f[hdict["species"]] 
    res =  fnames.get(name)
    if res :
        nmatches = nmatches+1
        # print("found fm: " + name + ", " + res)
        resline = name + "\t" + res + "\t"
        
        # get all the needed fields
        if (nmatches % 5000 == 0) : print(str(n) + "\t" + str(nmatches) +": " + resline)
        tankname = synonymize.bad2good(res, goodnames)
        resline = resline + tankname + "\t"
        for h in gfields:
       #     print(h)
       #     print(hdict[h])
            resline = resline + f[hdict[h]] + "\t"
        output_file.write(resline + "\n")

    if n > 10000 : break

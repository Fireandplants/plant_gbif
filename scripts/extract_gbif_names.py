#!/usr/env python

## Dylan W. Schwilk

## Extracts "species" field (latin binomials) from a GBIF occurrence download zip file

import zipfile as zf
import codecs

GBIF_ZIP_FILE = '/mnt/gis/gbif_plantae/0000380-141021104744918.zip'
OUTPUT_FILE = '../query_names/gbif-occurrences-names_141023.txt'

def makeHeaderDict(s):
    gbif_header = s[:-1].split("\t")
    hdict = {}
    for i,h in enumerate(gbif_header) :
        hdict[h]=i
    return hdict

occurences = zf.ZipFile(GBIF_ZIP_FILE).open("occurrence.txt", "r")
output_file = codecs.open(OUTPUT_FILE, 'w', "utf-8")

# get header
for l in occurences:
    l = codecs.decode(l, "utf-8")
    hdict = makeHeaderDict(l)
    break # just read first line

## get index of "species" field
sp_index = hdict[u"species"]

res = set()
n = 0
nfound = 0
nnotfound = 0

for l in occurences:
    l = codecs.decode(l, "utf-8")
    n = n + 1 
  #  if(n > 10) : break
    f = l[:-1].split("\t")
  #  print(f[sp_index])
    res.add(f[sp_index] )
    if n%10000 == 0 : print(n)



for i in res:
    output_file.write(i + "\n")


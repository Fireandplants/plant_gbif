#!/usr/env python


import zipfile
#import codecs

gbif_fields = [
"species",
"scientificname",
"genus"
"id",
"dataset_id",
"basis_of_record",
"taxon_id",
"country_code",
"latitude",
"longitude",
"year",
"elevation_in_meters",
"verbatim_latitude",
"verbatim_longitude",
"coordinate_precision",
"continent_ocean",
"state_province",
"county",
"country",
"locality"
]

def getHeader(l):
    r = {}
    for i, n in enumerate(l):
        r[n] = i
    return(r)

def extract_species(s):
    p = s.split()
    try:
        varsp = p[2]
        if (varsp == "var." or  varsp == "subsp."):
            return(p[0] + " " + p[1] +  " " + p[3])
    except :
        pass
    return(p[0] + " " + p[1])


with zipfile.ZipFile("0008084-140429114108248.zip") as z:
    with z.open("occurrence.txt") as f:
        count = 0
        for line in f:
            count+=1
            l = line.split("\t")
            if count==1: 
                header = getHeader(l)
                hindices = sorted(header.values())
            else :
                # pull the parts we want:
            
                if count > 30: break
                #print(l[176] + "," + l[100] + "," + l[101] + "," + l[223])
                print(extract_species(l[176]))




for i,n in enumerate(header):
    print(str(i) + ": " + n)

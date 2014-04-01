#!/usr/bin/env python

# make_compact.py 

# quick script to pair down the TPL1.1_synonyms.csv file for
# slightly faster access from other code.

# import re

TPL_FILE = "./TPL1.1_synonyms.csv"
OUT_FILE = "./TPL1.1_synonyms_compact.csv"

def main():
#    p = re.compile("""("[0-9]+,)"([^"]+)","([^"]+)""")
    outf = open(OUT_FILE,"w")
    tpl = open(TPL_FILE)
    for line in tpl:
 #       s,a = p.match(line).group(2,3)
        line = line.replace("_"," ")
        n,s,a = line.split(",")
        outf.write(s[1:-1] + "," + a[1:-2] + "\n")
    outf.close()

if __name__== "__main__":
    main()

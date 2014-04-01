#!/usr/bin/env python

# Dylan Schwilk

# create synonym table from a list of canonical names and the current TPL
# lookup, expand a canonical list or merge list containing synonyms. This code
# makes some assumptions about the TPL1.1_synonyms_compact.csv list which are
# not true (see issue #6). 

#from collections import defaultdict

TPL_FILE = "../theplantlist1.1/TPL1.1_synonyms_compact.csv"
NAME_FILE = "../../bigphylo/species/big-phylo-leaves.txt"

def read_names(name_file = NAME_FILE):
    return([line.rstrip() for line in open(name_file)])

def tpl_dict(tpl=TPL_FILE):
    """This function assumes that every name (including accepted ones) is included
in the synonym column (first col). Change this if that assumption is false
after Beth's recreation of TPL1.1

    """
    tpl = map(lambda x : x[0:-1].split(","), open(TPL_FILE).readlines()[1:])
    #syn = defaultdict(set)
    syn = {}
    for s,a in tpl:
        syn[s] = a # should be one accepted per synonym
        # syn[s].add(s) # should not be necessary, see above
    return(syn)

# def reverse_dict(d):
#     r = {}
#     for key,s in d.iteritems():
#         for n in s.items():
#             r[s] =

def expand_names(canonical, d):
    r = set()
    for name in canonical:
        r.add(name)
        r.add(d.get(name, name))
    return(r)


def merge_names(badnames, d):
    """Merge list of names. Return a list of the same length as badnames, but with
synonyms replaced"""
    good = []
    for n in badnames:
        good.append(d.get(n,n))
    return(good)

    

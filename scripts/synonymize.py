#!/usr/bin/env python

"""create synonym table from a list of canonical names and the current TPL
lookup, expand a canonical list or merge list containing synonyms.

NEEDS testing still.
"""

__version__ =    '''0.1'''
__program__ =    '''synonymize.py'''
__author__  =    '''Dylan Schwilk'''
__usage__   =    '''synonymize.py [options] [names_file]'''

# default files if non given
TPL_FILE = "../theplantlist1.1/TPL1.1_synonymy_list"
NAMES_FILE = "../../bigphylo/species/big-phylo-leaves.txt"

import logging
logging.basicConfig(format='%(levelname)s: %(message)s')
tpl_logger = logging.getLogger('tpl_logger')

def read_names(src):
    return([line.rstrip() for line in src.readlines()])

def tpl_dict(tpl):
    """Create dictionary from the tpl ragged array.
    """
    syn = {}
    for line in open(TPL_FILE):
        names = line[:-1].replace("_"," ").split(",")  # replace underscores with spaces
        a =names[0]
        #syn[a] = a
        for s in names[1:]:
            syn[s] = a # should be one accepted per synonym
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
synonyms replaced. If synonym not found, use actual name in badnames."""
    good = []
    for n in badnames:
        good.append(d.get(n,n))
    return(good)

    
def main():
    '''Command line program.  '''
    import sys   
    from optparse import OptionParser

    parser = OptionParser(usage=__usage__, version ="%prog " + __version__)
    parser.add_option("-a", "--action", action="store", type="string", \
                      dest="action",  default = 'expand', help="Action to perform, 'expand' or 'merge'")
    # parser.add_option("-o", "--outfile", action="store", type="string", dest="TPL_FILE", 
    #                   default="", help="file name for output=%default")
    parser.add_option("-f", "--tplfile", action="store", type="string", dest="TPL_FILE", 
                      default=TPL_FILE, help="Set path to TPL ragged array, default=%default")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False,
                      help="Print INFO messages to stdout, default=%default")    

    (options, args) = parser.parse_args()

    if options.verbose:
        tpl_logger.setLevel(logging.INFO)
    
    if len(args) == 2 :
        try :
            names = read_names(open(args[1]))
        except IOError:
            tpl_logger.error('Error reading file, %s' % args[0])
            sys.exit()
    elif len(args) == 1:
        names = read_names(sys.stdin)


    # make the lookup
    syndict = tpl_dict(options.TPL_FILE)

    # expand or merge
    if options.action=="expand" :
        r = expand_names(names, syndict)
    elif options.action=="merge":
        r = merge_names(names, syndict)
    else :
        tpl_logger.error('Invalid action, %s' % options.action)
        sys.exit()


    for l in r:
        print(l)

    return(0)

if __name__== "__main__":
    main()

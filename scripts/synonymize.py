#!/usr/bin/env python

"""create synonym table from a list of canonical names and the current TPL
lookup, expand a canonical list or merge list containing synonyms.

NEEDS testing still.

This looks good Beth.  I have explored this some.  One thing that I discovered: the original problem I noted when opening this issue still holds, but it is simply characteristic of TPL.  The statement "there is ONE accepted name for each unique name", is only true when one includes authors. In fact, ignoring authorship, there are some synonyms that match to multiple accepteds (eg "Amaryllis dubia").  No way around it, but it does mean that expanding a canonical list is not completely reversible, one cannot merge back to the same set of names exactly.  Well, I'm working on a solution one, but it is a more complicated problem than searching through lists of 'sister' synonyms.  It is not the end of the world in any case

"""

__version__ =    '''0.1'''
__program__ =    '''synonymize.py'''
__author__  =    '''Dylan Schwilk'''
__usage__   =    '''synonymize.py [options] [names_file]'''

import logging
logging.basicConfig(format='%(levelname)s: %(message)s')
tpl_logger = logging.getLogger('tpl_logger')

# The PLant List synonymy table:
TPL_FILE = "../theplantlist1.1/TPL1.1_synonymy_list"
# default canonical names file if none given
CANONICAL_NAMES_FILE = "../../bigphylo/species/big-phylo-leaves.txt"

# global dicts
syn2accepted = {}
accepted2syn = {}

def read_names(src):
    return([line.rstrip() for line in src])

def make_tpl_dicts(tpl):
    """Create dictionary from the tpl ragged array

    """
    
    for line in tpl:
        names = line[:-1].replace("_"," ").split(",")  # replace underscores with spaces
        syns = set(names)
        a = names[0]
        accepted2syn[a] = syns
        for n in syns :
            syn2accepted[n] = a

            
def expand_names(names):
    r = set()
    for name in names:
        r.add(name) # add itself
        if syn2accepted.has_key(name): # is it even in TPL?
            syns = accepted2syn[syn2accepted[name]] # if so, get all sister synonyms
            for n in syns:
                r.add(n)
    return(r)


def merge_names(badnames, goodnames):
    """Merge list of names using list or set "goodnames" as canonical names.
    Modifies badnames, but with synonyms replaced. If synonym not found, use
    actual name in badnames.

    """
    g = set(goodnames)
    for i,n in enumerate(badnames):
        if not n in g :  # name is not already canonical
            # 2 possibilities: it is an accepted name or a synonym
            a = syn2accepted[n]
            if a in g : # accepted is canonical
                badnames[i] = a
            else : # last try accepted is a sister synonym
                syns = accepted2syn[a] # get syns of a
                snames = syns.intersection(g)
                if len(snames) > 0 :  # might was well take first one, no way to choose:
                    badnames[i] = snames.pop()
                # if this doesn't work, stick with original
                else :
                    print("Not found: " + n)
    return

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
    syndict, accepteddict = tpl_dict(open(options.TPL_FILE))

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

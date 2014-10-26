 #!/usr/bin/env bash

TANKNAMES="../../bigphylo/species/big-phylo-leaves.txt"
EXPANDED_NAMES="../query_names/tanknames-expanded.txt"

# -b option forces binomial names
python synonymize.py -b -a expand $TANKNAMES > $EXPANDED_NAMES

# to merge the result, in $EXPANDED NAMES
# python synonymize.py -a merge -c $TANKNAMES $EXPANDED_NAMES > ../query_names/merged_names.txt

# proof this is reversible :
diff -s <(sort $TANKNAMES) <(python synonymize.py -b -a merge -c $TANKNAMES $EXPANDED_NAMES | sort | uniq)

## output: Files /dev/fd/63 and /dev/fd/62 are identical


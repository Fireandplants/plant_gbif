 #!/usr/bin/env bash

CANONICAL_NAMES="../query_names/myco_species.txt"
EXPANDED_NAMES="../query_names/myco_species_expanded.txt"
SYNONYMIZE="../../taxon-name-utils/scripts/synonymize.py"

# -b option forces binomial names
python $SYNONYMIZE -b -a expand $CANONICAL_NAMES > $EXPANDED_NAMES

# to merge the result, in $EXPANDED NAMES
# python synonymize.py -a merge -c $CANONICAL_NAMES $EXPANDED_NAMES > ../query_names/merged_names.txt
echo "Finished expansion, testing . . ."

# proof this is reversible :
diff -s <(sort $CANONICAL_NAMES) <(python $SYNONYMIZE -b -a merge -c $CANONICAL_NAMES $EXPANDED_NAMES | sort | uniq)

## output: Files /dev/fd/63 and /dev/fd/62 are identical

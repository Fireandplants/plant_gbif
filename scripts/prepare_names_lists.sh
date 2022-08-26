 #!/usr/bin/env bash

CANONICAL_NAMES="../query_names/myco_species"
EXPANDED_NAMES="../query_names/myco_species_expanded"
GBIF_NAMES="../query_names/gbif-occurrences-names_220823"

# shorter test lists
# CANONICAL_NAMES="../query_names/testlist"
# EXPANDED_NAMES="../query_names/testexpanded.txt"


SYNONYMIZE="../../taxon-name-utils/scripts/synonymize.py"
PARSENAMES="./parsenames" # awk script adapted form one of same name in Cam Webb's taxon-tools

# 1. Expand canonical names to all synonyms
python3 $SYNONYMIZE -a expand $CANONICAL_NAMES > $EXPANDED_NAMES
echo "Finished expansion, testing . . ."

# to merge the result, in $EXPANDED NAMES
#python3 $SYNONYMIZE -a merge -c $CANONICAL_NAMES $EXPANDED_NAMES > ../query_names/merged_names.txt

# proof this is reversible :
#diff -s <(sort $CANONICAL_NAMES | uniq) <(python3 $SYNONYMIZE -a merge -c $CANONICAL_NAMES $EXPANDED_NAMES | sort | uniq)

## output: Files /dev/fd/63 and /dev/fd/62 are identical

# 2. Produce parsed versions of all scientific names
echo "parsing original and expanded names lists"
$PARSENAMES  $CANONICAL_NAMES > ${CANONICAL_NAMES}_parsed 
$PARSENAMES $EXPANDED_NAMES > ${EXPANDED_NAMES}_parsed
$PARSENAMES $GBIF_NAMES > ${GBIF_NAMES}_parsed

# 3. align parsed versions with original names in files named with "_both"
paste $CANONICAL_NAMES ${CANONICAL_NAMES}_parsed > ${CANONICAL_NAMES}_both
paste $EXPANDED_NAMES ${EXPANDED_NAMES}_parsed > ${EXPANDED_NAMES}_both
paste $GBIF_NAMES ${GBIF_NAMES}_parsed > ${GBIF_NAMES}_both

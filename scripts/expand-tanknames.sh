 #!/usr/bin/env bash

TANKNAMES="../../bigphylo/species/big-phylo-leaves.txt"
EXPANDED_NAMES="../query_names/taxa_for_bigphylo_gbif_query_04_08_14.txt"

python synonymize.py -a expand $TANKNAMES >> ../query_names/taxa_for_bigphylo_gbif_query_04_08_14.txt

# to merge the result, in $EXPANDED NAMES
#python synonymize.py -a merge -c $TANKNAMES $EXPANDED_NAMES >> ../query_names/merged_names.txt

plant_gbif
==========

This repository is for data and scripts for matching the names in the Tanke et al phylogeny with occurrence records in the Global Biodiversity Information Facility (GBIF) dataset. 


Analysis steps / walkthrough
---------------------------

Generic code for steps 1-2 are in the taxon-name-utils repository

### 1. Create expanded list of canonical names ###

Our canonical names for phylogenetic analyses are the tip names in the [Tank et al tree][TankTree].  We would like to search for occurrences of these species accounting for synonyms, so we use synonymize.py to expand the names list to all canonical names plus all synonyms.  We use the data scraped from [The Plant List][TPL]by [Beth Forrestel][ejforrestel] around 3/30/2014 to conduct this expansion. 


``` bash
expand_tanknames.sh
```

This will create a names list, `../query_names/tanknames-expanded.txt`.  It reads the canonical names from `../../bigphylo/species/big-phylo-leaves.txt`

### 2. Conduct fuzzy name matching

This step creates a lookup table that associates every possible taxon binomial in the full GBIF Plantae occurrence database with its match in the expanded canonical names list.  The code uses `fuzzy_match.py` from the taxon-name-utils repository to do matching based on a combination of Levenshtein distances and Jaro-Winkler distances.

First, we must extract all possible taxon binomials from the full GBIF Plantae data. Schwilk downloaded the the full GBIF Plantae data on 2014-07-XX.  This is approximately 132 million occurrence records.  This data, stored as a compressed zip file is not in the git repository, but is referred to by the  `extract_gbif_names.py` script.

```
python extract_gbif_names.py
```

This will create the names list `../query_names/gbif-taxon_names_140905.csv`. [TODO: correct script to point to correct directory].  This is all unique names in the GBIF Plantae occurrences data.

Now we can create a lookup table that maps each name in this list to the expanded canonical names list, ommitting any name that does not have a sufficently close match according to the settings in `fuzzy_match.py`


``` bash
python gbif_lookup.py
```

The resulting table is `../query_names/gbif-occurrence-names_140905.txt`. This table requires a bit of cleaning in R to throw out a few false-positive matches.  Use `gbif_clean?.R` [TODO: check name]. The final lookup table is `gbif-occurrence-names-final.txt`

### 3. Extract matching records from the GBIF Plantae data ###

This step reads line by line through the 132 million GBIF occurrence records and extracts those for which the species name match a name in `gbif-occurrence-names-final.txt`  [TODO: check this!]

```
python extract_matched_gbif_occurrences.py

```

[ejforrestel]: https://github.com/ejforrestel
[GBIF]: http://www.gbif.org/
[TPL]: http://www.theplantlist.org/
[TPL-accepted]: http://www.theplantlist.org/1.1/about/#accepted
[TankTree]: http://datadryad.org/resource/doi:10.5061/dryad.63q27/3
[Zanne-etal-2013]: http://www.nature.com/nature/journal/v506/n7486/full/nature12872.html


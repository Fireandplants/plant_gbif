plant_gbif
==========

This repository is for data and scripts for matching the names in the [Tank et al phylogeny][TankTree] with occurrence records in the Global Biodiversity Information Facility (GBIF) dataset. 

Note that all of these scripts read text files as utf-8 and immediately treat as unicode internally. All matching and comparisons work on unicode. All written output is encoded as utf-8. This has a slight speed penalty but is worth it!  All strings are correctly decoded and encoded.

Analysis steps / walkthrough
----------------------------

Generic code for steps 1-2 are in the [taxon-name-utils repository](https://github.com/schwilklab/taxon-name-utils). There are some slight modifications to that code (especially to `synonymize.py` ) in this repository.

### 1. Create expanded list of canonical names ###

Our canonical names for phylogenetic analyses are the tip names in the [Tank et al tree][TankTree]. We would like to search for occurrences of these species accounting for synonyms, so we use synonymize.py to expand the names list to all canonical names plus all synonyms. We use the data scraped from [The Plant List][TPL]by [Beth Forrestel][ejforrestel] around 3/30/2014 to conduct this expansion. This expansion can result in three part names (eg var. part after specific epithet), but all subsequent matching is on binomial part only.


```
expand_tanknames.sh
```

This will create a names list, `../query_names/tanknames-expanded.txt`.  It reads the canonical names from `../../bigphylo/species/big-phylo-leaves.txt`

### 2. Conduct fuzzy name matching

This step creates a lookup table that associates every possible taxon binomial in the full GBIF Plantae occurrence database with its match in the expanded canonical names list.  The code uses `fuzzy_match.py` from the taxon-name-utils repository to do matching based on a combination of Levenshtein distances and Jaro-Winkler distances.

First, we must extract all possible taxon binomials from the full GBIF Plantae data. Schwilk downloaded the the full GBIF Plantae data on 2014-07-XX.  This is approximately 132 million occurrence records.  This data, stored as a compressed zip file is not in the git repository, but is referred to by the  `extract_gbif_names.py` script.

```
python extract_gbif_names.py
```

This will create the names list. Current version is `../query_names/gbif-occurrences-names_140905.txt`. This is all unique binomial names in the GBIF Plantae occurrences data.

Now we can create a lookup table that maps each name in this list to the expanded canonical names list, omitting any name that does not have a sufficiently close match according to the settings in `fuzzy_match.py`

```
python make_tank_gbif_fuzzy_lookup.py
```

The resulting table is `../query_names/gbif_tank_lookup_140906.csv`. Raw, this results in 59139 matched names from the expanded canonical list. This table requires a bit of cleaning in R to throw out a few false-positive matches.  Use `scripts/clean_gbif2tankname.R`. The lookup table saved by that R script is `gbif_tank_lookup_140906_cleaned.csv`.  After manually marking additional removals (false matches), the resulting file was saved as `gbif_tank_lookup_140906_cleaned_manual.csv`.  The R script above then reads in this modified version and throws away the rows marked as false positives and saves the result as  `gbif-tank_lookup_final.csv`.

### 3. Extract matching records from the GBIF Plantae data ###

Schwilk downloaded the full GBIF Plantae data on 2014-07-02. This is around 132 million records. 

This step reads line by line through the 132 million GBIF occurrence records and extracts those for which 1) there is a latitude and longitude, and 2) for which the species name matches a name in `gbif_tank_lookup_final.csv`. 


```
python extract_matched_gbif_occurrences.py

```

The result is saved as a large tab-separated file, current version is `gbif-occurrences_extracted_140906.csv`.

This file should go to Dan for further cleaning (removing species for which there are not at least 50 records, etc).

[ejforrestel]: https://github.com/ejforrestel
>>>>>>> Stashed changes
[GBIF]: http://www.gbif.org/
[TPL]: http://www.theplantlist.org/
[TPL-accepted]: http://www.theplantlist.org/1.1/about/#accepted
[TankTree]: http://datadryad.org/resource/doi:10.5061/dryad.63q27/3
[Zanne-etal-2013]: http://www.nature.com/nature/journal/v506/n7486/full/nature12872.html


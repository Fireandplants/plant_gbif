plant_gbif
=================

This repository is for data and scripts for matching taxon names to GBIF occurrence data. The master branch represents the current project investigating abandonment of the arbuscular mycorrhizal mutualisms across angiosperms. It currently mirrors the myco-evol-project branch. The plant_gbif repo contains branches for other related projects with similar workflows.

Note: one thing I (Schwilk) have not cleaned up is that all of Schwilk's scripts (python or R) assume that the "scripts" directory is the working directory. McGlinn's scripts assume that "." is the working directory.

Current release: [![DOI](https://zenodo.org/badge/17485158.svg)](https://zenodo.org/doi/10.5281/zenodo.11282177)

Matching GBIF occurrence records
--------------------------------

Matching the taxon names with plant occurrence records in the [Global Biodiversity Information Facility (GBIF) dataset][GBIF]. 

These scripts read text files as utf-8 and immediately treat as unicode internally. All matching and comparisons work on unicode internally. All written output is encoded as utf-8. This has a slight speed penalty but is worth it and necessary as there are unicode characters in the GBIF data and some in other taxon name sources.

A note on scientific names: The input data sources only inlcude latin binomials as the species names. These are not full scientific names weith authors nor do any taxa in the two original data sources (Tank et al tree and mycorrizal state state information data) include an infraspecific epithets. When we do name epxansion to synonyms and match against gbif data, we do include infraspecific epithets. We ignore authors when matching to species ebcause that information is missing.

### Analysis steps / walkthrough ###

Much code for steps 1-2 are in the [taxon-name-utils repository](https://github.com/schwilklab/taxon-name-utils). That repository aims to create a set of general and useful name matching and synonym finding tools. The code in this repo assumes that both repos are cloned in the same parent directory --- these scripts modify the python module search path to include the taxon-name-utils/scripts directory.


#### 1. Extract all possible name binomials in the full GBIF occurrence data ####

First, we must extract all possible taxon binomials from the full GBIF Plantae data. Schwilk downloaded the the full GBIF Plantae data on August 23, 2022 (https://doi.org/10.15468/dl.s4fvvn). This is 323,717,877 occurrence records. This data, stored as a compressed zip file is not in the git repository, but is referred to by the `extract_gbif_names.py` script. To rerun these analysis, the user must supply this file and modify the file location in the `extract_gbif_names.py` script. Other large data such as these are stored in the `/data/` directory of the repo which is ignored by git (see `.gitignore`).


```
python extract_gbif_names.py
```

This will create the names list. The current version is `../query_names/gbif-occurrences-names_151014.csv`. This is all unique scientific names in the GBIF Plantae occurrences data.


#### 2. Prepare taxon name lists ####

Run
```
prepare_names_lists.sh
```


What it does: There are 5284 plant taxa with mycorrizal state information from Maherali 2016: `../query_names/myco_species` . We expand this out to those names plus all synonyms using `taxon-names-tools/synonymize.py`. We use [World Flora Online][WFO] v.2022.07	Jul. 12, 2022. (see https://github.com/schwilklab/taxon-name-utils).

This will create a names list, `../query_names/myco_species_expanded`. This expanded names list includes each name in the original list and all synonyms according to [The World Flora Online backbone data][WFO]

Then the script produces parsed versions of all names using a modified version of Cam Webb's parsenames gawk script from the [taxon-tools package][Taxon-Tools]. Finally, the script lines up the original name as a single string alongside the parsed version for all three names files. The main useful result are two of these:  `../query_names/myco_species_expanded_both` and  `../query_names/gbif-occurrences-names_220823_both`


#### 3. Conduct fuzzy name matching ####

This step creates a lookup table that associates every possible taxon binomial in the full GBIF Plantae occurrence database with its match in the expanded canonical names list created in step 1. The code uses `fuzzy_match.py` from the taxon-name-utils repository to do matching based on a combination of Levenshtein distances and Jaro-Winkler distances. The matching algorithm is

```
python make_myco_gbif_fuzzy_lookup.py
```

For every "expanded name" (canonical names and synonyms), go through all names in GBIF data and first match genus and then specific epithet. If there is no exact match, find the closest genus match that is within a Levenshtein distance of 2 and, within that genus, find the closest specific epithet within a Levenshtein distance of 3. "Closest" is defined by Jaro-Winkler similarity. The resulting table is `../query_names/gbif_myco_lookup_220823.csv`. The threshold distances hard-coded in the script above over-match by design. Therefore, this table requires a bit of cleaning in R to throw out a few false-positive matches followed by a manual check. 

This will overmatch so we now drop any suspect matches according to the following algorithm: 1) Any fuzzy match for which both names are listed in The World FLora Online database. 2) We conduct some tests to mark likely good matches asthose whose specific epithet invovles only a latin gender change, common typing mistakes and alternative spellings (caespitosa vs cespitosa, sylvestris, sylvestris). All fuzzy matches are then checked manually to avoid incorrect matches (match that involves a known change of meaning (eg "micro" vs macro" or Latin diminutives). Some of this could be automated as most false positives and likely good amtches follow a few common typing transpostions and spelling variations. But a manual cehck is safest.
3) The remaining suspect matches are hand checked and most marked for removal. The automatic parts of the steps above (steps 1 and 2) are executed by `clean_gbif2canonical.R`. This produces the file for manual editing `gbif_myco_lookup_220826_cleaned.csv`

Conduct the manual fixes by adding "TRUE" to the manual_remove column to remove incorrect matches. ON 2022-08-26, Schwilk removed 141 incorrect matches, leaving 844-141 = 703 fuzzy matches most of which appear to be spelling alternatives or data entry errors. Overall, that leaves 24991 names extracted from gbif that can be matched to the expanded canonical names (canonical plus synonyms). We need to convert matched names (we ignored author portion of name) back to the full names so we can match precisely with the gbif `scientificName` field. To do that run

`finish_gbif2canonical.R` 

to finalize the manual marks and to create a lookup table that includes the full strings for the canonical names as well as the full gbif `scientificName` field (with author) needed in the next step. The final lookup table has 24991 unique canonical+synonym names matched to 29472 gbif full `scientificName` field names. The larger number of gbif scientificNames is beacause we match on full scientific names but omit authors because of many minor variations in how authors are specified in gbif data from heterogenous sources. The created file is `gbif_myco_lookup_220826_final.csv`

#### 4. Extract matching records from the GBIF Plantae data ####

This step reads line by line through all GBIF occurrence records and extracts those for which 1) there is a latitude and longitude, and 2) for which the scientificName field matches a name in `gbif_myco_lookup_220826_final.csv`

```
python3 extract_matched_gbif_occurrences.py

```

```
Total records scanned = 323717877
Total matches found   = 189072622
```

The result is saved as a large tab-separated file, current version is `data/myco-gbif-occurrences_extracted_.csv`. This is our full species occurrence data, but it WILL have records with untrustworthy coordinates, it will include observations from horticultural plants (eg NY City Parks!) and therefore needs further cleaning. This file uncompressed is 46 GB and its MD5sum is bc5a6584d47670f45c2e927db4a960d4. I then compressed that file using xz compression to about 3 GB to send to Dan McGlinn.

Data cleaning and GIS queries 
------------------------------

The next steps of the data processing removed possibly erroneous data, queried 
various GIS databases for environmental variables, and lastly summarized 
the spatial and environmental conditions at the species level. 

The script to run this entire process is `./scripts/geog_filter/run_all.R`

GBIF records were removed from the dataset using `./scripts/geog_filter/geog_filter.R`
if they were found to have any of the following attributes: 
- a duplicated record
- non-numeric coordinates 
- coordinates without reasonable range 
- coordinates that equal to exactly 0
- were located within 0.01 decimal degree of Cophenhagen, Denmark (GBIF headquaters)
- latitude was equal longitude 
- the coordinates where low resolution (i.e., did not record to the hundredth
   place in decimal degrees)
- located within 0.01 decimal degree of a country's centroid
- coordinate of the record must match the country or continent that was recorded
   for the record. This effectively removed any points falling in the ocean
   as well. 

The script `./scripts/geog_filter/climate_query.R` carried out the following
environmental queries using GIS databases. 

The WorldClim database was queried for mean annual temperature and annual
precipitation data (Hijmans et al. 2005).

The International Soil Reference and Information Centre (ISRIC)
world soil information database was used for total soil Nitrogen (N) (Batjes 2012). 

The Global Gridded Soil Phosphorus Distribution Maps database from the Oak Ridge
Oak Ridge National Laboratory Distributed Active Archive Center for labile inorganic
phosphorus (P) content (Yang et al. 2014).

Lastly, the script `./scripts/geog_filter/climate_summary.R` was used to compute
the median and 95% quantile of all the enviornmental and spatial variables at the
species level. 

References
----------
Hijmans, R.J., Cameron, S.E., Parra, J.L., Jones, P.G. and Jarvis, A., 2005.
Very high resolution interpolated climate surfaces for global land areas.
International journal of climatology, 25(15), pp.1965-1978.

Batjes, N.H., 2012. ISRIC-WISE Derived Soil Properties on a 5 by 5 Arc-minutes
Global Grid (Version 1.2). ISRIC–World Soil Information, Wageningen, The
Netherlands.

Yang, X., W.M. Post, P.E. Thornton, and A. Jain. 2014. Global Gridded Soil
Phosphorus Distribution Maps at 0.5-degree Resolution. Data set. Available
on-line [http://daac.ornl.gov] from Oak Ridge National Laboratory Distributed
Active Archive Center, Oak Ridge, Tennessee, USA.
http://dx.doi.org/10.3334/ORNLDAAC/1223


[GBIF]: http://www.gbif.org/
[WFO]: http://www.worldfloraonline.org/
[Taxon-Tools]: https://github.com/camwebb/taxon-tools


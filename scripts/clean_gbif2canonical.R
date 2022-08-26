#!/usr/env Rscript

## Dylan Schwilk

## clean the results for running the make_canonical_gbif_fuzzy_lookup.py fuzzy
## matching script. That script intentially overmatches. The solution is to
## identify "suspects" according to Jaro Winkler similarities, WFO, and
## presenece/absence of gender switches. Keep clear gender switches and cull
## all suspect matches in which both names are in the WOrld Flora ONline data
## because those are likely false positives. Some additional manual checking is
## still necessary to catch some spelling changes that result in rather low JW
## similarities (eg "silvestris" vs "sylvestris"). And to catch overmatched
## examples like mega vs micro and latin diminutives.

library(stringr)
library(data.table)
library(dplyr)
library(readr)

is_same_with_replace <- function(a,b,orig,replace) {
  return(str_replace(a,coll(orig),replace) == str_replace(b,coll(orig),replace))
}

iswr <- is_same_with_replace

# match if it is one of these spelling altenraives. We also don;t care if
# infraspecific rank was var vs form.
is_spelling_alternative <- function(a,b) {
  return( iswr(a,b, "cespitos","caespitos") | iswr(a,b, "sylvestris", "silvestris") |
            iswr(a,b, " f. ", " var. ") | iswr(a,b,"sylvatic","silvatic"))
}
                                        

wfo <- fread("../../taxon-name-utils/data/WorldFlora/classification.txt", quote="")
wfo <- filter(wfo, taxonRank %in% c("SPECIES", "VARIETY", "SUBSPECIES"))
wfo <- wfo$scientificName


gbif2can <-  read_csv("../query_names/gbif_myco_lookup_220823.csv")
names(gbif2can) <- c("gbif","canonical", "genus_jw", "se_jw", "gswitch")
nrow(gbif2can)
#30797. But that is with some same full names but different authors. We are not
# going to worry about slight changes in author abbreviations etc remove
# duplicates
gbif2can <- unique(gbif2can)
nrow(gbif2can)

fmatches <- subset(gbif2can, canonical!=gbif)
length(fmatches$gbif)
# 1878 fuzzy matches oput of 26166 matches
gbif2can <- gbif2can %>% mutate(fuzzy = gbif != canonical)


## allgbif <- read.csv("../query_names/gbif-occurrences-names_220823_both", sep="\t",
##                     header=FALSE, stringsAsFactors=FALSE)$V1

# matched <- allgbif[! allgbif %in% gbif2tank$gbif] 
# ngth(unmatched)
# ngth(gbif2tank$gbif)


# names that are both listed WFO names, mark them as such for removal
gbif2can <- gbif2can %>% mutate(bothwfo= (gbif %in% wfo & canonical %in% wfo))

# mark low similarity as suspect.
gbif2can$suspect <- gbif2can$genus_jw < 1.0 |  gbif2can$se_jw < 1.0

# mark certain spelling alternatives/typos as not suspect

gbif2can <- mutate(gbif2can, spelling_alternative=is_spelling_alternative(gbif,canonical),
                   suspect = suspect & !(spelling_alternative | gswitch))


# rule for removal:
# drop all fuzzy matches where both are in world flora list
gbif2can$remove <- gbif2can$bothwfo & gbif2can$fuzzy
remove <- subset(gbif2can, remove)
length(remove$gbif)
# [1] 1034 removed because both names are in WFO

keep <- filter(gbif2can, !remove)
keep <- keep[with(keep,order(se_jw)),]
count(subset(keep, fuzzy))

# 844 fuzzy matches to check. But ones not marked suspect are almost certainly
# good matches.

head(keep[with(keep, order(se_jw)),], 100)


## Current table overmatches, so apply some rules for removal. Remove in
## following cases:

# now manually check other suspects, so write to file.
write_delim(keep, "../query_names/gbif_myco_lookup_220826_cleaned.csv", delim="\t")

## Manual step: Remove any match that meets any of the following conditions.
## Add TRUE to the 'manual_remove ' column

##  Any case were difference is definite alternative latin: eg "micro" for
## "macro" should not match, so remove despite only one char diff. Again, these
## should be automated but are not. Typical cases: "micro"/"macro",
## "florus"/"folius" and latin diminutives.


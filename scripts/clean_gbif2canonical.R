#!/usr/env Rscript

## Dylan Schwilk

## clean the results for running the myco2tankname fuzzy matching script. That
## script intentially overmatches. The solution is to identify "suspects"
## according to Jaro Winkler similarities. Keep clear gender switches and cull
## all suspect matches in which both names are a TPL name as those are probably
## false positives. Some additional manual checking is still necessary to catch
## some spelling hcanges that result in rather low JW similarities (eg
## "silvestris" vs "sylvestris").

library(stringr)
library(dplyr)

gbif2tank <-  read.csv("../query_names/gbif_tank_lookup_170420.csv", stringsAsFactors=FALSE)
names(gbif2tank) <- c("gbif","tank", "genus_jw", "se_jw", "gswitch")
fmatches <- subset(gbif2tank, tank!=gbif)
length(fmatches$gbif)

allgbif <- read.csv("../query_names/gbif-occurrences-names_170420.txt",
                    header=FALSE, stringsAsFactors=FALSE)$V1

unmatched <- allgbif[! allgbif %in% gbif2tank$gbif]
length(unmatched)
length(gbif2tank$gbif)

tpl <- scan("../../taxon-name-utils/data/theplantlist1.1/tpl_accepted_and_syn", "character", sep="\n")

# names that are both TPL names, mark them as suspect
gbif2tank$bothtpl <- gbif2tank$gbif != gbif2tank$tank &
    (gbif2tank$gbif %in% tpl & gbif2tank$tank %in% tpl) 

# other suspects
gbif2tank$suspect <- gbif2tank$genus_jw < 0.96 |  gbif2tank$se_jw < 0.96

# rule for removal:
gbif2tank$remove <- gbif2tank$bothtpl & gbif2tank$suspect & 
        ( gbif2tank$gswitch != "True" )

remove <- subset(gbif2tank, remove)
length(remove$gbif)

keep <- subset(gbif2tank, !remove)
keep <- keep[with(keep,order(se_jw)),]
length(subset(keep, se_jw < 0.96)$gbif)

head(keep[with(keep, order(se_jw)),], 100)


## Current table overmatches, so apply some rules for removal. Remove in
## following cases:

## Any genus mismatch when both species are in TPL
keep <- keep %>% filter(!(genus_jw < 1 & bothtpl))

# now manually check other suspects, so write to file.

## fist step, merge with previous manual cehcking:

## I did this on 2017-04-20 to aid in manual checking:
## oldkeep <- read.csv("../query_names/gbif_tank_lookup_141024_cleaned_manual.csv",
##                     stringsAsFactors=FALSE)
## keep <- left_join(keep, select(oldkeep, gbif, tank, manual.remove))

write.csv(keep, "../query_names/gbif_tank_lookup_170420_cleaned.csv", row.names=FALSE)

## The current lookup WILL contain overmatches, so now do some more removal
## manually:


## Remove any match that meets any of the following conditions:


## 1. Any case were difference is definite alternative latin: eg "micro" for
## "macro" should not match, so remove despite only one char diff. Again, these
## should be automated but are not. Typical cases: "micro"/"macro",
## "florus"/"folius"
## 2. Both names are in TPL and the specific epithet differences is anything
## but a clear minor mispelling. Eg sylvestris vs silvestris, some "ae" for "i"
## changes. These could be automated but are not yet.

checked_names <- read.csv("../query_names/gbif_tank_lookup_170420_cleaned_manual.csv",
                          stringsAsFactors=FALSE)

checked_names$manual.remove[is.na(checked_names$manual.remove)] <- FALSE
final.lookup <- subset(checked_names, ! (remove | manual.remove))

write.csv(final.lookup, "../query_names/gbif_tank_lookup_final_170420.csv",
           row.names=FALSE)

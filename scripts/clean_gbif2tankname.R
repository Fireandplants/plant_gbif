#!/usr/env Rscript

library(stringr)

## Dylan Schwilk

## clean the results for running the gbif2tankname fuzzy matching script. That
## script intentially overmatches. Easiest solution: identify "suspects"
## according to JW similarities. Keep clear gender switches, cull all suspect
## matches in which both names are a TPL name as those are probably false
## positives.

gbif2tank <-  read.csv("../query_names/gbif_tank_lookup_140906.csv", stringsAsFactors=FALSE)
names(gbif2tank) <- c("gbif","tank", "genus_jw", "se_jw", "gswitch")
fmatches <- subset(gbif2tank, tank!=gbif)
length(fmatches$gbif)


allgbif <- read.csv("../query_names/gbif-occurrences-names_140905.txt", header=FALSE, stringsAsFactors=FALSE)$V1
unmatched <- allgbif[! allgbif %in% gbif2tank$gbif]
length(unmatched)
length(gbif2tank$gbif)

## hyphens <- grepl("-", unmatched, fixed=TRUE)
## drophyphen <-  str_split_fixed(unmatched[hyphens], "-", 2)[,1]
## head(drophyphen)


#tpl <- read.csv("../data/theplantlist1.1/names_unique.csv", stringsAsFactors=FALSE)
tpl <- scan("../theplantlist1.1/tpl_accepted_and_syn", "character", sep="\n")
# tpl <- subset(tpl, status != "Unresolved")  # ignore unresolved names?
#tpl <- paste(tpl$genus, tpl$species)


# names that are both TPL names, could be wrong
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
# now manually check other suspects!

write.csv(keep, "../query_names/gbif_tank_lookup_140906_cleaned.csv", row.names=FALSE)

## Now do some more removal manually:

## 1. any genus mismatch when both species are in TPL
## 2. Any case were both are in TPL and se differences is anything but a clear
## minor mispelling. Eg sylvestris vs silvestris
## 3. Any case were difference is definite alternative latin: eg "micro" for
## "macro" should not match, so remove depsite only one char diff.

checked_names <- read.csv("../query_names/gbif_tank_lookup_140906_cleaned_manual.csv", stringsAsFactors=FALSE)

checked_names$manual.remove[is.na(checked_names$manual.remove)] <- FALSE
final.lookup <- subset(checked_names, ! (remove | manual.remove))

write.csv(final.lookup, "../query_names/gbif_tank_lookup_final.csv", row.names=FALSE)

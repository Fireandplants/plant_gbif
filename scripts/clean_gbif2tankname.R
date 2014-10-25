#!/usr/env Rscript

## Dylan Schwilk

## clean the results for running the gbif2tankname fuzzy matching script. That
## script intentially overmatches. The solution is to identify "suspects"
## according to Jaro Winkler similarities. Keep clear gender switches and cull
## all suspect matches in which both names are a TPL name as those are probably
## false positives. Some additional manual checking is still necessary to catch
## some spelling hcanges that result in rather low JW similarities (eg
## "silvestris" vs "sylvestris").

library(stringr)

gbif2tank <-  read.csv("../query_names/gbif_tank_lookup_141024.csv", stringsAsFactors=FALSE)
names(gbif2tank) <- c("gbif","tank", "genus_jw", "se_jw", "gswitch")
fmatches <- subset(gbif2tank, tank!=gbif)
length(fmatches$gbif)


allgbif <- read.csv("../query_names/gbif-occurrences-names_141023.txt",
                    header=FALSE, stringsAsFactors=FALSE)$V1

unmatched <- allgbif[! allgbif %in% gbif2tank$gbif]
length(unmatched)
length(gbif2tank$gbif)

tpl <- scan("../theplantlist1.1/tpl_accepted_and_syn", "character", sep="\n")

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

## This section simply to take advantage of the fact we ahve run many of these
## matches on an earlier GBIF download os we can use previously manually
## checked names to save time.
checked_names1 <- read.csv("../query_names/gbif_tank_lookup_140906_cleaned_manual.csv",
                          stringsAsFactors=FALSE)
checked_names2 <- read.csv("../query_names/gbif_tank_lookup_141024_newonly_cleaned_manual.csv",
                              stringsAsFactors=FALSE)
## added about 600 new lookups
checked_names <- rbind(checked_names1, checked_names2)
checked_names$manual.remove[is.na(checked_names$manual.remove)] <- FALSE
checked_names <- checked_names[, c(1,2,9)] # just get gbif, tank and manual_remove
keep <- merge(keep, checked_names, by = c("gbif", "tank"), all.x=TRUE)

# now manually check other suspects, so write to file.
write.csv(keep, "../query_names/gbif_tank_lookup_141024_cleaned.csv", row.names=FALSE)

## The current lookup WILL contain overmatches, so now do some more removal
## manually:

## Remove any match that meets any of the following conditions:

## 1. Any genus mismatch when both species are in TPL
## 2. Both names are in TPL and the specific epithet differences is anything
## but a clear minor mispelling. Eg sylvestris vs silvestris, some "ae" for "i"
## changes. These could be automated but are not yet.
## 3. Any case were difference is definite alternative latin: eg "micro" for
## "macro" should not match, so remove despite only one char diff. Again, these
## should be automated but are not. Typical cases: "micro"/"macro",
## "florus"/"folius"

checked_names <- read.csv("../query_names/gbif_tank_lookup_141024_cleaned_manual.csv",
                          stringsAsFactors=FALSE)

checked_names$manual.remove[is.na(checked_names$manual.remove)] <- FALSE
final.lookup <- subset(checked_names, ! (remove | manual.remove))

write.csv(final.lookup, "../query_names/gbif_tank_lookup_final.csv",
           row.names=FALSE)

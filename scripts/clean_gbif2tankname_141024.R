#!/usr/env Rscript

library(stringr)

## Dylan Schwilk

## New version to merge the fuzzy matching from July 2014 with new names from October 2014.

gbif2tank.new <-  read.csv("../query_names/gbif_tank_lookup_141024_newonly.csv", stringsAsFactors=FALSE)
names(gbif2tank.new) <- c("gbif","tank", "genus_jw", "se_jw", "gswitch")

fmatches <- subset(gbif2tank.new, tank!=gbif)
length(fmatches$gbif)

tpl <- scan("../theplantlist1.1/tpl_accepted_and_syn", "character", sep="\n")

# names that are both TPL names, could be wrong
gbif2tank.new$bothtpl <- gbif2tank.new$gbif != gbif2tank.new$tank &
    (gbif2tank.new$gbif %in% tpl & gbif2tank.new$tank %in% tpl) 

# other suspects
gbif2tank.new$suspect <- gbif2tank.new$genus_jw < 0.96 |  gbif2tank.new$se_jw < 0.96

# rule for removal:
gbif2tank.new$remove <- gbif2tank.new$bothtpl & gbif2tank.new$suspect & 
        ( gbif2tank.new$gswitch != "True" )

remove <- subset(gbif2tank.new, remove)
length(remove$gbif)

keep <- subset(gbif2tank.new, !remove)
keep <- keep[with(keep,order(se_jw)),]
length(subset(keep, se_jw < 0.96)$gbif)

head(keep[with(keep, order(se_jw)),], 100)
# now manually check other suspects!

write.csv(keep, "../query_names/gbif_tank_lookup_141024_newonly_cleaned.csv",
          row.names=FALSE)

## Now do some more removal manually:

## 1. any genus mismatch when both species are in TPL
## 2. Any case were both are in TPL and se differences is anything but a clear
## minor mispelling. Eg sylvestris vs silvestris
## 3. Any case were difference is definite alternative latin: eg "micro" for
## "macro" should not match, so remove depsite only one char diff.

checked_names <- read.csv("../query_names/gbif_tank_lookup_140906_cleaned_manual.csv",
                          stringsAsFactors=FALSE)
checked_names.new <- read.csv("../query_names/gbif_tank_lookup_141024_newonly_cleaned_manual.csv",
                              stringsAsFactors=FALSE)

## added about 600 new lookups
checked_names <- rbind(checked_names, checked_names.new)
checked_names$manual.remove[is.na(checked_names$manual.remove)] <- FALSE
final.lookup <- subset(checked_names, ! (remove | manual.remove))

write.csv(final.lookup, "../query_names/gbif_tank_lookup_final.csv", row.names=FALSE)

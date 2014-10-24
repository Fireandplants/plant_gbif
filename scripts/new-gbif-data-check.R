
# Some checks on the new GBIF plantae data dump (2014-10-22). I don't wantt o
# run fuzzy matching on everything again, so just check whcih new names have
# been added since July 2014
old.gbif.names <- read.csv("../query_names/gbif-occurrences-names_140905.txt",
                           header=FALSE, stringsAsFactors=FALSE)$V1
new.gbif.names <- read.csv("../query_names/gbif-occurrences-names_141023.txt",
                           header=FALSE, stringsAsFactors=FALSE)$V1

length(old.gbif.names)
length(new.gbif.names)

new.names <- new.gbif.names[! new.gbif.names %in% old.gbif.names]
length(new.names)
# 5859
cat(new.names, file="../query_names/gbif-occurrences-names_141023_newonly.txt", sep="\n")

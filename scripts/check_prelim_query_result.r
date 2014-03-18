# 2014-03-18 
# schwilk

prelim.res <- read.csv("../query_names/GBIF_lookup-cleaned.txt", sep="\t", header=FALSE)
names(prelim.res) <- c("GBIF.taxon.key", "kingdom", "family", "scientific.name", "qname", "nrecords" )

more50 <- subset(prelim.res, nrecords >= 50)
length(more50$scientific.name)
#[1] 55245


more100 <- subset(prelim.res, nrecords >= 100)
length(more100$scientific.name)
#[1] 44079

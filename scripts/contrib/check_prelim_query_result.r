## Purpose: to examine the list of names that returned matches
## from GBIF provided by Jan Legind (03/17/14)

library(ape)

prelim.res <- read.table("../query_names/GBIF_lookup-cleaned.txt", header=T, sep=' ')
names(prelim.res)
#[1] "GBIF_id"  "kingdom"  "family"   "name"     "binomial" "count"

## more than zero records
sum(prelim.res$count > 0)
#[1] 83269

more50 <- subset(prelim.res, count >= 50)
nrow(more50)
#[1] 55245

more100 <- subset(prelim.res, count >= 100)
nrow(more100)
#[1] 44079

## no records
sum(prelim.res$count == 0)
#[1] 4866

## graphical summary
plot(density(log10(prelim.res$count)))

## read in tree
tree = read.tree('../../bigphylo/Tank-tree/Vascular_Plants_rooted.dated.tre')
tree_sp = sub('_', ' ', tree$tip.label)
length(tree_sp)
#[1] 31749

## how many tips have GBIF records
sum(tree_sp %in% prelim.res$binomial[prelim.res$count > 0])
#[1] 30903
## how many tips don't have GBIF records
sum(!(tree_sp %in% prelim.res$binomial[prelim.res$count > 0]))
#[1] 846

tree_sp_mi = tree_sp[!(tree_sp %in% prelim.res$binomial[prelim.res$count > 0])]

## examine tnrs results --------------------------------------------------------
tnrs = read.csv('../query_names/taxa_for_big_phylo_tnrs.csv') 


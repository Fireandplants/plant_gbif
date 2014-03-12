## purpose: to compare the list of names sent to GBIF in 2011 with 
## those names on the Tank phylo tree

library(ape)

sp = read.table('./query_names/Zanne_GBIF_taxa_list_Aug2011.txt', sep=',')
sp = as.character(sp[ , 1])
sp = sub(' ', '_', sp)

tree = read.tree('../bigphylo//Tank-tree/Vascular_Plants_rooted.dated.tre')

sum(tree$tip.label %in% sp)
#[1] 22926
length(tree$tip.label)
#[1] 31749

## so all the names in the query list are not on the tree
## this is possibly because of synonymy issues?

missing_tips = tree$tip.label[!(tree$tip.label %in% sp)]

write.table(missing_tips, file='./query_names/missing_tank_tree_tips.txt',
            row.names=F, col.names=F, quote=F)

## generate a complete list to send for a gbif query
all_sp = unique(c(tree$tip.label, sp))
all_sp = sub('_', ' ', all_sp)

write.table(all_sp, file='./query_names/taxa_for_big_phylo_gbif_query_03_12_2014.txt',
            row.names=F, col.names=F, quote=F) 

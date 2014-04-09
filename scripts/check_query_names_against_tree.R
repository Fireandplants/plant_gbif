## purpose: to compare the list of names sent to GBIF in 2011 with 
## those names on the Tank phylo tree

library(ape)

sp = read.table('../query_names/Zanne_GBIF_taxa_list_Aug2011.txt', sep=',')
sp = as.character(sp[ , 1])
sp = sub(' ', '_', sp)

tree = read.tree('../../bigphylo/Tank-tree/Vascular_Plants_rooted.dated.tre')

sum(tree$tip.label %in% sp)
#[1] 22926
length(tree$tip.label)
#[1] 31749

## so all the names in the query list are not on the tree
## this is possibly because of synonymy issues?

missing_tips = tree$tip.label[!(tree$tip.label %in% sp)]

write.table(missing_tips, file='../query_names/missing_tank_tree_tips.txt',
            row.names=F, col.names=F, quote=F)

## generate a complete list to send for a gbif query----------------------------
all_sp = unique(c(tree$tip.label, sp))
all_sp = sub('_', ' ', all_sp)

write.table(all_sp,
            file='../query_names/taxa_for_big_phylo_gbif_query_03_12_2014.txt',
            row.names=F, col.names=F, quote=F)


## Check this list against the new one created using synonymize.py and TPL1.1
## data

tanknames.expanded <- read.table("../query_names/taxa_for_bigphylo_gbif_query_04_08_14.txt", sep = ",",)
tanknames.expanded = as.character(tanknames.expanded[ , 1])

not.in.new <- all_sp[!(all_sp %in% tanknames.expanded)]
length(not.in.new)

## what? THere are a lot of taxa in the Zanne list that are not in the tank
## tree and don't ahve synonyms according to TPL1.1 Perhaps because The Zanne
## et al list included potential gender changes? eg "Abarema adenophora" is in
## the Zanne list, is not in the tank tree, and is not a synonym or "sister
## synonym" of anything in the tank tree. It is an accepted name as is "Abarema
## adenophorum" -- perhaps the Zanne list included this as a synonym based on
## matching? I'm not sure

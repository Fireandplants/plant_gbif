# Code by Will Pearse
# Sent by Amy Zanne

#Headers
require(taxize)
require(xlsx)
scrub.names <- function(names){
  #Make everything "genus_species"
  names <- gsub("  ", "_", names)
  names <- gsub(" ", "_", names)
  names <- gsub(".", "_", names, fixed=TRUE)
  names <- tolower(names)
  
  #Remove the oddities
  names <- gsub("_sp\\.$", "", names)
  names <- gsub("_spp\\.$", "", names)
  names <- gsub("_sp$", "", names)
  names <- gsub("_spp$", "", names)
  
  #Handle hybrids differently
  # - TO DO!
  #Extract the first two parts (i.e. genus_species)
  names <- sapply(strsplit(names, "_", fixed=TRUE), function(x) paste(x[1:2], collapse="_"))
  
  return(names)
}

#Load plantlist
tpl <- read.csv("~/Dropbox/SESYNC.Macroevolution.ES.Trees/Taxonomy/pG/plantlist-all-23-Sep-2013.csv")
tpl <- tpl[tpl$Taxonomic.status.in.TPL == "Accepted",]
tpl.species <- unique(tolower(with(tpl, paste(Genus, Species, sep="_"))))
tpl.genera <- paste(tolower(unique(tpl$Genus)), "_NA", sep="")
rm(tpl)

#Read everything in
economic <- read.csv("~/Dropbox/SESYNC.Macroevolution.ES.Trees/Taxonomy/PGNameScrubbing/PGTaxaUniques.csv")$Genus.species
fia <- read.xlsx("~/Dropbox/SESYNC.Macroevolution.ES.Trees/2.US.Tree.Services/Species list/FIA_species_list.xls", 1)$Genus_spp
grin <- read.csv("~/Dropbox/SESYNC.Macroevolution.ES.Trees/Databases/World_Economic_Plants_GRIN/GRIN_economic_plants_flatfile.csv")$Genus_species
sepsal <- read.csv("~/Dropbox/SESYNC.Macroevolution.ES.Trees/Databases/SEPSAL_tropical_drylands_plants/SEPSAL_economic_plants_flatfile.csv")$Genus_species

#Remove duplicates, etc.
input.spp <- unique(c(as.character(economic), as.character(fia), as.character(grin), as.character(sepsal)))
input.spp.scrub <- scrub.names(input.spp)
input.spp.already.clean <- input.spp.scrub %in% tpl.species | input.spp.scrub %in% tpl.genera
input.spp.tpl.search.string <- gsub("_", " ", input.spp.scrub, fixed=TRUE)
input.spp.tpl.search.string <- gsub(" NA", "", input.spp.tpl.search.string, fixed=TRUE)

#Clean the remaining ones...
# - bit by bit because TPL_SEARCH is a fucking nightmare, and taxonstand isn't much better...
tpl_1 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][1:500])
tpl_2 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][501:1000])
tpl_3 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][1001:1500])
tpl_4 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][1501:2000])
tpl_5 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2001:2500])
tpl_6_1 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2501:2600])
tpl_6_2 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2601:2700])
tpl_6_3_1<- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2701:2750])
tpl_6_4 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2801:2900])
tpl_6_5 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2901:3000])
tpl_7 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][3001:3500])
tpl_8 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][3501:3744])

#Something in this list is breaking the download...
tpl_6_3_2_1 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2751:2774])
tpl_6_3_2_2 <- tpl_search(input.spp.tpl.search.string[!input.spp.already.clean][2775:2800][-24])
#OK, it's 2798, and I've emailed reporting the bug to the developers

#Link everything together
tpl <- rbind(tpl_1,tpl_2,tpl_3,tpl_4,tpl_5,tpl_6_1,tpl_6_2,tpl_6_3_1,tpl_6_3_2_1,tpl_6_3_2_2[-24:-25,],rep(NA,ncol(tpl_1)),tpl_6_3_2_2[24:25,],tpl_6_4,tpl_6_5,tpl_7,tpl_8)
tpl$New.Genus[tpl$Plant.Name.Index==FALSE] <- NA
tpl$New.Species[tpl$Plant.Name.Index==FALSE] <- NA

#Make lookup
lookup <- data.frame(input=input.spp, scrubbed=input.spp.scrub, clean=character(length(input.spp.scrub)), stringsAsFactors=FALSE)
lookup$clean[input.spp.already.clean] <- lookup$scrubbed[input.spp.already.clean]
lookup$clean[!input.spp.already.clean] <- with(tpl, tolower(paste(New.Genus, New.Species, sep="_")))
lookup$method <- as.factor(ifelse(input.spp.already.clean, "will.scrub", "tpl.lookup"))
lookup$clean[lookup$clean=="na_na"] <- NA

#Upper case the first character so it matches the Tank phylogeny
lookup$clean <- paste(toupper(substring(lookup$clean, 1, 1)), substring(lookup$clean, 2), sep="")

#save.image("~/Desktop/tax_parsing.RData")
rm(economic,fia,grin,input.spp,input.spp.already.clean,input.spp.scrub,input.spp.tpl.search.string,lookup.genera,lookup.species,scrub.names,sepsal,seq.spp,t,test,tpl,tpl_1,tpl_2,tpl_3,tpl_4,tpl_5,tpl_6_1,tpl_6_2,tpl_6_3_1,tpl_6_3_2_1,tpl_6_3_2_2,tpl_6_4,tpl_6_5,tpl_7,tpl_8,tpl.genera,tpl.search,tpl.species)
save.image("~/Dropbox/SESYNC.Macroevolution.ES.Trees/Taxonomy/thirdPass.RData")

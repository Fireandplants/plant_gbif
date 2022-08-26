## The current lookup WILL contain overmatches, so now do some more removal
## manually:

library(dplyr)
library(tidyr)
library(readr)

checked_names <- read_delim("../query_names/gbif_myco_lookup_220826_manual.csv", delim="\t")
gbif_both <- read_delim("../query_names/gbif-occurrences-names_220823_both", delim="\t", col_names=FALSE)

gbif_both <- separate(data = gbif_both, col = X2,
                      into = c("gx", "genus", "sx", "se", "infra_rank", "infra_e", "author"), sep = "\\|")

gbif_both <- mutate(gbif_both,
                    matched_gbif_name = str_trim(gsub('( )+',' ', paste(genus, se, infra_rank, infra_e,sep=" "))) )

gbif_both <- select(gbif_both, gbif=matched_gbif_name, gbif_full=X1)
nrow(gbif_both)
# 661679

checked_names$manual_remove[is.na(checked_names$manual_remove)] <- FALSE
final_lookup <- filter(checked_names, !manual_remove)
nrow(final_lookup)
# 24991

result <- select(final_lookup, gbif, canonical)
nrow(result)
result <- left_join(result, gbif_both)
nrow(result)
#left_join(final_lookup, gbif_both, by="gbif") # merge by the parsed (non author) gbif names

result <- result %>% select(canonical_or_syn=canonical, gbif_match = gbif, gbif_full)
write_delim(result, "../query_names/gbif_myco_lookup_220826_final.csv", delim="\t")


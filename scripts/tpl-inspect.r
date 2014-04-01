# take a look at the TPL list Beth created
#
# The same synonyms match to multiple 

tpl <- read.csv("../theplantlist1.1/TPL1.1_synonyms.csv")
length(tpl$syn)
# [1] 830977
unique.syn <- unique(tpl$synonym)
length(unique.syn)
#[1] 755159
unique.acc <- unique(tpl$accepted)
length(unique.acc)
# [1] 345525
# So there are duplicates in the left hand column (synonyms) Why?  We only expect them in the right hand
# lets see if there are simply completely duplicated data
both <- paste(tpl$synonym,tpl$accepted)
unique.both <- unique(both)
length(unique.both)
#[1] 830977 Hm, do not appear to be, weird So we have alternative, conflicting
# lookups from synonym -> accepted. This is not right

# let's find em
syn.dupes <- subset(tpl, duplicated(tpl$synonym))
 
head(syn.dupes)
length(syn.dupes$synonym)
## [1] 75818, yup. 830977 - 75818 = 755159
## ok

syn.doubles <- subset(tpl, synonym %in% syn.dupes$synonym)
length(syn.doubles$synonym)
length(unique(syn.doubles$synonym))
#[1] 53844  # that is a lot of synonyms that are matching to multiple "accepted"
syn.d.sorted <- syn.doubles[with(syn.doubles, order(synonym)),]
head(syn.d.sorted)

##             X                    synonym                    accepted
## 58         58      Abacopteris_insularis       Abacopteris_insularis
## 238769 238769      Abacopteris_insularis        Cyclosorus_insularis
## 643220 643220      Abacopteris_insularis       Pronephrium_insularis
## 63         63 Abacopteris_longipetiolata  Abacopteris_longipetiolata
## 238820 238820 Abacopteris_longipetiolata  Cyclosorus_longipetiolatum
## 643230 643230 Abacopteris_longipetiolata Pronephrium_longipetiolatum


## So, why?
## ???

## Are there names in the accepted column that are not in the synonym column?
## There should not be if names with no synonyms are mapped to themselves.

missing.acc <- tpl$accepted[!tpl$accepted %in% tpl$synonym]
length(unique(missing.acc))
# [1] 1107
head(unique(missing.acc))
## > head(unique(missing.acc))
## [1] Abies_borisii-regis    Acacia_pseudo-intsia   Acaena_novae-zelandiae
## [4] Acer_coriaceum         Acer_martini           Acer_varbossanium

# Are many hyphenated specific epithets?
missing.hyphenated <- missing.acc[grepl("-", missing.acc, fixed=TRUE)]
length(unique(missing.hyphenated))
# [1] 556
# Not all, but about half
# How many total hyphenated?
hyphenated <- tpl$accepted[grepl("-", tpl$accepted, fixed=TRUE)]
length(unique(hyphenated))
# [1] 556
# so every hyphenated name is missing from left hand side!
# Any on left?
hyphenated.syn <- tpl$synonym[grepl("-", tpl$synonym, fixed=TRUE)]
length(unique(hyphenated.syn))
[1] 0

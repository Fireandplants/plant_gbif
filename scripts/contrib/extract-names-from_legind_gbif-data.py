
## 2014-09-05
## Dylan Schwilk

## Script to replace the gbif returned names from the 11.5 million records Jan
## Legind sent and replace with out canonical names

gbif_locations_file = "../data/nescent_gbif_09-07-2014.csv"
gbif_interpreted_names_file = "../query_names/nescent_interpreted_names.csv"

## build gbif interpretation name map


#gbif_locations_file = "../data/temp.csv"
gbif_locations = open(gbif_locations_file)
outnames = open("../query_names/gbif_locations_taxon_names_140709.txtb", "w")

header = gbif_locations.readline()
res = []
for line in gbif_locations :
    fields = line.split(",")
    res.append(fields[0][1:-1] + "\n")

outnames.writelines(res)
outnames.close()


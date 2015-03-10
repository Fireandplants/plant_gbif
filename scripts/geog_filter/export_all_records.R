## Part V - Compile all records, drop remaining duplicates, and export
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Description:
## read in the genus level datafiles and rbind them together without summarizing
## then export two files:
## 1) 'gbif_all_remote_data.csv' which has information on all the relevant variables
## 2) 'gbif_coords.csv' which only has the fields: spname, long, lat, and alt

inputDir = './data/genus_sort/'
outputDir = './data/'
fileNames = dir(inputDir)
genusFiles = sapply(strsplit(fileNames,'-[[:digit:]]'), function(x) unlist(x)[[1]])
genusList = sort(unique(genusFiles))

for (i in seq_along(genusList)) {
    for (j in which(genusFiles %in% genusList[i])) {
        datTemp = read.csv(file.path(inputDir, fileNames[j]))
        if(!exists('dat'))
            dat = datTemp
        else
            dat = rbind(dat, datTemp)
    }
    rm(datTemp)
    ## drop duplicates
    filtering_columns = c('tankname', 'decimalLatitude', 'decimalLongitude')
    dat = subset(dat, !duplicated(dat[ , filtering_columns]))
    ## order the rows alphabetically by species name
    dat = dat[order(as.character(dat$tankname)), ]
    ## now begin exporting process
    subfields = c("tankname", "decimalLongitude", "decimalLatitude")
    if (i == 1) {
        write.table(dat, file=file.path(outputDir, 'gbif_all_remote_data.csv'),
                    sep=',', row.names=F)
        write.table(dat[ , subfields], file=file.path(outputDir, 'gbif_coords.csv'),
                    sep=',', row.names=F)
    }
    else {
        write.table(dat, file=file.path(outputDir,'gbif_all_remote_data.csv'), 
                    sep=',', row.names=F, append=TRUE, col.names=FALSE)
        write.table(dat[ , subfields], file=file.path(outputDir, 'gbif_coords_alt.csv'),
                    sep=',', row.names=F, append=TRUE, col.names=FALSE)                
    }
}

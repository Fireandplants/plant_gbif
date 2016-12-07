## Part V - Compile all records, drop remaining duplicates, and export
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Description:
## read in the genus level datafiles and rbind them together without summarizing
## then export two files:
## 1) 'gbif_all_remote_data.csv' which has information on all the relevant variables
## 2) 'gbif_coords.csv' which only has the fields: spname, long, lat, and alt

input_dir = './data/genus_sort/'
output_dir = './data/'
file_names = dir(input_dir)
genus_files = sapply(strsplit(file_names,'-[[:digit:]]'), function(x) unlist(x)[[1]])
genus_list = sort(unique(genus_files))

for (i in seq_along(genus_list)) {
    for (j in which(genus_files %in% genus_list[i])) {
        dat_temp = read.csv(file.path(input_dir, file_names[j]))
        if(!exists('dat'))
            dat = dat_temp
        else
            dat = rbind(dat, dat_temp)
    }
    rm(dat_temp)
    ## drop duplicates
    filtering_columns = c('tankname', 'decimallatitude', 'decimallongitude')
    dat = subset(dat, !duplicated(dat[ , filtering_columns]))
    ## order the rows alphabetically by species name
    dat = dat[order(as.character(dat$tankname)), ]
    ## now begin exporting process
    subfields = c("tankname", "decimallongitude", "decimallatitude")
    file1 = paste('gbif_all_remote_data_', Sys.Date(), '.csv', sep='')
    file2 = paste('gbif_coords_', Sys.Date(), '.csv', sep='')
    if (i == 1) {
        write.table(dat, file=file.path(output_dir, file1),
                    sep=',', row.names=F)
        write.table(dat[ , subfields], file=file.path(output_dir, file2),
                    sep=',', row.names=F)
    }
    else {
        write.table(dat, file=file.path(output_dir, file1), 
                    sep=',', row.names=F, append=TRUE, col.names=FALSE)
        write.table(dat[ , subfields], file=file.path(output_dir, file2),
                    sep=',', row.names=F, append=TRUE, col.names=FALSE)                
    }
    rm(dat)
    print(paste('Genus', genus_list[i], 'appended'))
}

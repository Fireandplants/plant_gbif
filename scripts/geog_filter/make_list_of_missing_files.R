
#make a list of files that should exist

library(readr)
input_dir = './data/filtered_results/'
file_names = dir(input_dir)[grep('filter-', dir(input_dir))]

file_ct <- 0
out_files <- c()
for (i in seq_along(file_names)) {
    dat = read_csv(file.path(input_dir, file_names[i]))
    ## pull genus out of name column
    genus = sapply(strsplit(as.character(dat$canonical_name),' '), function(x) unlist(x)[1])
    genus_list = sort(unique(genus))
    out_files = c(out_files, paste(genus_list, 
                     strsplit(file_names[i], 'filter')[[1]][2], sep=''))
    file_ct <- file_ct + length(genus_list)
}

existing_files <- dir('./data/genus_sort')
length(existing_files)

# which files not present
absent <- which(!(out_files %in% existing_files))

# write missing file list to file
write.table(out_files[absent], file = './data/missing_from_genus_sort.txt')




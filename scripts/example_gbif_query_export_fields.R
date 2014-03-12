
dat_ex = read.delim('./data/gbif_example_query_result.txt', colClasses='character',
                 as.is=TRUE, quote='', header=T)

names(dat_ex)

str(dat_ex)

write.table(names(dat_ex), './data/gbif_example_fields.txt', col.names=F,
            row.names=F, quote=F)

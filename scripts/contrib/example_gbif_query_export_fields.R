
dat_ex = read.delim('./data/gbif_example_query_result.txt', colClasses='character',
                 as.is=TRUE, quote='', header=T)

names(dat_ex)

str(dat_ex)

write.table(names(dat_ex), './data/gbif_example_fields.txt', col.names=F,
            row.names=F, quote=F)


fields_to_query = c('id',
                    'dataset_id', 
                    'basis_of_record',
                    'scientific_name',
                    'taxon_id',
                    'country_code',
                    'latitude',
                    'longitude',
                    'year',
                    'elevation_in_meters',
                    'verbatim_latitude',
                    'verbatim_longitude',
                    'coordinate_precision',
                    'continent_ocean',
                    'state_province',
                    'county',
                    'country',
                    'locality')

write.table(fields_to_query, file='./query_names/gbif_fields.txt', col.names=F,
            row.names=F, quote=F)

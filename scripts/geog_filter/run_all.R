## Run all filtering scripts sequentially
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Date: 04/2015
## Description:
## This script calls each of the data grooming scripts sequentially
## and thus can be used to generate all relevant data products. The directory
## this script is called from must contain the unpacked GBIF raw datafiles in a
## directory called 'gbif_raw_data' and the working directory must also contain
## the files 'names-tr.txt','speciesTraitData.csv','headers_commadelim_rerun.txt',
## and 'GBIF_functions.R'. The script will create the following directories if
## they do not exist:
## 'gbif_data_chunks','filtered_results','genus_sort', & 'genus_results' 
## Lastly the relevant GIS datalayers that are called must be present in the 
## directory '../gis/' 
## and the following R packages are installed: 
## 'sp','raster','rgdal','foreach','snow','snowfall','doSNOW'

dir.create('./log_files')
dir.create('./data/gbif_chunks')

## Part I

nlines = '500000'
log_file = './log_files/chunk_gbif.log'
input_file = './data/gbif-occurrences_extracted_141030.csv'
cmd = paste('python ./scripts/split-csv.py -v -d -n', nlines,
            '-o./data/gbif_chunks/chunk-', input_file, '>', log_file, '2>&1')
system(cmd)

## Part II
#system('Rscript ./scripts/geog_filter/GBIF_make_splist.R > ./log_files/make_splist.log 2>&1',
#       wait=F)

## Part III
system('Rscript ./scripts/geog_filter/setup_geog_data.R > ./log_files/setup_geog_data.log 2>&1',
       wait=F)

## Part IV
system('Rscript ./scripts/geog_filter/geog_filter.R > ./log_files/geog_filter.log 2>&1', wait=F)

## Part V
system('Rscript GBIF_climate_query.R > ./log_files/climate_query.log 2>&1', wait=F)

## Part VI
system('Rscript GBIF_climate_summary.R > ./log_files/climate_summary.log 2>&1', wait=F)

## Part VII
system('Rscript GBIF_export_all_records.R > ./log_files/export_all_records.log 2>&1', wait=F)

## Part VIII
system('Rscript GBIF_package_summaries.R > ./log_files/package_summaries.log 2>&1', wait=F)

## Part IX
system('Rscript GBIF_output_freezing_exposure.R >./log_files/output_freezing_exposure.log 2>&1', wait=F)

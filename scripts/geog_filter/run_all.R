## Run all filtering scripts sequentially
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Date: 04/2015
## Description:
## This script calls each of the data grooming scripts sequentially
## and thus can be used to generate all relevant data products. 
## The relevant GIS datalayers that are called must be present in the 
## directory '../gis/' 
## and the following R packages are installed: 
## 'sp','raster','rgdal','foreach','snow','snowfall','doSNOW'

dir.create('./log_files')
dir.create('./data/gbif_chunks')

## Part I - Break up GBIF data dump into smaller files
script_file = './scripts/split-csv.py'
options = '-v -d'
nlines = '-n 500000'
log_file = './log_files/chunk_gbif.log'
input_file = './data/gbif-occurrences_extracted_141030.csv'

cmd = paste('python', script_file, options, nlines,
            '-o./data/gbif_chunks/chunk-', input_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Part II - Prepare remotely sensed data for queries
script_file = './scripts/geog_filter/setup_geog_data.R'
log_file = './log_files/setup_geog_data.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Part III - Geographically filter dataset
script_file = './scripts/geog_filter/geog_filter.R'
log_file = './log_files/geog_filter.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Part IV - Query remotely sensed data
script_file = './scripts/geog_filter/climate_query.R'
log_file = './log_files/climate_query.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Part V - compile all records, drop remaining duplicates, and export
script_file = './scripts/geog_filter/export_all_records.R'
log_file = './log_files/export_all_records.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)


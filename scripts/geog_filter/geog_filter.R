## Part IV - Geographically filter the GBIF data
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Date: 03/2015
## Description:
## This script takes a quick cut of the best data. 
## Filters:
## - no duplicated records
## - no non-numeric coordinates 
## - no coordinates without reasonable range 
## - no coordinates equal to exactly 0
## - not located within 0.01 decimal degree of Cophenhagen, Denmark
## - latitude not equal longitude 
## - low resolution coordinates dropped
## - not located within 0.01 decimal degree of a country's centroid
## - lat/long of the record must match the country or continent that was recorded
##   for the record.

library(foreach)
library(doSNOW) ##needed to initialize the cluster with foreach
library(snowfall) ##needed to create cluster
library(readr)

source('./scripts/geog_filter/GBIF_functions.R')

input_dir = './data/gbif_chunks'
file_names = dir(input_dir)
output_dir = './data/filtered_results'
dir.create(output_dir)

#out = dir(output_dir)
#files = sub('filter-', '', out)
#file_names = file_names[!(sub('chunk-', '', file_names) %in% files)]

load('./data/gbif_geog.Rdata')

sfInit(parallel=TRUE, cpus=24, type="SOCK")
sfLibrary(raster)
sfLibrary(readr)
registerDoSNOW(sfGetCluster())

foreach(i = 1:length(file_names), .inorder = FALSE) %dopar% {
    dat = read_csv(file.path(input_dir, file_names[i]))
    ## drop duplicates as defined by 
    ## rows that have the same species name and coordinates 
    ## this filter will be carried once again when aggregating to the species
    filtering_columns = c('tankname', 'decimallatitude', 'decimallongitude')
    dat = subset(dat, !duplicated(dat[ , filtering_columns]))
    ## drop rows that are duplicates according to the 'occurance id field'
    dat = subset(dat, !duplicated(dat$gbifid))
    ## Begin checking for coordinate issues
    ## drop rows in which coords are non-numberic with reasonable ranges 
    dat = subset(dat, is.coord(dat$decimallongitude, dat$decimallatitude))
    ## check that not within 50 km of Cophenhagen, Denmark where GBIF is
    true = notGBIFhq(dat$decimallongitude, dat$decimallatitude, cutoff=0.01)
    dat = subset(dat, true)
    ## check that lat not equal lon
    dat = subset(dat, dat$decimallatitude != dat$decimallongitude)
    ## drop low resolutions coordinates
    true = highres_coords(dat$decimallongitude, dat$decimallatitude, min_digits = 2)
    dat = subset(dat, true)
    ## drop coordinates within 0.01 degrees of country centroids
    ## this is slow but works for a modest number of centroids
    ## if more centroids are considered a gridding system will need to be used
    centroids = coordinates(countryDat)
    pts = SpatialPoints(cbind(as.numeric(dat$decimallongitude),
                              as.numeric(dat$decimallatitude)),
                        proj4string=CRS(proj4string(countryDat)))
    true = apply(coordinates(pts), 1, function(x) notCentroid(centroids, x))
    dat = subset(dat, true)
    ## check that Country_interpreted field matches coordinate at country and
    ## continent scales
    ## change the Namibia - NA country code to NAm
    dat$countrycode = sub('NA', 'NAm', dat$countrycode)
    indices = match(dat$countrycode, countryDat$code)
    continent = as.character(countryDat$continent[indices])
    ## now we ask if the recorded country and continent match what the lat/lon
    ## indicate (i.e., the pts object)
    gbif_geog = over(pts, countryDat) 
    gd_country = as.character(gbif_geog$code) == dat$countrycode
    gd_continent = as.character(gbif_geog$continent) == continent
    ## define a code to describe degree of confidence in coordinate smaller is better  
    geocode = rep(NA, nrow(dat)) 
    ## if country matches this is the highest level of validation
    geocode = ifelse(gd_country, 0, geocode)
    ## if continent matches this is next best level
    geocode = ifelse(!gd_country & gd_continent, 1, geocode)
    ## begin process of outputing data
    dat = data.frame(dat, geocode, continent)
    fields = c('gbifname', 'expandedname', 'tankname', 'basisofrecord',
               'decimallatitude', 'decimallongitude', 'year', 'countrycode', 
               'geocode', 'continent')
    dat = subset(dat, !is.na(geocode), fields)
    filename = sub('chunk-', 'filter-', file_names[i])
    write_csv(dat, path=file.path(output_dir, filename))
    print(paste('file', i, 'of', length(file_names)))
}

sfStop()

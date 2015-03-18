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

source('./scripts/geog_filter/GBIF_functions.R')

inputDir = './data/gbif_chunks'
fileNames = dir(inputDir)
outputDir = './data/filtered_results'
dir.create(outputDir)

#out = dir(outputDir)
#files = sub('filter-', '', out)
#fileNames = fileNames[!(sub('chunk-', '', fileNames) %in% files)]

load('./data/gbif_geog.Rdata')

sfInit(parallel=TRUE, cpus=8, type="SOCK")
sfLibrary(raster)
registerDoSNOW(sfGetCluster())

foreach(i = 1:length(fileNames), .inorder = FALSE) %dopar% {
    dat = read.csv(file.path(inputDir, fileNames[i]), colClasses='character')
    ## drop duplicates as defined by 
    ## rows that have the same species name and coordinates 
    ## this filter will be carried once again when aggregating to the species
    filtering_columns = c('tankname', 'decimalLatitude', 'decimalLongitude')
    dat = subset(dat, !duplicated(dat[ , filtering_columns]))
    ## drop rows that are duplicates according to the 'occurance id field'
    dat = subset(dat, !duplicated(dat$gbifID))
    ## Begin checking for coordinate issues
    ## drop rows in which coords are non-numberic with reasonable ranges 
    dat = subset(dat, is.coord(dat$decimalLongitude, dat$decimalLatitude))
    ## check that not within 50 km of Cophenhagen, Denmark where GBIF is
    true = notGBIFhq(dat$decimalLongitude, dat$decimalLatitude, cutoff=0.01)
    dat = subset(dat, true)
    ## check that lat not equal lon
    dat = subset(dat, dat$decimalLatitude != dat$decimalLongitude)
    ## drop low resolutions coordinates
    true = highres_coords(dat$decimalLongitude, dat$decimalLatitude, min_digits = 2)
    dat = subset(dat, true)
    ## drop coordinates within 0.01 degrees of country centroids
    ## this is slow but works for a modest number of centroids
    ## if more centroids are considered a gridding system will need to be used
    centroids = coordinates(countryDat)
    pts = SpatialPoints(cbind(as.numeric(dat$decimalLongitude),
                              as.numeric(dat$decimalLatitude)),
                        proj4string=CRS(proj4string(countryDat)))
    true = apply(coordinates(pts), 1, function(x) notCentroid(centroids, x))
    dat = subset(dat, true)
    ## check that Country_interpreted field matches coordinate at country and
    ## continent scales
    ## change the Namibia - NA country code to NAm
    dat$countryCode = sub('NA', 'NAm', dat$countryCode)
    indices = match(dat$countryCode, countryDat$code)
    continent = as.character(countryDat$continent[indices])
    true = !is.na(dat$countryCode) & !is.na(continent)
    ## now we ask if the recorded country and continent match what the lat/lon
    ## indicate (i.e., the pts object)
    gbifGeog = over(pts, countryDat) 
    goodCountry = as.character(gbifGeog$code) == dat$countryCode
    goodContinent = as.character(gbifGeog$continent) == continent
    ## define a code to describe degree of confidence in coordinate smaller is better  
    geoCode = rep(NA, nrow(dat)) 
    ## if country matches this is the highest level of validation
    geoCode = ifelse(goodCountry, 0, geoCode)
    ## if continent matches this is next best level
    geoCode = ifelse(!goodCountry & goodContinent, 1, geoCode)
    ## begin process of outputing data
    dat = data.frame(dat, geoCode, continent)
    fields = c('gbifname', 'expandedname', 'tankname', 'basisOfRecord',
               'decimalLatitude', 'decimalLongitude', 'year', 'countryCode', 
               'geoCode', 'continent.1')
    dat = subset(dat, !is.na(geoCode), fields)
    filename = sub('chunk-', 'filter-', fileNames[i])
    names(dat) = c(names(dat)[-ncol(dat)], 'continent')
    write.csv(dat, file=file.path(outputDir, filename), row.names = FALSE)
    print(paste('file', i, 'of', length(fileNames)))
}

sfStop()

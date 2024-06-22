## Part II - Prepare remotely sensed data for queries
## Purpose: is to setup the goegraphical databases. The script writes the 
## following datafiles to the './data/' directory:
## 1) "gbif_geog.Rdata"    two country lookup tables
## 2) "bioclim_alt_5m.grd" raster of prepared bioclim variables at 5 arc min
## 3) "ndvi.grd"           a raster of NDVI at the 10 arc min resolution.
## 4) "wwfeco.Rdata"       a shapefile containing the WWF's terrestrial ecoregions
## Contact: danmcglinn@gmail.com
## Date: 03/2015

library(sp)
library(raster)
library(maptools)
library(maps)
library(rgdal)

read.shape = function(shape_name, path=NULL) {
  require(rgdal)
  if (is.null(path)) {
    path = getwd()
  }
  fileName = paste(shape_name, '.shp', sep='')    
  shp = readOGR(file.path(path, fileName), shape_name)
}  

## the relevant country files are available here:
## http://code.google.com/p/gbif-dataportal/wiki/ConfiguringGeoserver
country = read.shape('country', '../gis/country')

## the relevant continent file is available here:
## http://pubs.usgs.gov/of/2006/1187/basemaps/continents/
continent = read.shape('continent', '../gis/continent')

## compute the the continent of each country
country_coords = SpatialPoints(coordinates(country))
proj4string(country_coords) = CRS(proj4string(country))
cc = over(country_coords, continent) 
country$CNTRY_NAME[is.na(cc)]
#[1] Papua New Guinea Gambia           Christmas Island Bermuda
## manually fix the few mistakes
cc[is.na(cc)] = c("Asia", "Africa", "Asia", "North America") 

countryCode = read.table("./data/country_codes.csv", header=TRUE, sep=',',
              colClasses="character")

sum(tolower(country$CNTRY_NAME) %in% tolower(countryCode[,1]))
country$CNTRY_NAME[!tolower(country$CNTRY_NAME) %in% tolower(countryCode[,1])]

indices = match(tolower(country$CNTRY_NAME), tolower(countryCode[,1]))
countryDat = cbind(country, cc, countryCode[indices, 2])
names(countryDat) = c(names(country), 'continent', 'code')
countryDat = SpatialPolygonsDataFrame(Sr = country, data = countryDat@data,
             match.ID = TRUE)
## now we can go to the GBIF data and based upon the 2 letter country 
## interpreted field look up the proposed continent of the record and check
## if their coordinates generally match with that. We can also check the
## proposed country name if is available

## add a continent designation to the countryCode object as well
indices = match(tolower(countryCode[,1]), tolower(countryDat$CNTRY_NAME))
countryCode = cbind(countryCode, as.character(countryDat$continent[indices]))
names(countryCode) = c(names(countryCode)[1:2], 'continent')
countryCode[ , 3] = as.character(countryCode[ , 3])
countryCode[is.na(countryCode$continent), ] 
## fix unknown continents in countryCode
continentFix = read.csv('./data/continent_manual_lookup.csv', header=TRUE,
               colClasses='character')
countryCode[is.na(countryCode$continent), ] = continentFix

save(countryDat, countryCode, file="./data/gbif_geog.Rdata")

## load altitude data
## this file is available here:
## http://biogeo.ucdavis.edu/data/climate/worldclim/1_4/grid/cur/alt_5m_bil.zip
alt = raster('../gis/WorldClimData/alt.bil')

## load bioclim, alt, and geographic information
## these files are located here: 
## http://biogeo.ucdavis.edu/data/climate/worldclim/1_4/grid/cur/bio_5m_bil.zip
bioStack = stack('../gis/WorldClimData/bioclim_5m.grd')

## combine bioclim and alt data
bioStack = addLayer(bioStack, alt)

## save raster stack
writeRaster(bioStack, file='./data/bioclim_alt_5m.grd', format='raster',
            overwrite=TRUE)

## NDVI data
ndvi = stack('../gis/GlobalVegData/Mean&Std/ndviAvg.grd')
fixNDVI = function(x){
  x2 = ifelse(x == 1, NA, x)
  out = (x2 - 128) / 128
  return(out)
}
ndvi = calc(ndvi, fixNDVI)
writeRaster(ndvi, file='./data/ndvi.grd', format='raster', overwrite=TRUE)

## WWF ecoregions
## downloaded 02/16/2013 from the following link:
#http://assets.worldwildlife.org/publications/15/files/original/official_teow.zip?1349272619
## metadata located:
#http://worldwildlife.org/publications/terrestrial-ecoregions-of-the-world
## helpful metadata is located at this link:
#http://stuff.mit.edu/afs/athena/course/11/11.951/ecoplan/data/ecoregions/wwf_terr_ecos.htm
wwfeco = read.shape('wwf_terr_ecos', '../gis/wwf/official/')
save(wwfeco, file='./data/wwfeco.Rdata')

## soil data
p_grid = stack('../gis/global_gridded_soil/p_grid.grd')
writeRaster(p_grid, file='./data/p_grid.grd', format='raster', overwrite=TRUE)

## Part IV - Query remotely sensed data
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Date: 11/2011
## Description:
## This script reads in the filtered GBIF data product and queries
## the remotely sensed data layers at each of the GBIF coordinates
## Output is a seperate file for each genus that is written to the 
## './data/genus_sort' directory

library(raster)

library(foreach)
library(doSNOW) 
library(snowfall)

inputDir = './data/filtered_results/'
outputDir = './data/genus_sort/'
dir.create(outputDir)

## bioenvio vars
bioStack = stack('./data/bioclim_alt_5m.grd')

## ndvi raster data
ndvi = stack('./data/ndvi.grd')

## load wwf ecoregions
load('./data/wwfeco.Rdata')

fileNames = dir(inputDir)[grep('filter-', dir(inputDir))]

sfInit(parallel=TRUE, cpus=8, type="SOCK")
sfLibrary(raster)
registerDoSNOW(sfGetCluster())

## create a seperate file for each genus
foreach(i = 1:length(fileNames), .inorder = FALSE) %dopar% {
    dat = read.csv(file.path(inputDir, fileNames[i]))
    ## pull genus out of name column
    genus = sapply(strsplit(as.character(dat$tankname),' '), function(x) unlist(x)[1])
    genusList = sort(unique(genus))
    ## go through genus list and pull all records for each species together
    ## extract climate data and then export the information
    for (j in seq_along(genusList)) { 
        datTemp = dat[genus == genusList[j], ]
        colNames = names(datTemp)
        coords = cbind(datTemp$decimalLongitude, datTemp$decimalLatitude)
        clim = extract(bioStack, coords)
        prod = extract(ndvi, coords)
        if (nrow(datTemp) == 1) {
            datTemp = data.frame(c(datTemp, clim, prod))
        }            
        else {
            datTemp = data.frame(datTemp, clim, prod)
        }
        eco_code = over(SpatialPoints(coords, CRS(proj4string(wwfeco))),
                        wwfeco)$eco_code
        datTemp = data.frame(datTemp, eco_code)
        names(datTemp) = c(colNames, names(bioStack), 'ndviAvg', 'eco_code')
        out_file = paste(outputDir, genusList[j], 
                         strsplit(fileNames[i], 'filter')[[1]][2], sep='')
        write.csv(datTemp, file=out_file, row.names=FALSE)
    }
    print(paste('file', i, 'of', length(fileNames), ep=' '))
}

sfStop()


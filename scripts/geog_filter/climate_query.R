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

library(readr)

source('./scripts/geog_filter/wise_soil_import.R')

input_dir = './data/filtered_results/'
output_dir = './data/genus_sort/'
dir.create(output_dir)

## bioenvio vars
bioStack = stack('./data/bioclim_alt_5m.grd')

## ndvi raster data
ndvi = stack('./data/ndvi.grd')

## soil data
p_grid = stack('./data/p_grid.grd')

## load wwf ecoregions
load('./data/wwfeco.Rdata')

file_names = dir(input_dir)[grep('filter-', dir(input_dir))]

sfInit(parallel=TRUE, cpus=24, type="SOCK")
sfLibrary(raster)
sfLibrary(foreign)
sfLibrary(nlme)
sfLibrary(readr)
registerDoSNOW(sfGetCluster())

## create a seperate file for each genus
foreach(i = 1:length(file_names), .inorder = FALSE) %dopar% {
    dat = read_csv(file.path(input_dir, file_names[i]))
    ## pull genus out of name column
    genus = sapply(strsplit(as.character(dat$tankname),' '), function(x) unlist(x)[1])
    genus_list = sort(unique(genus))
    ## go through genus list and pull all records for each species together
    ## extract climate data and then export the information
    for (j in seq_along(genus_list)) { 
        dat_temp = dat[genus == genus_list[j], ]
        col_names = names(dat_temp)
        coords = data.frame(Long=dat_temp$decimallongitude, Lat=dat_temp$decimallatitude)
        clim = extract(bioStack, coords)
        prod = extract(ndvi, coords)
        P = extract(p_grid, coords)[ , c('Total.P', 'Labile.Inorganic.P', 'organic.P')]
        soil = add.soil.data(coords)[ , c('TOTN', 'TAWC')]
        if (nrow(dat_temp) == 1) {
            dat_temp = data.frame(c(dat_temp, clim, prod, P, soil))
        }            
        else {
            dat_temp = data.frame(dat_temp, clim, prod, P, soil)
        }
        eco_code = over(SpatialPoints(coords, CRS(proj4string(wwfeco))),
                        wwfeco)$eco_code
        dat_temp = data.frame(dat_temp, eco_code)
        names(dat_temp) = c(col_names, names(bioStack), 'ndviAvg',
                           'Total.P', 'Labile.Inorganic.P', 'organic.P',
                           'TOTN', 'TAWC', 'eco_code')
        out_file = paste(output_dir, genus_list[j], 
                         strsplit(file_names[i], 'filter')[[1]][2], sep='')
        write_csv(dat_temp, path=out_file)
    }
    print(paste('file', i, 'of', length(file_names), ep=' '))
}

sfStop()



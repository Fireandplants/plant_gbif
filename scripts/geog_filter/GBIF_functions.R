## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Description: The functions are to help in the processesing of the GBIF data

countSpCoords = function(spName, dat){
    ## this function counts how many reasonable sets of lat and lon
    ## there are for a given species name using very simple rules
    ## Arguments:
    # spName: species name
    # dat: a gbif data.frame with meaningful names
    ## Output:
    # total number of coordinates that meet the criteria
    true = which(spName == dat$Scientific_name_interpreted)
    lat = as.numeric(dat$Latitude[true]) >= -90 &
      as.numeric(dat$Latitude[true]) <= 90
    lon = as.numeric(dat$Longitude[true]) >= -180 & 
      as.numeric(dat$Longitude[true]) <= 180
    out = sum(lat + lon == 2, na.rm=TRUE)   
    return(out)
}

countCuml = function(spCnts,breaks,filter=NULL){
  ## this function counts how many species have at least a given count value
  ## Aguments:
  # spCnts: a vector of integers each value is for a different species
  # breaks: the values at which to evaluate how many species have at least a given count
  # filter: a boolean variable that when true specifies a subset of the 
  ## which is specified by breaks, use the boolean filter argument to only look at a 
  ## subset of the counts.
  if(is.null(filter))
    tab = table(spCnts)
  else
    tab = table(spCnts[filter])
  tab = tab[-1]
  cnts = sapply(breaks, function(x) sum(tab[as.numeric(names(tab))>=x]))
  return(data.frame(cutoff = breaks, freq = cnts))
}

is.spname = function(spList){
  ## this function checks if each element of a character  vector
  ## appears to be species name
  ## Arguments:
  # spList: a vector of character strings
  ## Output:
  # logical vector
  ## Example:
  # is.spname(c("abc","quercus rubra","Quercus rubra","Quercus rubra var. rubra","Quercus rubra var rubra"))
  spList = as.character(spList)
  re = "^[A-Z][-A-z]+ [-a-z]+( [-a-z]+| subsp.? [-a-z]+| ssp.? [-a-z]+| var.? [-a-z]+| f.? [-a-z]+)?"  
  out = attr(regexpr(re,spList),'match.length') == nchar(spList)
  return(out)
}

tnrs_check = function(spnames, ...) {
  require(taxize)
  if (length(spnames) > 50)
    getpost = 'POST'
  else
    getpost = 'GET'
  name_data = tnrs(query=sp_names, getpost=getpost, ...) 
  ## check that sp_names is in name_data
  #which (spnames %in% name_data$submi
}

mrnaims_check = function(sp_names, mrnaims_path = '~/mr-naims') {
  ## uses the mr-naims python module to find the best accepted name
  ## for the supplied species names
  sp_file_path = file.path(mrnaims_path, 'sp.txt')
  write.table(sp_names, file=sp_file_path, row.names=FALSE, col.names=FALSE,
              quote=FALSE)
  args = paste('python ', mrnaims_path, '/simple.py --skip-gnrd -f ',
               sp_file_path, sep='')
  system(args, wait=TRUE)
  output = read.csv(file.path(mrnaims_path, 'sp_change_report.csv'))
  ## reorder names according to input order
  output = output[match(sp_names, output$submittedName), ]
  return(output)
}

is.hybrid = function(x) {
  hybrid = grep(' x ', x)
  hybrid = c(hybrid, grep('×', x))
  hybrid = c(hybrid, grep(' × ', x))
  out = rep(FALSE, length(x))
  out[hybrid] = TRUE
  return(out)
}

makeBinomial = function(x) {
  ## fix the taxonNames that are output by rgbif so that 
  ## they are more standardized binomials
  fix_space = gsub('  +', ' ', x, fixed=FALSE)
  find_replace = cbind(c('.', '?', '/', '*', 'cf ', ' cf', ' aff ', '- '),
                       c('' , '' , ' ', '' , ''   , ''   , ' '    , '-' ))
  clean_names = fix_space
  for (i in seq_along(find_replace[ , 1]))
    clean_names = gsub(find_replace[i, 1], find_replace[i, 2], clean_names, fixed = TRUE)
  fix_case = sapply(clean_names, sentence_case)
  name_split = strsplit(fix_case, ' +')
  bin_name = sapply(name_split, function(x) paste(x[1], x[2],sep=' '))
  return(as.vector(bin_name))
}

sentence_case = function(x) {
  x = tolower(x)
  firstword = strsplit(x, " ")[[1]][1]
  otherwords = strsplit(x, " ")[[1]][-1]
  firstword = paste(toupper(substring(firstword, 1,1)), 
                    substring(firstword, 2),  sep="", collapse=" ")
  otherwords = tolower(otherwords)
  out = paste(firstword, paste(otherwords, collapse=' '), sep=' ')
  return(out)
}

agrep_iter = function(pattern, x, incr=0.1, max.iter=100, 
                      max.distance=0.1, ...) 
{
  ## Purpose: to attempt to iteratively find the best partial
  ## match to a string
  ## Arguments:
  ## pattern: 
  ## x: 
  ## incr: the increment by which to change max.distance
  ## max.iter: the maximum number of iterations to attempt  
  ## max.distance: Maximum distance allowed for a match. 
  ## Expressed either as integer, or as a fraction of the
  ## pattern length times the maximal transformation cost
  ## (will be replaced by the smallest integer not less
  ## than the corresponding fraction), or a list with
  ## possible components 
  ## ... : other optional arguments to supply agrep()
  ## Note: future improvement should use a truely recursive form
  ## that will not suffer from dropping all matches when the 
  ## incr argument is too large
  out = agrep(pattern, x, ...)
  iter = 1
  while (length(out) == 0) {
    max.distance = max.distance + incr
    iter = iter + 1
    out = agrep(pattern, x, max.distance, ...)
    if (iter == max.iter) break
  }
  while (length(out) > 1) {
    max.distance = max.distance - incr/2
    iter = iter + 1
    out = agrep(pattern, x, max.distance, ...)
    if (iter >= max.iter)
      return(out)
  }
  return(out)
}


is.coord = function(lon, lat){
    ##this function gives TRUE/FALSE if data appears to be a lat/long coordinate
    ##this classification is defined using very simple rules
    ##Arguments
    #lon: longitude of sample points of interest
    #lat: latitude of sample points of interest
    ##Output
    #a logical vector
    ##note here that -180 to 180 is defined as ok b/c some rows have lat/long switched
    lon = as.numeric(lon)
    lat = as.numeric(lat) 
    is.lon = lon >= -180 & lon <= 180 & lon != 0
    is.lat = lat >= -180 & lat <= 180 & lat != 0
    good = (is.lat + is.lon) == 2
    good = ifelse(is.na(good), FALSE, good)
    return(good)
}

highres_coords = function(lon, lat, min_digits = 2) {
    ## Determine if decimal longitude and latitude are high enough 
    ## resolution given a minimum number of digits
    ## arguments
    # lon: longitude in decimal degrees
    # lat: latitude in decimal degrees
    # min_digits: the minimum number of digits that lon and lat must have
    lon = as.numeric(lon)
    lat = as.numeric(lat)
    lon_res = sapply(lon %% 1, nchar) - 2
    lat_res = sapply(lat %% 1, nchar) - 2
    return(lon_res >= min_digits & lat_res >= min_digits)
}

onGrid = function(lon, lat, grid, poly){
 ##Purpose: to examine if the coordinates specified 
 ##fall either on the grid dataset or within the poly dataset
 ##the function returns a logical (TRUE = on / FALSE = off)
 ##Arguments:
 #lon: longitude of sample points of interest
 #lat: latitude of sample points of interest
 #grid: a raster object that has the same coordinate system as pts, and NA's where there is ocean
 #poly: a SpatialPolygon object that has the same coordinate system as pts
 ##Output:
 require(raster)
 require(sp)
 lon = as.numeric(lon)
 lat = as.numeric(lat)
 pts = SpatialPoints(cbind(lon,lat))
 if(!missing(grid)){
  on.grid = !is.na(extract(grid,pts,'simple'))
  on = on.grid
 }
 if(!missing(poly)){
  on.poly = !is.na(overlay(pts,poly))
  on = on.poly
 }
 if(!missing(grid)&!missing(poly)){
  on =  (on.grid + on.poly) > 0
 }
 on
} 

notGBIFhq = function(lon, lat, cutoff=0.01) {
    ## Purpose: this function returns FALSE if 
    ## the GBIF coordinate occurs within a distance cutoff in miles 
    ## proximate to Copenhagen, Denmark, the GBIF headquaters
    ## Arguments:
    #lon: longitude of sample points of interest
    #lat: latitude of sample points of interest
    #cutoff: the minimium allowable proximity to Cophenhagen, Denmark in km
    require(sp)
    lon = as.numeric(lon)
    lat = as.numeric(lat) 
    dists = spDistsN1(pts = cbind(lon,lat), pt=cbind(12.59,55.68))
    filter = dists > cutoff
    return(filter)
}

notCentroid = function(centroids, point, cutoff=0.01) {
    ## Purpose: this function returns FALSE if 
    ## the GBIF coordinate occurs within a distance cutoff in miles 
    ## proximate to Copenhagen, Denmark, the GBIF headquaters
    ## Arguments:
    #lon: longitude of sample points of interest
    #lat: latitude of sample points of interest
    #cutoff: the minimium allowable proximity to Cophenhagen, Denmark in km
    require(sp)
    dists = spDistsN1(pts = centroids, pt = point)
    filter = any(dists > cutoff)
    return(filter)
}


define_lat_hemi = function(lat_lo, lat_hi) {
  ## Categorize if a species occurs primarily in the Northern (N), Southern (S),
  ## or Both (B) hemisphers using a 95% quantile of the species latitudes
  ## returns:
  ## a vector of strings, 'N' for northern, 'S' for southern, and 'B' for both.
  hemi = rep(NA,length(lat_lo))
  for (i in seq_along(lat_lo)) {
    if (lat_lo[i] < 0 & lat_hi[i] < 0) 
      hemi[i] = 'S'
    else if (lat_lo[i] > 0 & lat_hi[i] > 0)     
      hemi[i] = 'N'
    else 
      hemi[i] = 'B'
  }  
  return(hemi)
}

define_long_hemi = function(long_lo, long_hi) {
  ## Categorize if a species occurs primarily in the Eastern (E), Western (W),
  ## or Both (B) hemisphers using a 95% quantile of the species latitudes
  ## returns:
  ## a vector of strings, 'E' for eastern, 'W' for western, and 'B' for both.
  hemi = rep(NA,length(long_lo))
  for (i in seq_along(long_lo)) {
    if (long_lo[i] < 0 & long_hi[i] < 0) 
      hemi[i] = 'W'
    else if (long_lo[i] > 0 & long_hi[i] > 0)     
      hemi[i] = 'E'
    else 
      hemi[i] = 'B'
  }  
  return(hemi)
}

calc_hemi_quantile = function(lat) { 
  north_lat = lat[lat > 0]
  south_lat = lat[lat < 0]
  north_quant = c(quantile(north_lat, c(0.025, 0.975)), length(north_lat))
  south_quant = c(quantile(south_lat, c(0.025, 0.975)), length(south_lat))
  out = c(north_quant, south_quant)
  return(out)
}

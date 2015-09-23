## functions modified from Will Cornwell 09/01/15 for processing Wise soil data
## http://www.isric.org/data/isric-wise-global-data-set-derived-soil-properties-05-05-degree-grid-ver-30

add.soil.data<-function(SITE=SITE){
  require(raster)
  require(nlme)
  require(foreign)
  i.soil<-raster("../gis/global_gridded_soil/wise5by5min_v1b_0/rastert_wise5by1.txt") # map input
  SITE$SUID<-extract.t(SITE,i.soil,island.buffer=FALSE,bilinear=FALSE)
  i.dbf<-read.dbf("../gis/global_gridded_soil/wise5by5min_v1b_0/DBF/WISEsummaryFile_T1S1D1.DBF")
  SITE <- merge(SITE,i.dbf,by='SUID',all.x=TRUE)
  SITE$Site.ID<-paste0(SITE$Long,SITE$Lat)
  row.names(SITE)<-NULL
  return(SITE)
}  #No soils data from Antarctica or Maq Island


#tries to save points that just fall in the ocean or on small islands
extract.t<-function(SITE,r,island.buffer=TRUE,bilinear=TRUE,max.i=10){
  if (bilinear==TRUE)
    clim.var<-extract(r,cbind(SITE$Long,SITE$Lat),method="bilinear")
  if (bilinear==FALSE) clim.var<-extract(r,cbind(SITE$Long,SITE$Lat))
  if  (island.buffer==FALSE) 
    return(clim.var)
  for (i in 1:max.i){
    prob<-which(is.na(clim.var))
    if (length(prob)==0) 
      return(clim.var)
    clim.var[prob]<-extract(r,cbind(SITE$Long[prob],SITE$Lat[prob]),buffer=i*10^4,
                            fun=function(x)median(ifelse(x < 0, NA, x),na.rm=TRUE))
  }
  return(clim.var)
}

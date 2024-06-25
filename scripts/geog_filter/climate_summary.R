## Part VI - Compute Averages and Variances
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Description: 
## for each genus import all files that apply to that genus from the genus_sort
## directory compute means and variances of the bioclim, alt, and ndiv variables
## on a per species basis for that genus
## compute the primary biome and ecosystem based upon which count is the 
## highest on a per species basis
## Output a serate summary file for each genus to the 'genus_results' directory

library(readr)
library(foreach)
library(doSNOW) 
library(snowfall)

dat = read_csv('./data/gbif_all_remote_data_2022-10-05.csv')

# cover negative values from the wise soil data to NAs
dat$TOTN = ifelse(dat$TOTN < 0, NA, dat$TOTN)
dat$TAWC = ifelse(dat$TAWC < 0, NA, dat$TAWC)

spNames = dat$canonical_name
spList = sort(unique(spNames))

## now compute n, means and variances
colnames = c("decimalLatitude", "decimalLongitude", "year", 
             "mat", "mdr", "iso", "tseas", "tmax", "tmin", "tar",
             "twetq", "tdryq", "twarmq", "tcoldq", "ap",
             "pwet", "pdry", "pseas", "pwetq", "pdryq", 
             "pwarmq", "pcoldq", "alt", "ndviAvg", "Total.P",
             "Labile.Inorganic.P", "organic.P", "TOTN", "TAWC")
datSub = dat[ , colnames]
ns = tapply(dat$mat, spNames, function(x) sum(!is.na(x)))

sfInit(parallel=TRUE, cpus=24, type="SOCK")
sfExport("spNames", "spList")
registerDoSNOW(sfGetCluster())

quant = sfApply(datSub, 2, function(x) {
                aggregate(x, by = list(spNames), quantile,c(.025,.5,.975), na.rm=TRUE) })
sfExport("quant")
quantList = sfSapply(1:ncol(datSub),function(x) matrix(unlist(quant[[x]][2]),
                                                       nrow=length(spList),ncol=3),simplify=FALSE) 
sfStop()

quantMatrix = matrix(unlist(quantList),nrow=length(spList),ncol=ncol(datSub)*3)
## output climate 
climFileHeader = c('canonical_name', 'count', paste(rep(names(datSub),each=3),
                                              c('.lo','.me','.hi'),sep=''))
climOut = data.frame(spList, ns, quantMatrix)
names(climOut) = climFileHeader
write_csv(climOut, path='./data/gbif_climate_summary.csv')

print('summary complete')

# Code by Will Cornwell
# Emailed 2014-03-27

#
# BELOW HERE FOR ONE-TIME USE ONLY
# FINDING MIS-SPELLINGS
#

agrep.for.names<-function(good.names,bad.name,max.distance=0.07){
  fix<-good.names[agrep(bad.name,unique(good.names),max.distance=max.distance)]
  if (length(fix>0)&length(fix)<5){
    print(paste("bad name:",sub("_"," ",bad.name)))
    print("fixes:")
    print(sub("_"," ",fix))
    out.df<-data.frame(good=fix,bad=bad.name)
    return(out.df)
  }
}
# 

agrep.for.species.within.genera<-function(good.names,bad.names,max.distance=0.07){
  good.genera<-sapply(as.character(good.names),FUN=function(x) strsplit(x,"_")[[1]][1])
  bad.genera<-sapply(as.character(bad.names),FUN=function(x) strsplit(x,"_")[[1]][1])
  findable.bad.names<-bad.names[bad.genera%in%good.genera]
  bad.genera<-sapply(as.character(findable.bad.names),FUN=function(x) strsplit(x,"_")[[1]][1])
  list.out<-vector("list", length(findable.bad.names))
  for (i in 1:length(findable.bad.names)){
    poss.species<-good.names[bad.genera[i]==good.genera]
    list.out[[i]]<-agrep.for.names(unique(poss.species),findable.bad.names[i],max.distance=max.distance)
  }
  return(list.out)
}






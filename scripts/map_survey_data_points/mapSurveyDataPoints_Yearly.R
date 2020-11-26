####################################
# Script to produce a sequence of maps of Ethiopia with rust disease status at point survey locations
# -> produces 1 map with all point surveys per time-interval (year) for each type of wheat rust and both disease scores (severity and incidence)
#
# @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
#
# Summary script-structure:
#  import libs, define paths, etc.
#  for all three types of wheat rust (Sr,Yr,Lr)
#    for all years (2010-2019)
#       map Ethiopia admin boundaries, wheat areas and disease incidence as point surveys 
#       map Ethiopia admin boundaries, wheat areas and disease severity as point surveys
####################################


# clear workspace
rm(list = ls())

# import libs
library(readxl)
library(dplyr)
library(rgdal)
library(tmap) 
library(maptools)
library(ggplot2)
library(raster)
library(grid)
library(RColorBrewer)
library(sf)
library(spatialEco)
library(spdep)

# set global options
options(stringsAsFactors = FALSE)

# define path to project folder
ProjectFolderPath<-'C:\\Users\\marce\\Desktop\\FilesMM\\Ethiopia_WheatRustDataRevival\\wheat_rusts_Ethiopia'

## load data-input for maps 

# shapefiles with admin units of: world, ET admin, wheat 
WorldAdminUnitsAll<-readOGR(dsn=paste0(ProjectFolderPath,"/AuxiliaryData/World_Admin_Reduced"),layer="Export_Output")

# ET admin boundaries
ETAdminUnits0<-readOGR(dsn = paste0(ProjectFolderPath,"/AuxiliaryData/Ethiopia_Admin"), layer = "gadm36_ETH_0")
ETAdminUnitsRegions<-readOGR(dsn = paste0(ProjectFolderPath,"/AuxiliaryData/Ethiopia_Admin"), layer = "gadm36_ETH_1")
ETAdminUnitsZones<-readOGR(dsn = paste0(ProjectFolderPath,"/AuxiliaryData/Ethiopia_Admin"), layer = "gadm36_ETH_2")
ETAdminUnitsDistricts<-readOGR(dsn = paste0(ProjectFolderPath,"/AuxiliaryData/Ethiopia_Admin"), layer = "gadm36_ETH_3")

# ET wheat areas
ETWheat<-raster(paste0(ProjectFolderPath,"/AuxiliaryData/Wheat_Growing_Areas/WheatEthiopiaMapSpam.tif"))
ETWheatFlat<-ETWheat
ETWheatFlat[ETWheatFlat>0]<-1
ETWheatFlat[ETWheatFlat==0]<-NA

# get projection from shapefile with admin boundaries
ProjAdmin<-crs(ETAdminUnitsDistricts)

# define types of rust and time-intervals for mapping 
AllRusts<-c("WheatStemRust","WheatYellowRust","WheatLeafRust")
AllRustAbbr<-c("Sr","Yr","Lr")
AllYears<-c("2010","2011","2012","2013","2014","2015","2016","2017","2018","2019")

# loop all wheat rusts
for (iWR in 1:length(AllRusts)){
  iWheatRust=AllRusts[iWR]
  iRust=AllRustAbbr[iWR]
  
  # def. output folder
  PlotFolder=paste0(ProjectFolderPath,'\\Results\\SurveyDataMaps\\',iRust)
  if (!file.exists(PlotFolder)){dir.create(PlotFolder)}
  
  # loop all years
  for (iY in 1:length(AllYears)){
    iYear=AllYears[iY]
    
    # load wheat rust survey data per rust per time-interval
    iYearlySurveyData<-paste0(ProjectFolderPath,'\\Results\\CSVFilesForMapping\\',iRust,'\\YearlyMeher_',iRust,'_ET_',iYear,'.csv')
    SurveyData<-read.csv(file=iYearlySurveyData, header=TRUE, sep=",")  
  
    # def. output folder
    PlotFolder=paste0(ProjectFolderPath,'\\Results\\SurveyDataMaps\\',iRust,'\\Yearly\\')
    if (!file.exists(PlotFolder)){dir.create(PlotFolder)}
    
    # get coordinates of surveys
    AllCoords=cbind(SurveyData$Longitude,SurveyData$Latitude)
    
    # get disease data at coordinates
    SurveyInfoAtCoords<-data.frame("Inc"=SurveyData[,7],
                                   "Sev"=SurveyData[,6])
    
    # construct spatial object from coordinates, data and projection
    SurveyInfoAtCoords_sp <- SpatialPointsDataFrame(AllCoords,SurveyInfoAtCoords,proj4string=ProjAdmin)
    
    # map severity (for grid plot with all years)
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp,legend=FALSE)+tm_symbols("Sev",size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),palette=c("green","yellow","orange","red"),legend.col.show = FALSE)+tm_layout(title = iYear,scale=2)+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
        tmap_save(tm, paste0(PlotFolder,'/Surveys_Sev_',iYear,iRust,'.png'),dpi = 300)
      
    # map severity with legend (for animation of all years)
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue",panel.labels=c("Ethiopia: wheat rust surveys"),panel.label.size = 1)+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Sev",title.col =paste0(iRust," severity"),size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(title = iYear,scale=2)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
        tmap_save(tm, paste0(PlotFolder,'/Surveys_SevLegend_',iYear,iRust,'.png'),dpi = 300)
    
    # map incidence (for grid plot with all years)
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp,legend=FALSE)+tm_symbols("Inc",size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),palette=c("green","yellow","orange","red"),legend.col.show = FALSE)+tm_layout(title = iYear,scale=2)+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
        tmap_save(tm, paste0(PlotFolder,'/Surveys_Inc_',iYear,iRust,'.png'),dpi = 300)

    # map incidence with legend (for animation of all years)
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue",panel.labels=c("Ethiopia: wheat rust surveys"),panel.label.size = 1)+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Inc",title.col =paste0(iRust," incidence"),size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(title = iYear,scale=2)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
        tmap_save(tm, paste0(PlotFolder,'/Surveys_IncLegend_',iYear,iRust,'.png'),dpi = 300)
      
  } # end loop years
} # end loop rusts


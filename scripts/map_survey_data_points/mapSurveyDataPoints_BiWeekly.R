####################################
# Script to produce a sequence of maps of Ethiopia with rust disease status at point survey locations 
#  -> produces 1 map for each 2-weekly time interval from 2010 to 2019
#  -> on each map: all surveys from the beginning of the wheat season until the end of the time-interval
#
# @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
#
# Summary of script-structure:
#  import libs, define paths, etc.
#  for all three types of wheat rust (Sr,Yr,Lr)
#    for all 2-weekly time-intervals from Feb. 2010 - Dec. 2019
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

# load data-input for maps; 

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

# define types of disease 
AllRusts<-c("WheatStemRust","WheatYellowRust","WheatLeafRust")
AllRustAbbr<-c("Sr","Yr","Lr")

# define start and end of time-interval
StartDate<-as.Date("2010-02-25")
EndDate<-as.Date("2020-01-02")

# loop all wheat rusts
for (iWR in 1:length(AllRusts)){
  iWheatRust=AllRusts[iWR]
  iRust=AllRustAbbr[iWR]
  
  # loop all bi-weeks
  iStartInterval<-StartDate
  iEndInterval<-StartDate+13
  
  while (iEndInterval<EndDate){
    
    # load wheat rust survey data
    iSurveyData<-paste0(ProjectFolderPath,'\\Results\\CSVFilesForMapping\\',iRust,'\\CumBiWeekly\\CumBiWeekly',as.character(iStartInterval),'_',as.character(iEndInterval),'_',iRust,'.csv')
    SurveyData<-read.csv(file=iSurveyData, header=TRUE, sep=",")  
  
    # def. output folder
    PlotFolder=paste0(ProjectFolderPath,'\\Results\\SurveyDataMaps\\',iRust,'\\BiWeekly\\')
    if (!file.exists(PlotFolder)){dir.create(PlotFolder)}
    
    # get coordinates of surveys
    AllCoords=cbind(SurveyData$Longitude,SurveyData$Latitude)

    # get disease data at coordinates
    SurveyInfoAtCoords<-data.frame("Inc"=SurveyData[,7],
                                   "Sev"=SurveyData[,6])
    
    # construct spatial object from coordinates, data and projection
    SurveyInfoAtCoords_sp <- SpatialPointsDataFrame(AllCoords,SurveyInfoAtCoords,proj4string=ProjAdmin)
    
    # map severity
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue",panel.labels=c("Ethiopia: wheat rust surveys"),panel.label.size = 1)+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Sev",title.col =paste0(iRust," severity"),size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(scale = 2,title = paste0(as.character(format(iStartInterval,'%d/%m/%Y')),' -\n  ',as.character(format(iEndInterval,'%d/%m/%Y'))),title.size = 0.8)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
        tmap_save(tm, paste0(PlotFolder,'/Surveys_Sev_',as.character(iStartInterval),'_',as.character(iEndInterval),'_',iRust,'.png'),dpi = 300)
    
    # map severity without panel and legend
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp,legend=FALSE)+
      tm_symbols("Sev",size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),palette=c("green","yellow","orange","red"),legend.col.show = FALSE)+
      tm_layout(scale = 2,title = paste0(as.character(format(iStartInterval,'%d/%m/%Y')),' -\n  ',as.character(format(iEndInterval,'%d/%m/%Y'))),title.size = 0.8)+
      #tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
    tmap_save(tm, paste0(PlotFolder,'/Surveys_SevwithoutLeg_',as.character(iStartInterval),'_',as.character(iEndInterval),'_',iRust,'.png'),dpi = 300)
    
        
    # map incidence
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue",panel.labels=c("Ethiopia: wheat rust surveys"),panel.label.size = 1)+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Inc",title.col =paste0(iRust," incidence"),size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(scale = 2,title = paste0(as.character(format(iStartInterval,'%d/%m/%Y')),' -\n  ',as.character(format(iEndInterval,'%d/%m/%Y'))),title.size = 0.8)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
        tmap_save(tm, paste0(PlotFolder,'/Surveys_Inc_',as.character(iStartInterval),'_',as.character(iEndInterval),'_',iRust,'.png'),dpi = 300)
    
    # map incidence without legend
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp,legend=FALSE)+
      tm_symbols("Inc",size=0.2,showNA=FALSE,breaks=c(0,1,2,3,4),palette=c("green","yellow","orange","red"),legend.col.show = FALSE)+
      tm_layout(scale = 2,title = paste0(as.character(format(iStartInterval,'%d/%m/%Y')),' -\n  ',as.character(format(iEndInterval,'%d/%m/%Y'))),title.size = 0.8)+
      #tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom') )
    tmap_save(tm, paste0(PlotFolder,'/Surveys_IncwithoutLeg_',as.character(iStartInterval),'_',as.character(iEndInterval),'_',iRust,'.png'),dpi = 300)
    
        
    # re-set the date of the start of the season when the end of each wheat season is reached
    # the minor/Belg season is assumed to last from mid March until July and
    # the major/Meher season is assumed to last from August until mid March (only here for mapping year-round)
    
    # get current year
    iYear<-as.character(format(iEndInterval,'%Y'))
    
    # reset if the end of the Belg season is reached
    ResetStartDateBelg=as.Date(paste0(iYear,'-02-15'));
    ResetEndDateBelg=as.Date(paste0((iYear),'-02-28'));
    if ( (ResetStartDateBelg<=iEndInterval) && (ResetEndDateBelg>=iEndInterval) ){
      iStartInterval=iEndInterval+1;  
    }
    
    # reset if the end of the Meher season is reached
    ResetStartDateMeher=as.Date(paste0(iYear,'-07-22'));
    ResetEndDateMeher=as.Date(paste0(iYear,'-08-04'));
    if ( (ResetStartDateMeher<=iEndInterval) && (ResetEndDateMeher>=iEndInterval) ){
      iStartInterval=iEndInterval+1;
    }
    
    # iterate time-interval
    iEndInterval<-iEndInterval+14

  
  } # end while loop over all 2-weekly time-intervals
} # end loop over all types of wheat rust


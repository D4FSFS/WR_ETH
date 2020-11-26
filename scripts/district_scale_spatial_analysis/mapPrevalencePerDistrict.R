####################################
# Script to aggregating point surveys per administrative district of Ethiopia for analysing: 
#     - the number of surveys per district 
#     - disease prevalences per district (i.e. number of positives per district / total number surveys per district) as indicators of the probability/risk of disease occurance in different districts
#     - spatial autocorrelation (Morans-I)
#     - Hot- and cold-spots (Getis-Ord)
#     
# -> plot maps with survey results aggregated per district (for each type of wheat rust and for severity/incidence measures)
#
# @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
#
# Summary script-structure:
#  import libs, define paths, etc.
#  function defs (e.g. colour-schemes, mapping functions, Morans-I, Getis-Ord)
#  for all three types of wheat rust (Sr,Yr,Lr)
#       get subset of surveys for years 2010-2019
#       aggregate point surveys per district and count prevalences
#       map Ethiopia admin boundaries, wheat areas and disease incidence per district 
#       map Ethiopia admin boundaries, wheat areas and disease severity per district
#       test spatial autocorrelation (Morans-I)
#       test for hot- and cold-spots (Getis-Ord)
#
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
library(latex2exp)


#######################################################
# function definitions

# function for defining the color scheme for maps showing the number of surveys per district
getColorSchemeNumberResponses<-function(AllNumberResponses){
  
  # set boundaries
  CMax=max(AllNumberResponses,na.rm=TRUE)
  CMin=1
  
  # set breaks for colorbar
  C2=10
  C3=50
  C4=100
  colorBreaks1=c(CMin,C2,C3,C4,CMax+0.5) # for closed interval 
  
  # use pre-defined color-scheme
  AllColours=brewer.pal(8,"Accent")
  AllColoursB=brewer.pal(9,"Greys")
  Colours=c(AllColoursB[3],AllColours[4],AllColours[3],AllColours[6])
  Labels=c(paste0("[",CMin," - ",C2,")"),paste0("[",C2," - ",C3,")"),paste0("[",C3," - ",C4,")"),paste0("[",C4," - ",CMax,"]"))
  
  # return relevant info for mapping
  CScheme=list(colorBreaks1,Colours,Labels)
  return(CScheme)
  
} 

# function for defining the colour-schemes for disease prevalences of different rusts
getColorSchemePropsComparison<-function(colorIndicator,iRust){
  
  # set colour breaks, pick colours and set labels
  if (colorIndicator=="Negatives"){
    
    # set boundaries
    C1=0
    C2=0.25
    C3=0.5
    C4=0.75
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(6,"Greens")  
    Colours=AllColours[3:6]
  }
 
  ## Sr - stem rust
  # low disease levels
  if ( (colorIndicator=="Low") && (iRust=="Sr") ){
    
    # set boundaries
    C1=0
    C2=0.25
    C3=0.5
    C4=0.75
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"Greys")  
    Colours=c(AllColours[3],AllColours[5],AllColours[7],AllColours[8])
  }
  # moderate disease levels
  if ((colorIndicator=="Mod") && (iRust=="Sr")){
    
    # set boundaries
    C1=0
    C2=0.05
    C3=0.1
    C4=0.15
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"Greys")  
    Colours=c(AllColours[3],AllColours[5],AllColours[7],AllColours[8])
  }
  # high disease levels
  if ((colorIndicator=="High") && (iRust=="Sr")){
    
    # set boundaries
    C1=0
    C2=0.025
    C3=0.05
    C4=0.075
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"Greys")  
    Colours=c(AllColours[3],AllColours[5],AllColours[7],AllColours[8])
  }
  
  ## Yr - yellow rust
  # low disease levels
  if ( (colorIndicator=="Low") && (iRust=="Yr") ){
    
    # set boundaries
    C1=0
    C2=0.25
    C3=0.5
    C4=0.75
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"YlOrBr")  
    Colours=AllColours[3:6]
  }
  # moderate disease levels
  if ((colorIndicator=="Mod") && (iRust=="Yr")){
    
    # set boundaries
    C1=0
    C2=0.075
    C3=0.15
    C4=0.225
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"YlOrBr")  
    Colours=AllColours[3:6]
  }
  # high disease levels
  if ((colorIndicator=="High") && (iRust=="Yr")){
    
    # set boundaries
    C1=0
    C2=0.05
    C3=0.1
    C4=0.15
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(9,"YlOrBr")  
    Colours=AllColours[3:6]
  }
  ## Lr - leaf rust
  # low disease levels
  if ( (colorIndicator=="Low") && (iRust=="Lr") ){
    
    # set boundaries
    C1=0
    C2=0.25
    C3=0.5
    C4=0.75
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(11,"BrBG") 
    Colours=c(AllColours[4],AllColours[3],AllColours[2],AllColours[1])
  }
  # moderate disease levels
  if ((colorIndicator=="Mod") && (iRust=="Lr")){
    
    # set boundaries
    C1=0
    C2=0.025
    C3=0.05
    C4=0.075
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(11,"BrBG") 
    Colours=c(AllColours[4],AllColours[3],AllColours[2],AllColours[1])
  }
  # high disease levels
  if ((colorIndicator=="High") && (iRust=="Lr")){
    
    # set boundaries
    C1=0
    C2=0.01
    C3=0.03
    C4=0.05
    C5=1
    colorBreaks1=c(C1,C2,C3,C4,C5+0.1) # for closed interval 
    
    # pick colours
    AllColours=brewer.pal(11,"BrBG") 
    Colours=c(AllColours[4],AllColours[3],AllColours[2],AllColours[1])
  }
  
  # set labels
  Labels=c(paste0("[",C1*100," - ",C2*100,")"),paste0("[",C2*100," - ",C3*100,")"),paste0("[",C3*100," - ",C4*100,")"),paste0("[",C4*100," - ",C5*100,"]"))
  
  # return relevant info for mapping
  CScheme=list(colorBreaks1,Colours,Labels)
  return(CScheme)
  
} 


# function to plot a map with survey results aggregated per district
MapSurveyDataPerDistrict<- function(colNamePlotVariable,LegTitleStr,ColourScheme,MapFileName){
  
  tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+
    tm_borders(lw=0.5)+tm_fill(col="white")+
    tm_layout(bg.color = "lightblue")+
    tm_shape(ETAdminUnitsDistricts)+
    tm_borders(lwd=0.4)+
    tm_polygons(colNamePlotVariable,fill.style="fixed",breaks=ColourScheme[[1]],palette=ColourScheme[[2]],label=ColourScheme[[3]],title=paste0(LegTitleStr),colorNA=NULL,lwd=0.4,border.col="black",border.alpha = 1)+
    tm_layout(scale = 2)+
    tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
    tm_shape(ETAdminUnitsRegions)+tm_borders(lwd=1.5)+
    tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
    tm_compass(size = 2,position = c('left','bottom'))+
    tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
  tmap_save(tm, MapFileName, dpi = 300)  
  
}

# function to write global MoransI test results to file
WriteMoransITestToFile <- function(iRust,GlobalMoransI_B,DistrDisStr,OutFileHandle){
  cat("\n\n type of Rust: ",iRust,file=OutFileHandle)
  cat("\n data: ",DistrDisStr,file=OutFileHandle)
  cat("\n method: ",GlobalMoransI_B$method,file=OutFileHandle)
  cat("\n moran.test estimates (MoransI statistic, Expectation, Variance): ",GlobalMoransI_B$estimate,file=OutFileHandle)
  cat("\n p-value: ",GlobalMoransI_B$p.value,file=OutFileHandle)
  cat("\n alternative hypothesis: ",GlobalMoransI_B$alternative,file=OutFileHandle)
}

# function to calculate global MoransI for testing spatial autocorrelation
CalculateGlobalMoransIAndWriteToFile <- function(ETAdminUnitsDistricts,DistrictDiseaseMeasures,DistrDisStr,OutFileHandle){
  
  # get a neighbours list for all districts
  DistrictList=poly2nb(ETAdminUnitsDistricts, queen = T) 
  
  # set weights of neighbours - choose a simply binary weight (style='B') 
  W_cont_el_mat_B <- nb2listw(DistrictList,style = "B",zero.policy = TRUE) 
  # tested different styles of weighting for one case: only minor differences; stick to simplest case 
  
  # calc global Morans I 
  GlobalMoransI_B=moran.test(DistrictDiseaseMeasures,listw = W_cont_el_mat_B,zero.policy = T,na.action=na.exclude)
  # see: https://cran.r-project.org/web/packages/spdep/spdep.pdf
  
  # write to file
  WriteMoransITestToFile(iRust,GlobalMoransI_B,DistrDisStr,OutFileHandle)
  
}

# function for calculating and mapping Hot- and Cold-Spots (based on Local G - Getis statistic)
CalcAndMapHotSpotsLocalG <- function(iRust,ETAdminUnitsDistrictsReduced,DiseaseDataObject,DisMeasureStr,LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName){
  
  # compute nearest neighbours based on geographic distance
  DistrNB<-dnearneigh(coordinates(ETAdminUnitsDistrictsReduced),LowerDistanceNeighbours,UpperDistanceNeighbours)
  
  # compute weights for neighbours; use simple binary weighting
  DistrNB_LW<-nb2listw(include.self(DistrNB),zero.policy=TRUE,style="B")
  
  # compute local G statistic - returning a z-score for each polygon (admin. district)
  local_g<-localG(DiseaseDataObject,DistrNB_LW,zero.policy=TRUE)
  
  # bind the G statistic/z-score to the polygon data object for mapping
  ETAdminUnitsDistrictsReduced@data$gstat<-rep(NA,nrow(ETAdminUnitsDistrictsReduced@data))
  ETAdminUnitsDistrictsReduced@data$gstat<-local_g 
  
  # R t_map appears not to be able to deal with neg and pos values of zscores. 
  # Hence the following work-around: add an integer to ensure all values are positive and then adjust the 
  # labels in the map accordingly. 
  PosShift<-50
  ETAdminUnitsDistrictsReduced@data$gstat<-ETAdminUnitsDistrictsReduced@data$gstat+PosShift
  
  # define colors
  AllColours=brewer.pal(7,"RdYlBu") 
  Colours=rev(AllColours) 
 
  # map 
  tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+
    tm_layout(bg.color = "lightblue")+
    tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
    tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
    tm_shape(ETAdminUnitsDistrictsReduced)+
    tm_fill("gstat",
            breaks = c(-100,(-2.58+PosShift),(-1.96+PosShift),(-1.65+PosShift),(1.65+PosShift),(1.96+PosShift),(2.58+PosShift),100),
            labels = c("< -2.56","[ - 2.56, - 1.96)","[ - 1.96, - 1.65)","[ - 1.65, +1.65)","[ +1.65, +1.96)","[ +1.96, +2.56)","> +2.56"),
            palette=Colours, title = 'Gi* z-score')+
    tm_shape(ETAdminUnitsRegions)+tm_borders(lwd=1.5)+
    tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
    tm_layout(scale = 2,title =paste0(iRust,' positives\n(',DisMeasureStr,')'),title.size = 0.65)+
    tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
    tm_compass(size = 2,position = c('left','bottom'))+
    tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
  tmap_save(tm,MapFileName,dpi = 300)

  # see: https://cran.r-project.org/web/packages/spdep/spdep.pdf#Rfn.localG

}  

### end function defs


#################################################################
### start script instructions

# define path to project folder
ProjectFolderPath<-'C:/Users/marce/Desktop/FilesMM/Ethiopia_WheatRustDataRevival/wheat_rusts_Ethiopia'

# define output folder
PlotFolder=paste0(ProjectFolderPath,'/Results/DistrictScaleAnalysis/')
if (!file.exists(PlotFolder)){dir.create(PlotFolder)}

## load data-input for maps 

# shape-files with admin units of: world, ET admin, wheat 
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

# define types of disease and time-intervals for mapping 
AllRusts<-c("WheatStemRust","WheatYellowRust","WheatLeafRust")
AllRustAbbr<-c("Sr","Yr","Lr")

# loop all wheat rusts
for (iWR in 1:length(AllRusts)){
  iWheatRust=AllRusts[iWR]
  iRust=AllRustAbbr[iWR]

  # load wheat rust survey data
  iSurveyDataFileName<-paste0(ProjectFolderPath,'/SurveyData_Cleaned/CleanSurveyDataNumeric_ET_',iWheatRust,'.csv')
  iSurveyData<-read.csv(file=iSurveyDataFileName, header=TRUE, sep=",")  

  # def. output folder
  PlotFolderWR=paste0(PlotFolder,'/',iRust,'/')
  if (!file.exists(PlotFolderWR)){dir.create(PlotFolderWR)}

  # get subset of survey data: years 2010-2019, months 8-12, which are the relevant entries for this analysis
  # initialize empty dataframe and counter for storing subset of data
  iSurveyDataMeher<-data.frame(Year=integer(),
                               Month=integer(),
                               Day=integer(),
                               Latitude=double(),
                               Longitude=double(),
                               RustSeverity=integer(),
                               RustIncidence=integer())
  i<-0
  
  # loop all surveys and get subset with relevant years and months
  for (iEntry in 1:nrow(iSurveyData)){
    iYear<-iSurveyData[iEntry,1]
    iMonth<-iSurveyData[iEntry,2]
    if ( (iYear>=2010 && iYear <=2019) && (iMonth>=8 && iMonth<=12) ){
      i=i+1
      iSurveyDataMeher[i,]<-iSurveyData[iEntry,] 
    }
  }
  
  # print total number of surveys
  nrow(iSurveyData)
  nrow(iSurveyDataMeher)
  
  # get coordinates of surveys
  AllCoords=cbind(iSurveyDataMeher$Longitude,iSurveyDataMeher$Latitude)
  
  # get disease data at coordinates
  SurveyInfoAtCoords<-data.frame("Inc"=iSurveyDataMeher[,7],
                                 "Sev"=iSurveyDataMeher[,6])
  
  # construct spatial object from coordinates, data and projection
  SurveyInfoAtCoords_sp <- SpatialPointsDataFrame(AllCoords,SurveyInfoAtCoords,proj4string=ProjAdmin)
  
  # plot all surveys in 1 map
  # map severity
  MapFileName<-paste0(PlotFolderWR,'/AllSurveys_Sev_',iRust,'.png')
  if (!file.exists(MapFileName)){
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+
      tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnitsRegions)+tm_borders(lwd=1.5)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Sev",title.col =paste0(iRust," severity"),size=0.1,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(scale = 2,title = 'All surveys \n 2010 - 2019',title.size = 0.8)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
    tmap_save(tm,MapFileName,dpi = 500)
  }
  
  # map incidence
  MapFileName<-paste0(PlotFolderWR,'/AllSurveys_Inc_',iRust,'.png')
  if (!file.exists(MapFileName)){
    tm<-tm_shape(WorldAdminUnitsAll,projection=ProjAdmin,ylim=c(3,15),xlim=c(33,44.5))+tm_borders(lw=0.5)+tm_fill(col="white")+
      tm_layout(bg.color = "lightblue")+
      tm_shape(ETWheatFlat,projection=ProjAdmin)+tm_raster(breaks=c(0.1,1),palette=c("gray"),alpha=0.7,legend.show=FALSE)+
      tm_shape(ETAdminUnitsDistricts)+tm_borders(lwd=0.4)+
      tm_shape(ETAdminUnitsRegions)+tm_borders(lwd=1.5)+
      tm_shape(ETAdminUnits0,projection=ProjAdmin)+tm_borders(lw=3)+
      tm_shape(SurveyInfoAtCoords_sp)+tm_symbols("Inc",title.col =paste0(iRust," incidence"),size=0.1,showNA=FALSE,breaks=c(0,1,2,3,4),labels = c("none","low","medium","high"),palette=c("green","yellow","orange","red"))+tm_layout(scale = 2,title = 'All surveys \n 2010 - 2019',title.size = 0.8)+tm_legend(text.size=0.7,title.size=1,bg.color="white",frame="gray50",position=c("right","top"))+
      tm_compass(size = 2,position = c('left','bottom'))+
      tm_scale_bar(width=0.2,breaks = c(0,100,200,300),position =c('left','bottom'))
    tmap_save(tm,MapFileName,dpi = 500)
  }
  
  ## aggregate number of surveys and prevalence measures per district and map
  
  # find the name of the district in which each survey was conducted and write this name as additional column into the data-frame
  AllPolygonNames=over(SurveyInfoAtCoords_sp,ETAdminUnitsDistricts)
  SurveyInfoAtCoords$DistrictOfSurvey=AllPolygonNames$NAME_3
  # as the district names in the ET admin data are not unique, we also need the zones for unique identification
  SurveyInfoAtCoords$ZoneOfSurvey=AllPolygonNames$NAME_2
  
  # aggregate point survey data to districts
  # initialize additional NA columns to EtAdmin district shp for storing survey information
  ETAdminUnitsDistricts@data$TotNumSurveysPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data)) 
  ETAdminUnitsDistricts@data$SevPropNegativesPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  ETAdminUnitsDistricts@data$SevPropLowRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data)) 
  ETAdminUnitsDistricts@data$SevPropModRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  ETAdminUnitsDistricts@data$SevPropHighRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  ETAdminUnitsDistricts@data$IncPropNegativesPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  ETAdminUnitsDistricts@data$IncPropLowRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data)) 
  ETAdminUnitsDistricts@data$IncPropModRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  ETAdminUnitsDistricts@data$IncPropHighRustPerDistrict<-rep(NA,nrow(ETAdminUnitsDistricts@data))
  
  # loop all districts of Admin data and subset all point surveys in that district
  for (iD in 1:length(ETAdminUnitsDistricts@data$NAME_3) ){
    
    # get name and zone of this district 
    iDistrict=as.character(ETAdminUnitsDistricts@data$NAME_3[iD])
    iZone=as.character(ETAdminUnitsDistricts@data$NAME_2[iD])
    
    # subset all survey points in this district 
    iSurveysPerDistrict=subset(SurveyInfoAtCoords,DistrictOfSurvey==iDistrict & ZoneOfSurvey==iZone)
    
    # if there are any surveys per district: count prevalence
    if (nrow(iSurveysPerDistrict)>=1){
      
      # get total number of surveys per district
      ETAdminUnitsDistricts@data$TotNumSurveysPerDistrict[iD]<-nrow(iSurveysPerDistrict)
      
      # get prevalence of severity scores 
      iNumNegatives<-sum(iSurveysPerDistrict$Sev==0,na.rm=TRUE)
      iNumLow<-sum(iSurveysPerDistrict$Sev==1,na.rm=TRUE)
      iNumMod<-sum(iSurveysPerDistrict$Sev==2,na.rm=TRUE)
      iNumHigh<-sum(iSurveysPerDistrict$Sev==3,na.rm=TRUE)
      ETAdminUnitsDistricts@data$SevPropNegativesPerDistrict[iD]<-iNumNegatives/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$SevPropLowRustPerDistrict[iD]<-(iNumLow+iNumMod+iNumHigh)/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$SevPropModRustPerDistrict[iD]<-(iNumMod+iNumHigh)/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$SevPropHighRustPerDistrict[iD]<-iNumHigh/nrow(iSurveysPerDistrict)
     
      # get prevalence of incidence scores
      iNumNegatives<-sum(iSurveysPerDistrict$Inc==0,na.rm=TRUE)
      iNumLow<-sum(iSurveysPerDistrict$Inc==1,na.rm=TRUE)
      iNumMod<-sum(iSurveysPerDistrict$Inc==2,na.rm=TRUE)
      iNumHigh<-sum(iSurveysPerDistrict$Inc==3,na.rm=TRUE)
      ETAdminUnitsDistricts@data$IncPropNegativesPerDistrict[iD]<-iNumNegatives/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$IncPropLowRustPerDistrict[iD]<-(iNumLow+iNumMod+iNumHigh)/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$IncPropModRustPerDistrict[iD]<-(iNumMod+iNumHigh)/nrow(iSurveysPerDistrict)
      ETAdminUnitsDistricts@data$IncPropHighRustPerDistrict[iD]<-(iNumHigh)/nrow(iSurveysPerDistrict)
      
    } # end conditional ensuring non-zero numbers of surveys per district
  } # end loop over all districts of ET
  
  # map numbers of surveys per district and district level prevalences
 
  # Map number of surveys per district
  MapFileName<-paste0(PlotFolderWR,"/NumberOfSurveysPerDistrict_",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemeNumberResponses(ETAdminUnitsDistricts@data$TotNumSurveysPerDistrict)
    MapSurveyDataPerDistrict("TotNumSurveysPerDistrict","Number of surveys",ColourScheme,MapFileName)
  }
  
 
  ##################################################################
  # map the proportion of negatives and positives 
  
  # map the proportion of negatives per district
  MapFileName<-paste0(PlotFolderWR,"/PropNegativesPerDistrict_",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("Negatives",iRust)
    MapSurveyDataPerDistrict("SevPropNegativesPerDistrict",paste0(iRust," negatives [%]"),ColourScheme,MapFileName)
  }
  
  #############  SEVERITY #################################
  # Map proportion of positives (low+mod+high severity) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesSevLowPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("Low",iRust)
    MapSurveyDataPerDistrict("SevPropLowRustPerDistrict",paste0(iRust," positives [%] \n (>=low severity)"),ColourScheme,MapFileName)
  }
  
  # Map proportion of positives (mod+high severity) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesSevModPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("Mod",iRust)
    MapSurveyDataPerDistrict("SevPropModRustPerDistrict",paste0(iRust," positives [%] \n (>=mod severity)"),ColourScheme,MapFileName)
  }
  
  # Map proportion of positives (high severity) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesSevHighPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("High",iRust)
    MapSurveyDataPerDistrict("SevPropHighRustPerDistrict",paste0(iRust," positives [%] \n (high severity)"),ColourScheme,MapFileName)
  }
  
  ########### INCIDENCE ##################################
  # Map proportion of positives (low+mod+high incidence) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesIncLowPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("Low",iRust)
    MapSurveyDataPerDistrict("IncPropLowRustPerDistrict",paste0(iRust," positives [%] \n (>=low incidence)"),ColourScheme,MapFileName)
  }
  
  # Map proportion of positives (mod+high severity) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesIncModPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("Mod",iRust)
    MapSurveyDataPerDistrict("IncPropModRustPerDistrict",paste0(iRust," positives [%] \n (>=mod incidence)"),ColourScheme,MapFileName)
  }
  
  # Map proportion of positives (high severity) per district for comparison plot
  MapFileName<-paste0(PlotFolderWR,"/PropPositivesIncHighPerDistrict_comp",iRust,".png")
  if (!file.exists(MapFileName)){
    ColourScheme<-getColorSchemePropsComparison("High",iRust)
    MapSurveyDataPerDistrict("IncPropHighRustPerDistrict",paste0(iRust," positives [%] \n (high incidence)"),ColourScheme,MapFileName)
  }
  
  
  ##############################################################
  # Test spatial autocorrelation by calculating global Morans-I 
  
  # open file for writing summary of tests
  OutFileName<-paste0(PlotFolderWR,'/GlobalMoransI_Summary.txt')
  OutFileHandle <- file(OutFileName, "w")
  cat("Global MoransI test\n", file=OutFileHandle)
  
  # calculate global Morans-I for all disease measures (sev, inc; low, mod, high) and write to file
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$SevPropLowRustPerDistrict,"SevPropLowRustPerDistrict",OutFileHandle)
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$SevPropModRustPerDistrict,"SevPropModRustPerDistrict",OutFileHandle)
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$SevPropHighRustPerDistrict,"SevPropHighRustPerDistrict",OutFileHandle)
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$IncPropLowRustPerDistrict,"IncPropLowRustPerDistrict",OutFileHandle)
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$IncPropModRustPerDistrict,"IncPropModRustPerDistrict",OutFileHandle)
  CalculateGlobalMoransIAndWriteToFile(ETAdminUnitsDistricts,ETAdminUnitsDistricts@data$IncPropHighRustPerDistrict,"IncPropHighRustPerDistrict",OutFileHandle)
  
  #close file
  close(OutFileHandle)
  
  ###############################################################
  # conduct hot-spot analysis, i.e. calculate local Getis-Ord Geary statistic
  
  # define distance interval determining which neighbouring districts are considered
  LowerDistanceNeighbours<-0
  UpperDistanceNeighbours<-1 # in units: decimal degrees - as the spatial object with districts
  
  # calc. and map hot-spots for each disease measure (sev, inc; low, mod, high)
  
  # low severity
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_lowsev_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$SevPropLowRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$SevPropLowRustPerDistrict,">=low severity",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
  # moderate severity
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_modsev_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$SevPropModRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$SevPropModRustPerDistrict,">=mod severity",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
  # high severity
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_highsev_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$SevPropHighRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$SevPropHighRustPerDistrict,"high severity",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
  # low incidence
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_lowinc_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$IncPropLowRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$IncPropLowRustPerDistrict,">=low incidence",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
  # moderate incidence
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_modinc_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$IncPropModRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$IncPropModRustPerDistrict,">=mod incidence",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
  # high incidence
  MapFileName<-paste0(PlotFolderWR,'/HotSpots_',iRust,'_highinc_',UpperDistanceNeighbours,'.png')
  if (!file.exists(MapFileName)){
    # get a spatial object containing only those districts with data entries (ignore NAs)
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistricts
    ETAdminUnitsDistrictsReduced<-ETAdminUnitsDistrictsReduced[!is.na(ETAdminUnitsDistrictsReduced$IncPropHighRustPerDistrict),]
    # calc and map hot-spots
    CalcAndMapHotSpotsLocalG(iRust,ETAdminUnitsDistrictsReduced,ETAdminUnitsDistrictsReduced$IncPropHighRustPerDistrict,"high incidence",LowerDistanceNeighbours,UpperDistanceNeighbours,MapFileName)
  }
  
} # end loop over all rusts


% script to analyze and plot associations between latitude/longitude and
% wheat rust disease prevalence in Ethiopia. Aim: check for directional
% trends, as e.g. north-south gradient in disease prevalence
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
%
% summary:
% for each type of wheat rust
%   read the cleaned survey data 
%   for each wheat season in Ethiopia (main, minor)
%       for each disease measure (incidence, severity)
%          count and plot prevalence per latitude / longitude bin 
%          check for simple linear trend

% clear workspace
clear all;
close all;

% def. paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\LatLongCorrelations\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% loop all three types of wheat rusts 
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
for iR=1:length(AllRusts)
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create directory for plotting
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanFieldDiseaseSurveyData=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readtable(CleanFieldDiseaseSurveyData);
    
    % convert to a numeric array
    SurveyDataEthiopiaReducedNumeric = convertFromTableToNumericDataArray(DataArrayAll);
        
    % check extremes of Lat/Lon for defining the lat/lon bins   
    MaxLat=max(SurveyDataEthiopiaReducedNumeric(:,4));  
    MinLat=min(SurveyDataEthiopiaReducedNumeric(:,4)); 
    MaxLong=max(SurveyDataEthiopiaReducedNumeric(:,5)); 
    MinLong=min(SurveyDataEthiopiaReducedNumeric(:,5)); 
    
    % define arrays with lat-lon bin boundaries covering all key wheat producing areas in ET
    LatitudeBinArray=[5.5:1:14.5];
    LongBinArray=[34.5:1:43.5];
     
    % define rust-specific color for figures
    colorsBarChart = defineColorsForDifferentRusts(iRustStr);  
    
    % consider separately the two wheat seasons in Ethiopia
    % main/Meher season
    iSurveyDataMeher=[];
    count=0;
    for iS=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
        iYear=SurveyDataEthiopiaReducedNumeric(iS,1);
        iMonth=SurveyDataEthiopiaReducedNumeric(iS,2);
        if (iYear>=2010 && iYear<=2019) && (iMonth>=8 && iMonth<=12)
            count=count+1;
            iSurveyDataMeher(count,:)=SurveyDataEthiopiaReducedNumeric(iS,:);
        end
    end
   
    % minor/Belg season
    iSurveyDataBelg=[];
    count=0;
    for iS=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
        iYear=SurveyDataEthiopiaReducedNumeric(iS,1);
        iMonth=SurveyDataEthiopiaReducedNumeric(iS,2);
        if (iYear>=2010 && iYear<=2019) && (iMonth>=3 && iMonth<=7)
            count=count+1;
            iSurveyDataBelg(count,:)=SurveyDataEthiopiaReducedNumeric(iS,:);
        end
    end

    % for Meher and Belg season
    AllWheatSeasons={'Belg','Meher'};
    for iS=1:length(AllWheatSeasons(1,:))
        iSeason=AllWheatSeasons{iS};
        SurveyDataArray=[];
        if strcmp(iSeason,'Belg')
            SurveyDataArray=iSurveyDataBelg;
        elseif strcmp(iSeason,'Meher')
            SurveyDataArray=iSurveyDataMeher;
        end
        
        % loop disease scores (for separate analysis of severity and incidence scores)
        DiseaseMeasure={'Sev','Inc'};
        DisStrLegend={'severity','incidence'};
        for iD=1:length(DiseaseMeasure)
            iDiseaseStr=DiseaseMeasure{iD};
            iDisStrLeg=DisStrLegend{iD};
            if strcmp(iDiseaseStr,'Sev')
                icolD=6;
            elseif strcmp(iDiseaseStr,'Inc')
                icolD=7;
            end        
            
            % aggregate surveys per latitude interval
            NumberSurveysPerLatitudeInterval=[];
            DiseaseCountsPerLatitude=[];
            [NumberSurveysPerLatitudeInterval,DiseaseCountsPerLatitude]=aggregateSurveysPerLatitude(SurveyDataArray,icolD,LatitudeBinArray);
    
            % aggregate surveys per longitude interval
            NumberSurveysPerLongitudeInterval=[];
            DiseaseCountsPerLongitude=[];
            [NumberSurveysPerLongitudeInterval,DiseaseCountsPerLongitude]=aggregateSurveysPerLongitude(SurveyDataArray,icolD,LongBinArray);
    
            % plot disease prevalence vs latitude as bar chart
            figName=strcat(SubPlotFolderPath,RustType,'_ProbDiseasePerLatitude_',iDiseaseStr,'_',iSeason,'.png');
            plotDiseasePrevalenceScoresLatLon(figName,DiseaseCountsPerLatitude,NumberSurveysPerLatitudeInterval,LatitudeBinArray,iRustStr,iDisStrLeg,colorsBarChart,'latitude');
        
            % plot disease prevalence vs longitude as bar chart
            figName=strcat(SubPlotFolderPath,RustType,'_ProbDiseasePerLongitude_',iDiseaseStr,'_',iSeason,'.png');
            plotDiseasePrevalenceScoresLatLon(figName,DiseaseCountsPerLongitude,NumberSurveysPerLongitudeInterval,LongBinArray,iRustStr,iDisStrLeg,colorsBarChart,'longitude');
                            
            close all;
            
        end % end loop over disease metrics
    end % end loop over wheat season
end  %loop over wheat rusts
    
%%% analyse and plot rust disease prevalence as function of altitude for all three types of wheat rusts in ET
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
% 
% Summary:
% For all types of wheat rusts
%   read the cleaned survey data and conduct additional consistency tests
%   for data entries in the column "altitude"
%     for both wheat seasons in Ethiopia
%      for both disease measures (incidence, severity)
%         count disease prevalence per altitude bin (2000-3000m)
%         conduct linear fit to mean prevalence per altitude
%         plot figure for comparing altitude-prevalence correlations of different
%         rusts

% clear work-space
clear all;
close all; 

% Def. paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\AltitudeCorrelation\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% define types of wheat rust, wheat seasons, disease measures, temporal domain and altitude bins 
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
Seasons={'Belg_MarJul','Meher_AugDec'};
DiseaseMeasure={'Sev','Inc'};
DisStrLegend={'severity','incidence'};
AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
AltitudeBinArray=[1950,2050,2150,2250,2350,2450,2550,2650,2750,2850,2950,3050];

% loop types of wheat rusts 
for iR=1:length(AllRusts)
    
    % get identifier for type of wheat rust
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create plot directory
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanDataFileName=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readCleanSurveyData(CleanDataFileName);      
    
    % check consistency of survey entries in column "altitude", as these
    % have not been cleaned in the initial generic cleaning scripts
    CleanEthiopiaDataArray={};
    CleanEthiopiaDataArray=cleanAltitudeEntries(DataArrayAll,RustType,SubPlotFolderPath);
     
    % convert to numeric array
    SurveyDataEthiopiaReducedNumeric = convertFromCellToNumericDataArray(CleanEthiopiaDataArray);
     
    %%% get separate data arrays for Belg and Meher wheat season
    % Meher season
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
    % get max, min, mean altitude
    [MaxAltitude,IndMaxAltitude]=max(iSurveyDataMeher(:,9));
    [MinAltitude,IndMinAltitude]=min(iSurveyDataMeher(:,9));
    MeanAltitude=mean(iSurveyDataMeher(:,9));
    MedianAltitude=median(iSurveyDataMeher(:,9));
    
    % Belg season
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
    % get min, max, mean altitude
    [MaxAltitudeBelg,IndMaxAltitudeBelg]=max(iSurveyDataBelg(:,9));
    [MinAltitudeBelg,IndMinAltitudeBelg]=min(iSurveyDataBelg(:,9));
    MeanAltitudeBelg=mean(iSurveyDataBelg(:,9));
    MedianAltitudeBelg=median(iSurveyDataBelg(:,9));
    
    % define rust-specific colors for figures
    colorsBarChart = defineColorsForDifferentRusts(iRustStr);
    
    % loop wheat seasons
    for iS=1:length(Seasons)
        iSeasonStr=Seasons{iS};
        
        iSurveyData=[];
        if iS==1
            iSurveyData=iSurveyDataBelg;
        elseif iS==2
            iSurveyData=iSurveyDataMeher;
        end
        
        % loop disease scores (for separate analysis of severity and incidence scores)
        for iD=1:length(DiseaseMeasure)
            iDiseaseStr=DiseaseMeasure{iD};
            iDisStrLeg=DisStrLegend{iD};
            if strcmp(iDiseaseStr,'Sev')
                icolD=6;
            elseif strcmp(iDiseaseStr,'Inc')
                icolD=7;
            end        
            
            % aggregate surveys per altitude interval, counting the number of surveys with low, medium and
            % high disease prevalence per altitude bin
            NumberSurveysPerAltitudeInterval=[];
            DiseaseCountsPerAltitude=[];
            [NumberSurveysPerAltitudeInterval,DiseaseCountsPerAltitude]=aggregateSurveysPerAltitude(iSurveyData,icolD,AltitudeBinArray);
    
            % calc. and plot the proportions of low/medium/high disease
            % levels per altitude level
            ProportionIncidenceLow=[];
            ProportionIncidenceMed=[];
            ProportionIncidenceHigh=[];
            ProportionIncidenceNegative=[];
            for iA=1:length(AltitudeBinArray)-1
                iNumS=NumberSurveysPerAltitudeInterval(iA);
                if iNumS>0
                    ProportionIncidenceLow(iA)=DiseaseCountsPerAltitude(iA,2)./ NumberSurveysPerAltitudeInterval(iA);
                    ProportionIncidenceMed(iA)=DiseaseCountsPerAltitude(iA,3)./ NumberSurveysPerAltitudeInterval(iA);
                    ProportionIncidenceHigh(iA)=DiseaseCountsPerAltitude(iA,4)./ NumberSurveysPerAltitudeInterval(iA);
                    ProportionIncidenceNegative(iA)=DiseaseCountsPerAltitude(iA,1)./NumberSurveysPerAltitudeInterval(iA);
                else
                    ProportionIncidenceLow(iA)=NaN;
                    ProportionIncidenceMed(iA)=NaN;
                    ProportionIncidenceHigh(iA)=NaN;
                    ProportionIncidenceNegative(iA)=NaN;
                end
            end
            
            % combine all three props into one array for plotting stacked
            % histograms
            AllProps=[];
            AllProps(:,4)=ProportionIncidenceNegative;
            AllProps(:,3)=ProportionIncidenceLow;
            AllProps(:,2)=ProportionIncidenceMed;
            AllProps(:,1)=ProportionIncidenceHigh;
            
            % check and plot linear trend
            for i=1:length(AltitudeBinArray)-1
                 XValues(i)=(AltitudeBinArray(i)+AltitudeBinArray(i+1))/2;
            end
            figName=strcat(SubPlotFolderPath,RustType,'_LinearTrend_',iDiseaseStr,'_',iSeasonStr,'Bar.png');
            fileName=strcat(SubPlotFolderPath,RustType,'_LinearTrend_',iDiseaseStr,'_',iSeasonStr,'.txt');
            calcAndPlotLinearTrendInDiseasePerAltitude(XValues,AllProps,NumberSurveysPerAltitudeInterval,AltitudeBinArray,colorsBarChart,iRustStr,iDisStrLeg,figName,fileName);
                       
           close all;
                    
            
        end % end loop over disease scores
    end %end loop over wheat seasons 
    close all;            
end % end loop over types of wheat rust



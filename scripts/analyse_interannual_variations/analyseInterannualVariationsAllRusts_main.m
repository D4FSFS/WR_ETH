% script to analyse inter-annual variations in wheat rust prevalence in
% Ethiopia 
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
%
% summary script-structure:
%
% for each type of wheat rust
%    read cleaned survey data
%    for each wheat season (minor, main)
%        for each disease score (severity, incidence)
%            aggregate all surveys per year and analyse disease prevalence
%            plot bar-charts showing interannual variations w.r.t: 
%                 (i) the prevalence (ratio infected fields/total number of surveys)
%                 (ii) the total number of surveyed fields
%           calculate linear fit to disease prevalence for each of the
%           three disease categories (low, mod, high); plot the fit
%           and write the fit diagnostics to file; aim of fit: get
%           indication of long-term trend in disease prevalence over last
%           10 years
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
     
% define paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\InterannualVariations\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% define types of wheat rust, wheat seasons and time-domain
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
Seasons={'Belg_MarJul','Meher_AugDec'};
DiseaseMeasure={'Sev','Inc'};
DisStrLegend={'severity','incidence'};
AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];

% loop all rusts 
for iR=1:length(AllRusts)
    
    % get identifier of rust in this iteration
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create plot directory
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanFieldDiseaseSurveyData=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readtable(CleanFieldDiseaseSurveyData);
    
    % convert to numeric array
    SurveyDataEthiopiaReducedNumeric = convertFromTableToNumericDataArray(DataArrayAll);
        
    % separate the two wheat seasons and restricting data to the main wheat season of years 2010-2019 
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
    
    iSurveyDataBelg=[];
    count=0;
    for iS=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
        iYear=SurveyDataEthiopiaReducedNumeric(iS,1);
        iMonth=SurveyDataEthiopiaReducedNumeric(iS,2);
        if (iYear>=2010 && iYear<=2017) && (iMonth>=3 && iMonth<=7)
            count=count+1;
            iSurveyDataBelg(count,:)=SurveyDataEthiopiaReducedNumeric(iS,:);
        end
    end
    
    % define rust-specific color for figures
    colorsBarChart = defineColorsForDifferentRusts(iRustStr);
        
    % get and plot the number of positives/negatives per year for each wheat season
    for iS=1:length(Seasons)
        
        % get survey data for the season
        iSeasonStr=Seasons{iS};
        iSurveyData=[];
        if iS==1
            iSurveyData=iSurveyDataBelg;
        elseif iS==2
            iSurveyData=iSurveyDataMeher;
        end
        
        % aggregate disease scores per year considering disease incidence
        % and disease severity
        for iD=1:length(DiseaseMeasure)
            iDiseaseStr=DiseaseMeasure{iD};
            iDisStrLeg=DisStrLegend{iD};
            if strcmp(iDiseaseStr,'Sev')
                icolD=6;
            elseif strcmp(iDiseaseStr,'Inc')
                icolD=7;
            end        
        
            % aggregate surveys per year counting the total number of surveys
            % per year as well as the number of surveys with low, medium and
            % high disease severity
            NumberSurveysPerYear=[];
            DiseaseCountsPerYear=[];
            [NumberSurveysPerYear,DiseaseCountsPerYear]=aggregateSurveysPerYear(iSurveyData,icolD,AllYears);
                                  
            % calc. and plot the proportions of positives of total per year, as well as
            % the proportions of low/medium/high inc. and sev. of all positives
            ProportionIncidenceLow=[];
            ProportionIncidenceMed=[];
            ProportionIncidenceHigh=[];
            ProportionIncidenceNegative=[];
            ProportionIncidenceLow=DiseaseCountsPerYear(:,2)./ flipud(NumberSurveysPerYear(:,1));
            ProportionIncidenceMed=DiseaseCountsPerYear(:,3)./ flipud(NumberSurveysPerYear(:,1));
            ProportionIncidenceHigh=DiseaseCountsPerYear(:,4)./ flipud(NumberSurveysPerYear(:,1));
            ProportionIncidenceNegative=DiseaseCountsPerYear(:,1)./ flipud(NumberSurveysPerYear(:,1));
             
            % combine all three props incidence in one to plot stacked histogram
            AllProps=[];
            AllProps(:,4)=ProportionIncidenceNegative;
            AllProps(:,3)=ProportionIncidenceLow;
            AllProps(:,2)=ProportionIncidenceMed;
            AllProps(:,1)=ProportionIncidenceHigh;
             
            % plot bar chart with proportions of disease (separataley for each rust, season,
            % disease metric) - old layour
            figName=strcat(SubPlotFolderPath,RustType,'_ProbDiseasePerYear_',iDiseaseStr,'_',iSeasonStr,'.png');
            plotPrevalenceBarChart(AllProps,NumberSurveysPerYear(:,1),colorsBarChart,iDisStrLeg,iRustStr,figName)
             
            % check and plot linear trend
            figName=strcat(SubPlotFolderPath,RustType,'_LinearTrend_',iDiseaseStr,'_',iSeasonStr,'.png');
            fileName=strcat(SubPlotFolderPath,iRustStr,'_LinTrend_',iDiseaseStr,'_',iSeasonStr,'Fit.txt');
            testLinearTrendOverYears(AllYears,AllProps,colorsBarChart,iRustStr,iDisStrLeg,figName,fileName);
  
            close all;
        end % end loop over disease measures
    end % end loop over seasons
end % end of loop over wheat rusts



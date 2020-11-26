% script for analysing within-season disease progress of wheat rusts in Ethiopia 
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
%
% summary script-structure:
% for each type of rust
%    read clean survey data and subset to data covering the main wheat season
%    calculate the time-duration from beginning of main season to the date of the survey
%    for each disease metric (severity, incidence)
%       get mean prevalence (averaged over all years) per bi-weekly
%       time-interval and plot bar chart
%       fit 3-parameter logistic curve to within-season disease progress
%       using matlabs nonlinear regression method; 
%       plot fit and write fitting diagnostics to file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear workspace
clear all;
close all;

% define paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\WithinSeasonDiseaseProgress\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

%%%% loop all wheat rusts 
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
for iR=1:length(AllRusts)
    
    % get identifier of type of wheat rust
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
           
    % separate the two wheat seasons and restrict to years 2010-2019 
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
     
    % get the time-duration from the start of the main season to the date
    % of the survey
    for iEntry=1:length(iSurveyDataMeher(:,1))
        iDayOfSurvey=iSurveyDataMeher(iEntry,3);
        iMonthOfSurvey=iSurveyDataMeher(iEntry,2);
        iYearOfSurvey=iSurveyDataMeher(iEntry,1);
        iDateOfSurvey=datetime(iYearOfSurvey,iMonthOfSurvey,iDayOfSurvey);
        % get the number of days into the main wheat season, which is assumed to
        % start at the 1st of August every year
        iBeginningMainSeason=datetime(iYearOfSurvey,8,1);
        iDaysIntoMainSeason=days(iDateOfSurvey-iBeginningMainSeason);
        iBiweekIntoMainSeason=floor(iDaysIntoMainSeason/14)+1;
        iSurveyDataMeher(iEntry,9)=iDaysIntoMainSeason;
        iSurveyDataMeher(iEntry,10)=iBiweekIntoMainSeason;
    end
    
    % define start dates of bi-weekly time-intervalls as temporal bins
    AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
    iStartDate=datetime(AllYears,8,15);
    iEndDate=datetime(AllYears,12,31);
    iAllBiWeeks=datetime();
    for iY=1:length(AllYears)
        start=iStartDate(iY);
        enddate=iEndDate(iY);
        alldates=start:calweeks(2):enddate;
        if iY==1
            iAllBiWeeks=alldates;
        else
            iAllBiWeeks=[iAllBiWeeks;alldates];
        end
    end
    
    % aggregate all surveys per bi-weekly interval.
    % Surveys from all years are aggregated for analysing the mean disease 
    % prevalence in all surveys conducted in a particular
    % time-window of the main wheat season.
    
    % write all surveys per bi-weekly time-interval to file as it takes a while aggregating the surveys
    AllBiWeeklyDataArrays = aggregateSurveysPerBiWeek(iSurveyDataMeher,AllYears,RustType,iAllBiWeeks,SubPlotFolderPath);
    
    % read back in; file with all surveys per bi-weekly time-interval
    AllBiWeeklyDataArraysFromFile=readAllSurveysPerBiWeek(iAllBiWeeks,SubPlotFolderPath);
    AllBiWeeklyDataArrays=AllBiWeeklyDataArraysFromFile;
        
    % define rust-specific color for figures
    colorsBarChart = defineColorsForDifferentRusts(iRustStr);           
    
    % loop disease metrics
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
 
        % count disease occurences per bi-week
        [NumberSurveysPerBiweek,DiseaseCountsPerBiweek] = getDiseaseCountsPerBiweek(AllBiWeeklyDataArrays,iAllBiWeeks,icolD);

        % calc proportions of disease occurence         
        ProportionIncidenceLow=[];
        ProportionIncidenceMed=[];
        ProportionIncidenceHigh=[];
        ProportionIncidenceNegative=[];
        for iA=1:length(iAllBiWeeks(1,:))
            iNumS=NumberSurveysPerBiweek(iA);
            if iNumS>0
                ProportionIncidenceLow(iA)=DiseaseCountsPerBiweek(iA,2)./ NumberSurveysPerBiweek(iA);
                ProportionIncidenceMed(iA)=DiseaseCountsPerBiweek(iA,3)./ NumberSurveysPerBiweek(iA);
                ProportionIncidenceHigh(iA)=DiseaseCountsPerBiweek(iA,4)./ NumberSurveysPerBiweek(iA);
                ProportionIncidenceNegative(iA)=DiseaseCountsPerBiweek(iA,1)./NumberSurveysPerBiweek(iA);
            else
                ProportionIncidenceLow(iA)=0;
                ProportionIncidenceMed(iA)=0;
                ProportionIncidenceHigh(iA)=0;
                ProportionIncidenceNegative(iA)=0;
            end
        end
        
        % combine proportions into one array for plotting stacked histogram
        AllProps=[];
        AllProps(:,4)=ProportionIncidenceNegative;
        AllProps(:,3)=ProportionIncidenceLow;
        AllProps(:,2)=ProportionIncidenceMed;
        AllProps(:,1)=ProportionIncidenceHigh;
        
        % fit nonlinear regression model, write results to file and plot
        % fitted lines on top of a stacked bar-chart with mean prevalence
        % levels
        figName=strcat(SubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_','LogFit.png');
        fileName=strcat(SubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_','LogFit.txt');
        [mdlloglow,mdllogmod,mdlloghigh]=fitLogisticAndPlot(AllProps,iAllBiWeeks,NumberSurveysPerBiweek,SubPlotFolderPath,RustType,iDiseaseStr,iDisStrLeg,iRustStr,colorsBarChart,figName,fileName);
        
        
    end
    
end % end loop over rusts
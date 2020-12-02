% script to get an overview of the entire wheat rust dataset by calculating
% some descriptive stats
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
% 
% Summary:
% For each type of wheat rust
%   load cleaned data
%   compute overview stats for main and minor wheat season separately and write to file: 
%       number and proportion low, mod, high severity 
%       number and proportion low, mod, high incidence
%%%%%%%%%%%%%

% clear workspace
clear all;
close all;

% def. paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\OverviewStats\');
mkdir(PlotFilePath);

% include helper functions defined in another folder
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% define types of wheat rusts
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};

% loop all three wheat rusts 
for iR=1:length(AllRusts)
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create directory for storing results
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanDataFileName=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readCleanSurveyData(CleanDataFileName);
    
    % restrict survey data to years 2010-2019
    DataArray={};
    TimeInterval='2010-2019';
    counter=1;
    for iEntry=1:length(DataArrayAll(:,1))
       iYear=DataArrayAll{iEntry,2};
       if iYear>=2010
           DataArray(counter,:)=DataArrayAll(iEntry,:);
           counter=counter+1;
       end
    end  
    
    % analyse both wheat seasons separately  
    WheatSeasons={'Belg','Meher'};
    MonthsOfSeason=[4,7,8,12];
    for iSeason=1:length(WheatSeasons)
        
        % get characteristics of this wheat season
        iWheatSeasonStr=WheatSeasons{iSeason};
        if strcmp(iWheatSeasonStr,"Belg")
            iStartMonth=MonthsOfSeason(1);
            iEndMonth=MonthsOfSeason(2);
        elseif strcmp(iWheatSeasonStr,"Meher")
            iStartMonth=MonthsOfSeason(3);
            iEndMonth=MonthsOfSeason(4);
        end
        
        % open file for writing summaries
        SummaryFilename=strcat(SubPlotFolderPath,'OverviewData_ET_',iRustStr,'_',iWheatSeasonStr,'.txt');
        fidSummaryFile=fopen(SummaryFilename,'w');
        fprintf(fidSummaryFile,'Summary survey data  %s \n\n',RustType);
        fprintf(fidSummaryFile,'TimeInterval:  %s \n\n',TimeInterval);
        fprintf(fidSummaryFile,'WheatSeason: %s \n\n',iWheatSeasonStr);
        
        % get subset of data for this wheat season
        iSurveyDataSeason={};
        count=0;
        for iS=1:length(DataArray(:,1))
            iMonth=cell2mat(DataArray(iS,3));
            if ( (iMonth>=iStartMonth) && (iMonth<=iEndMonth) )
                count=count+1;
                iSurveyDataSeason(count,:)=DataArray(iS,:);
            end
        end
        
        % get the total number of surveys
        TotalNumberSurveys=length(iSurveyDataSeason(:,1));
        fprintf(fidSummaryFile,'Total number of survey entries:  %f \n\n',TotalNumberSurveys);

        % get the total number of field surveys per disease catagories (no
        % disease, low, moderate, high severity / incidence)
        TotalNumberSurveysNoSeverity=length(find(cell2mat(iSurveyDataSeason(:,11))==0));
        TotalNumberSurveysLowSeverity=length(find(cell2mat(iSurveyDataSeason(:,11))==1));
        TotalNumberSurveysModSeverity=length(find(cell2mat(iSurveyDataSeason(:,11))==2));
        TotalNumberSurveysHighSeverity=length(find(cell2mat(iSurveyDataSeason(:,11))==3));
        TotalNumberSurveysNoIncidence=length(find(cell2mat(iSurveyDataSeason(:,12))==0));
        TotalNumberSurveysLowIncidence=length(find(cell2mat(iSurveyDataSeason(:,12))==1));
        TotalNumberSurveysModIncidence=length(find(cell2mat(iSurveyDataSeason(:,12))==2));
        TotalNumberSurveysHighIncidence=length(find(cell2mat(iSurveyDataSeason(:,12))==3));

        % get the proportions relative to the total number of surveys
        TotalPropNoSev=TotalNumberSurveysNoSeverity/TotalNumberSurveys;
        TotalPropLowSev=TotalNumberSurveysLowSeverity/TotalNumberSurveys;
        TotalPropModSev=TotalNumberSurveysModSeverity/TotalNumberSurveys;
        TotalPropHighSev=TotalNumberSurveysHighSeverity/TotalNumberSurveys;
        TotalPropNoInc=TotalNumberSurveysNoIncidence/TotalNumberSurveys;
        TotalPropLowInc=TotalNumberSurveysLowIncidence/TotalNumberSurveys;
        TotalPropModInc=TotalNumberSurveysModIncidence/TotalNumberSurveys;
        TotalPropHighInc=TotalNumberSurveysHighIncidence/TotalNumberSurveys;

        % write to file
        fprintf(fidSummaryFile,'Total number of surveys with zero severity:  %f \n',TotalNumberSurveysNoSeverity);
        fprintf(fidSummaryFile,'Total prop of surveys with zero severity score:  %f \n\n',TotalPropNoSev);
        fprintf(fidSummaryFile,'Total number of surveys with low severity score:  %f \n',TotalNumberSurveysLowSeverity);
        fprintf(fidSummaryFile,'Total prop of surveys with low severity score:  %f \n\n',TotalPropLowSev);
        fprintf(fidSummaryFile,'Total number of surveys with mod severity score:  %f \n',TotalNumberSurveysModSeverity);
        fprintf(fidSummaryFile,'Total prop of surveys with mod severity score:  %f \n\n',TotalPropModSev);
        fprintf(fidSummaryFile,'Total number of surveys with high severity score:  %f \n',TotalNumberSurveysHighSeverity);
        fprintf(fidSummaryFile,'Total prop of surveys with high severity score:  %f \n\n',TotalPropHighSev);
        fprintf(fidSummaryFile,'Total number of surveys with zero incidence score:  %f \n',TotalNumberSurveysNoIncidence);
        fprintf(fidSummaryFile,'Total prop of surveys with zero incidence score:  %f \n\n',TotalPropNoInc);
        fprintf(fidSummaryFile,'Total number of surveys with low incidence score:  %f \n',TotalNumberSurveysLowIncidence);
        fprintf(fidSummaryFile,'Total prop of surveys with low incidence score:  %f \n\n',TotalPropLowInc);
        fprintf(fidSummaryFile,'Total number of surveys with mod incidence score:  %f \n',TotalNumberSurveysModIncidence);
        fprintf(fidSummaryFile,'Total prop of surveys with mod incidence score:  %f \n\n',TotalPropModInc);
        fprintf(fidSummaryFile,'Total number of surveys with high incidence score:  %f \n',TotalNumberSurveysHighIncidence);
        fprintf(fidSummaryFile,'Total prop of surveys with high incidence score:  %f \n\n',TotalPropHighInc);

        % get the total number of field surveys with disease levels (sev / inc) >=low and >=mod
        TotalNumberSevEqualGreaterLow=TotalNumberSurveysLowSeverity+TotalNumberSurveysModSeverity+TotalNumberSurveysHighSeverity;
        TotalNumberSevEqualGreaterMod=TotalNumberSurveysModSeverity+TotalNumberSurveysHighSeverity;
        TotalNumberIncEqualGreaterLow=TotalNumberSurveysLowIncidence+TotalNumberSurveysModIncidence+TotalNumberSurveysHighIncidence;
        TotalNumberIncEqualGreaterMod=TotalNumberSurveysModIncidence+TotalNumberSurveysHighIncidence;

        % get the proporations relative to the total number of surveys
        TotalPropGELowSev=TotalNumberSevEqualGreaterLow/TotalNumberSurveys;
        TotalPropGEModSev=TotalNumberSevEqualGreaterMod/TotalNumberSurveys;
        TotalPropGELowInc=TotalNumberIncEqualGreaterLow/TotalNumberSurveys;
        TotalPropGEModInc=TotalNumberIncEqualGreaterMod/TotalNumberSurveys;

        % write to file
        fprintf(fidSummaryFile,'Total number of surveys with severity score >=low:  %f \n',TotalNumberSevEqualGreaterLow);
        fprintf(fidSummaryFile,'Total prop of surveys with severity score >=low:  %f \n\n',TotalPropGELowSev);
        fprintf(fidSummaryFile,'Total number of surveys with severity score >=mod:  %f \n',TotalNumberSevEqualGreaterMod);
        fprintf(fidSummaryFile,'Total prop of surveys with severity score >=mod:  %f \n\n',TotalPropGEModSev);
        fprintf(fidSummaryFile,'Total number of surveys with incidence score >=low:  %f \n',TotalNumberIncEqualGreaterLow);
        fprintf(fidSummaryFile,'Total prop of surveys with incidence score >=low:  %f \n\n',TotalPropGELowInc);
        fprintf(fidSummaryFile,'Total number of surveys with incidence score >=mod:  %f \n',TotalNumberIncEqualGreaterMod);
        fprintf(fidSummaryFile,'Total prop of surveys with incidence score >=mod:  %f \n\n\n',TotalPropGEModInc);
    
       
    end  % end loop wheat seasons 
    
end % end loop types of wheat rust